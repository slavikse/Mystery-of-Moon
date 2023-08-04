extends Area2D
class_name AlienMob

export(bool) var _is_agressive := false
export(bool) var _is_without_raincoat := false

signal alien_destroy

var is_killed := false

onready var _collision_node := $Collision as CollisionPolygon2D
onready var _sprite_anim_node := $SpriteAnim as AnimatedSprite
onready var _destroy_delay_node := $Destroy/Delay as Timer
onready var _splitting_audio_node := $Splitting as AudioStreamPlayer2D


func _ready() -> void:
    set_collision_disabled(not _is_without_raincoat)

    if _is_without_raincoat:
        _is_agressive = false


func set_collision_disabled(is_disabled: bool) -> void:
    _collision_node.set_deferred('disabled', is_disabled)


func destroy() -> void:
    is_killed = true
    set_collision_disabled(true)

    _sprite_anim_node.stop()
    _sprite_anim_node.hide()

    _destroy_delay_node.start()

    _splitting_audio_node.play()
    emit_signal('alien_destroy')


func _on_Destroy_Delay_timeout() -> void:
    queue_free()
