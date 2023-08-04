extends Area2D
class_name Puzzle

#warning-ignore:UNUSED_CLASS_VARIABLE
export(int, 1, 9) var number: int
export(Texture) var _texture: Texture

onready var _collision_node := $Collision as CollisionPolygon2D

onready var _texture_node := $Texture as Sprite
onready var _texture_hide_anim_node := $Texture/Hide as AnimationPlayer

onready var _collected_audio_node := $Collected as AudioStreamPlayer2D

onready var _menu_node := $'/root/Level/Player/Menu' as Menu


func _ready() -> void:
    _texture_node.set_texture(_texture)


func set_collision_disabled(is_disabled: bool) -> void:
    _collision_node.set_deferred('disabled', is_disabled)


func collect() -> void:
    _collision_node.queue_free()
    _texture_hide_anim_node.play('hide')

    _collected_audio_node.play()

    if not number in GC.puzzles_state:
        _menu_node.pause_switcher(number)
        GC.save_puzzles(number)


func _on_Hide_animation_finished(_anim_name: String) -> void:
    _texture_node.hide()
