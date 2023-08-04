extends RigidBody2D
class_name Scrap

onready var _falled_audio_node := $Falled as AudioStreamPlayer2D


func _ready() -> void:
    set_linear_velocity(Vector2(GC.external_get_random_int(-30, -20), GC.external_get_random_int(-50, 50)))
    set_applied_force(Vector2(GC.external_get_random_int(-50, -40), GC.external_get_random_int(-40, 40)))


func put(scrap: Scrap) -> void:
    scrap.set_deferred('sleeping', true)
    _falled_audio_node.play()
