extends Area2D
class_name TempoArea

onready var ground_node := $Ground as Area2D # Наметка для выравнивания.


func _ready() -> void:
    ground_node.queue_free()
