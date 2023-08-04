extends Area2D
class_name AlienBody

const _SCARE_COLOR := '#ff0000'

onready var _collision_node := $Collision as CollisionPolygon2D
onready var _alien_node := $'..' as Alien


func destroy() -> void:
    _collision_node.set_deferred('disabled', true)
    _alien_node.destroy()
