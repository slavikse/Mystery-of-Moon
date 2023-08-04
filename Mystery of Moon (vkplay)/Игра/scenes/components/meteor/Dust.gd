extends Node2D
class_name Dust

onready var _left_node := $Left as Particles2D
onready var _right_node := $Right as Particles2D


func setting(left_position: Vector2, right_position: Vector2) -> void:
    _left_node.position = left_position
    _right_node.position = right_position


func emitting() -> void:
    _left_node.emitting = true
    _right_node.emitting = true
