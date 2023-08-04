extends Area2D
class_name Boost

enum BoostType { None, Fuel }
#warning-ignore:UNUSED_CLASS_VARIABLE
export(BoostType) var external_boost_type := BoostType.Fuel

const _DEACTIVATED_COLOR := '#888'
const _FALL_POSITION_Y := 600.0
const _FALL_INTERPOLATE_TIME := 2.0

var is_one_charge := false

onready var _collision_node := $Collision as CollisionPolygon2D
onready var _soar_anim_node := $Soar as AnimationPlayer
onready var _flame_sparks_node := $Flame/Sparks as Particles2D
onready var _fall_tween_node := $Fall as Tween
# Вложено в Boost в родителе Fuel.
onready var _refuel_anim_node := $Refuel as AnimationPlayer
onready var _hisses_audio_node := $Hisses as AudioStreamPlayer2D
onready var _falled_audio_node := $Falled as AudioStreamPlayer2D


func _ready() -> void:
    _soar_end_animation()


func _soar_start_animation() -> void:
    _flame_sparks_node.emitting = true
    _hisses_audio_node.play()


func _soar_end_animation() -> void:
    _flame_sparks_node.emitting = false
    _hisses_audio_node.stop()


func start_refuel_animation() -> void:
    _refuel_anim_node.play('refuel')

    if is_one_charge:
        _flame_sparks_node.emitting = false

        #warning-ignore:RETURN_VALUE_DISCARDED
        _fall_tween_node.interpolate_property(self, 'position', position,
            Vector2(position[0], _FALL_POSITION_Y), _FALL_INTERPOLATE_TIME, Tween.TRANS_QUAD, Tween.EASE_IN)
        #warning-ignore:RETURN_VALUE_DISCARDED
        _fall_tween_node.start()


func collision_deactivated(is_disabled: bool) -> void:
    external_boost_type = int(BoostType.None)
    _collision_node.set_deferred('disabled', is_disabled)
    _soar_anim_node.stop()
    _hisses_audio_node.stop()
    _flame_sparks_node.emitting = not is_disabled
    modulate = _DEACTIVATED_COLOR


func _on_Boost_area_entered(area: Area2D) -> void:
    if area is Ground:
        #warning-ignore:RETURN_VALUE_DISCARDED
        _fall_tween_node.stop_all()
        collision_deactivated(true)
        _falled_audio_node.play()
