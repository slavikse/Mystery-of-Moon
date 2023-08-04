extends Area2D
class_name Boost

enum BoostType { None, Fuel }
#warning-ignore:UNUSED_CLASS_VARIABLE
export(BoostType) var external_boost_type := BoostType.Fuel

const _FALL_POSITION_Y := 600.0
const _FALL_INTERPOLATE_TIME := 2.0

# Вложено в Boost в родителе Fuel.
onready var _refuel_anim_node := $Refuel as AnimationPlayer
onready var _falled_audio_node := $Falled as AudioStreamPlayer2D


func start_refuel_animation() -> void:
    _refuel_anim_node.play('refuel')


func _on_Boost_area_entered(area: Area2D) -> void:
    if area is Ground:
        _falled_audio_node.play()
