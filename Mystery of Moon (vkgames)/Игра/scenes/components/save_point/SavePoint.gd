extends Area2D
class_name SavePoint

onready var _save_shadow_node := $SaveShadow as Node2D
onready var _saved_audio_node := $Saved as AudioStreamPlayer


func _ready() -> void:
    _save_shadow_node.hide()


func set_save_shadow(position_y: float) -> void:
    _save_shadow_node.position[1] = position_y - 4.0
    _save_shadow_node.show()
    _saved_audio_node.play()
