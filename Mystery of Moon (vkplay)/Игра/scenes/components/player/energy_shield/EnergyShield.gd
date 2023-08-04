extends Area2D
class_name EnergyShield

enum _ReflectedType { METEOR, BUBBLE }

const _HITS_REFLECTED_FOR_METEOR := 1
const _HITS_REFLECTED_FOR_BUBBLES := 10

var _is_activating := false
var _is_activated := false
var _is_deactivating := false
var _is_deactivated := false

var _hits_reflected_for_meteor := 0
var _hits_reflected_for_bubbles := 0

onready var _collision_node := $Collision as CollisionShape2D
onready var _activate_anim_node := $Activate as AnimationPlayer
onready var _pulse_anim_node := $Pulse as AnimationPlayer

onready var _activated_audio_node := $Activated as AudioStreamPlayer
onready var _reflected_audio_node := $Reflected as AudioStreamPlayer

onready var _control_manager_node := get_parent().get_node('ControlManager') as ControlManager
onready var _player_node := get_parent() as Area2D # Player


func _ready() -> void:
    _activate_anim_node.play('reset')


func _process(_delta: float) -> void:
    if _is_activating:
        if not _activated_audio_node.is_playing():
            _activated_audio_node.play()
    else:
        _activated_audio_node.stop()


func activate() -> void:
    if not _is_activating: # №1
        _is_activating = true
        _is_deactivated = false

        _collision_node.set_deferred('disabled', false)
        _activate_anim_node.play('activating')
        _pulse_anim_node.play('pulse')


func deactivate() -> void:
    if not _is_deactivated and _control_manager_node.ext_energy_shield_enabled: # №3
        _is_deactivating = true
        _is_activating = false
        _is_deactivated = true

        _hits_reflected_for_meteor = 0
        _hits_reflected_for_bubbles = 0

        Input.action_release('energy_shield')
        _collision_node.set_deferred('disabled', true)

        _pulse_anim_node.play('RESET')
        _activate_anim_node.play('deactivating')


func _on_Activate_animation_finished(anim_name: String) -> void:
    if anim_name == 'activating': # №2
        _is_activated = true

    elif anim_name == 'deactivating': # №4
        _is_activated = false
        _is_deactivating = false

        _activate_anim_node.play('reset')


func _on_EnergyShield_area_entered(area: Area2D) -> void:
    if _is_activated and (area is Meteor or area is MeteorInCosmos):
        _increment_hits_reflected(int(_ReflectedType.METEOR))
        _activate_anim_node.play('protection')
        _reflected_audio_node.play()

        #warning-ignore:UNSAFE_METHOD_ACCESS
        _player_node.ext_camera_shake('shake')
        #warning-ignore:UNSAFE_METHOD_ACCESS
        area.destroy()


func _on_EnergyShield_body_entered(body: RigidBody2D) -> void:
    if _is_activated and body is Bubble:
        var bubble_node := body as Bubble

        if bubble_node.bubble_type != int(bubble_node.BubbleType.FUEL):
            _increment_hits_reflected(int(_ReflectedType.BUBBLE))
            _activate_anim_node.play('protection')
            _reflected_audio_node.play()

            bubble_node.is_destroyed = true
            bubble_node.burst()


func _increment_hits_reflected(type: int) -> void:
    if type == int(_ReflectedType.METEOR):
        _hits_reflected_for_meteor += 1

        if _hits_reflected_for_meteor == _HITS_REFLECTED_FOR_METEOR:
            _hits_reflected_for_meteor = 0

            var timer := Timer.new()
            timer.autostart = true
            timer.wait_time = 0.25 # Время анимации отражения удара =0.15
            #warning-ignore:RETURN_VALUE_DISCARDED
            timer.connect('timeout', self, "_reflected_for_meteor_timeout", [timer])
            add_child(timer)

    elif type == int(_ReflectedType.BUBBLE):
        _hits_reflected_for_bubbles += 1

        if _hits_reflected_for_bubbles == _HITS_REFLECTED_FOR_BUBBLES:
            _hits_reflected_for_bubbles = 0
            deactivate()


func _reflected_for_meteor_timeout(timer: Timer) -> void:
    timer.queue_free()
    deactivate()
