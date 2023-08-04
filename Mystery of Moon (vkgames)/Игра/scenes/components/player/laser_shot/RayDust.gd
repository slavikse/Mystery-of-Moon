extends CPUParticles2D

onready var _dust_audio_node := $Dust as AudioStreamPlayer2D


func emit(collision_point: Vector2) -> void:
    position = collision_point
    emitting = true
    _dust_audio_node.play()
