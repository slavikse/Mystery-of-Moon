extends Area2D
class_name Altar

onready var _collision_node := $Collision as CollisionPolygon2D
onready var _statue_anim_node := $Statue as AnimatedSprite

onready var _magic_audio_node := $Magic as AudioStreamPlayer2D
onready var _collect_audio_node := $Collect as AudioStreamPlayer2D
onready var _bury_audio_node := $Bury as AudioStreamPlayer2D


func _ready() -> void:
    _statue_anim_node.play('glow')


func _on_Magic_Delay_timeout() -> void:
    _magic_audio_node.play()


func activation() -> void:
    _collision_node.set_deferred('disabled', true)
    _statue_anim_node.stop()

    _magic_audio_node.stop()
    _collect_audio_node.play()
    _bury_audio_node.play()
