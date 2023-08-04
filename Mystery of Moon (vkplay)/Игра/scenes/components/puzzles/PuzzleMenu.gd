extends Node2D
class_name PuzzleMenu

export(Texture) var _texture: Texture

const _MODULATE_LOCK := '#50320057'
const _MODULATE_UNLOCK := '#ffffff'


func _ready() -> void:
    ($Texture as Sprite).set_texture(_texture)
    lock_show()


func lock_show() -> void:
    ($Texture as Sprite).modulate = _MODULATE_LOCK


func lock_hide() -> void:
    ($Texture as Sprite).modulate = _MODULATE_UNLOCK
