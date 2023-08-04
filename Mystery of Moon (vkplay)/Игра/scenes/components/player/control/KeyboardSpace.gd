extends Area2D

onready var _textures_anim_node := $Textures as AnimatedSprite
onready var _textures_show_anim_node := $Textures/Show as AnimationPlayer


func _ready() -> void:
    _textures_anim_node.scale = Vector2(0, 3)


func _on_KeyboardSpace_area_entered(_area: Area2D) -> void:
    _textures_show_anim_node.play('show')
