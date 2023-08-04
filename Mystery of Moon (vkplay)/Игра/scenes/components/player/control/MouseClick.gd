extends AnimatedSprite
class_name MouseClick

onready var _show_anim_node := $Show as AnimationPlayer


func _ready() -> void:
    scale = Vector2(0, 3)


func playing(anim_name: String) -> void:
    play(anim_name)


func showing() -> void:
    _show_anim_node.play('show')
