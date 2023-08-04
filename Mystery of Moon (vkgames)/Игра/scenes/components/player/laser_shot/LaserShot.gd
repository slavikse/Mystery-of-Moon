extends Node2D
class_name LaserShot

const _WEAPON_ROTATION_COMPENSATION := 197.0
const _CHARGE_ANIMATION_COUNT := 4

var is_enabled := false
var is_fuel_consumer := false # Потребляет энергию, пока заряжается пушка.

var _is_waiting_for_shot := false
var is_shooting := false
var _is_charge_resetting := false

#onready var _toggle_showing_anim_node := $ToggleShowing as AnimationPlayer

onready var _weapon_node := $Weapon as Node2D
onready var _weapon_charge_anim_node := $Weapon/Charge as AnimatedSprite
onready var _weapon_charge_fire_node := $Weapon/Charge/Fire as Timer
onready var _weapon_charge_ray_node := $Weapon/Charge/LaserShotRay as Area2D
onready var _weapon_charge_ray_collision_node := $Weapon/Charge/LaserShotRay/Collision as CollisionPolygon2D

onready var _weapon_charging_audio_node := $Weapon/Charge/Charging as AudioStreamPlayer
onready var _weapon_shooting_audio_node := $Weapon/Charge/Shooting as AudioStreamPlayer
onready var _weapon_discharging_audio_node := $Weapon/Charge/Discharging as AudioStreamPlayer

onready var _player_node := get_parent() as Area2D # Player


func _ready() -> void:
    laser_shot(false)


func _process(_delta: float) -> void:
    #warning-ignore:UNSAFE_PROPERTY_ACCESS
    if is_enabled and not _player_node.ext_is_game_over:
#        _weapon_rotation()

        #warning-ignore:UNSAFE_PROPERTY_ACCESS
        if _player_node.fuel > 0.0:
            pass
#            _shooting()
        else:
            is_fuel_consumer = false
    else:
        is_fuel_consumer = false

    _charging_shooting_audio()


func toggle_show(is_shown: bool) -> void:
    pass
#    if is_enabled:
#        if is_shown:
#            _toggle_showing_anim_node.play('show')
#        else:
#            _toggle_showing_anim_node.play('hide')


func _weapon_rotation() -> void:
    var cursor_angle := global_position.angle_to_point(get_global_mouse_position())
    _weapon_node.rotation_degrees = rad2deg(cursor_angle) - _WEAPON_ROTATION_COMPENSATION


func _shooting() -> void:
    var is_pressed := Input.is_action_just_pressed('laser_shot')
    var is_released := Input.is_action_just_released('laser_shot')

    if is_pressed:
        _is_waiting_for_shot = true

    if is_released:
        _is_waiting_for_shot = false

    if not _is_charge_resetting:
        if _is_waiting_for_shot and _weapon_charge_anim_node.animation == 'cooling':
            laser_shot(true)

        if is_released and _weapon_charge_anim_node.animation == 'heating':
            laser_shot(false)


func laser_shot(_is_shooting: bool) -> void:
    var _weapon_charge_frame_previous := _weapon_charge_anim_node.frame + 1

    if _is_shooting:
        _weapon_charge_anim_node.play('heating')
    else:
        _weapon_charge_anim_node.play('cooling')

    _weapon_charge_anim_node.frame = _CHARGE_ANIMATION_COUNT - _weapon_charge_frame_previous


func _charging_shooting_audio() -> void:
    if is_fuel_consumer:
        if not _weapon_charging_audio_node.is_playing():
            _weapon_discharging_audio_node.stop()
            _weapon_charging_audio_node.play()
    else:
        if _weapon_charging_audio_node.is_playing():
            _weapon_charging_audio_node.stop()

    if is_shooting:
        if not _weapon_shooting_audio_node.is_playing():
            _weapon_shooting_audio_node.play()
    else: # Длина звука выстрела должна быть больше, чем длится выстрел в игре.
        if _weapon_shooting_audio_node.is_playing():
            _weapon_shooting_audio_node.stop()
            _weapon_discharging_audio_node.play()


func _on_Charge_frame_changed() -> void:
    if _weapon_charge_anim_node.animation == 'heating':
        if _weapon_charge_anim_node.frame == _CHARGE_ANIMATION_COUNT: # Стадия выстрела.
            is_shooting = true
            is_fuel_consumer = false

            _weapon_charge_ray_node.show()
            _weapon_charge_ray_collision_node.set_deferred('disabled', false)
            #warning-ignore:UNSAFE_METHOD_ACCESS
            _player_node.ext_camera_shake('middle_shake')
        else:
            is_fuel_consumer = true
    else:
        is_shooting = false
        is_fuel_consumer = false

        _weapon_charge_ray_node.hide()
        _weapon_charge_ray_collision_node.set_deferred('disabled', true)


func _on_Charge_animation_finished() -> void:
    if _weapon_charge_anim_node.animation == 'heating':
        _is_charge_resetting = true
        _weapon_charge_fire_node.start()
        Input.action_release('laser_shot')

    elif _weapon_charge_anim_node.animation == 'cooling':
        _is_charge_resetting = false


func _on_Charge_Fire_timeout() -> void:
    _weapon_charge_anim_node.play('cooling')


func stop_weapon_charge() -> void:
    is_fuel_consumer = false
    _weapon_charge_anim_node.stop()
    _weapon_charge_anim_node.frame = 0


func destruction() -> void:
    _is_charge_resetting = false
    _weapon_charge_anim_node.stop()
