extends Node2D
class_name FuelCharger

const _TICK_FOR_EACH := 3
var _charged_is_playing := false

onready var _fuel_anim_node := $Boost/Fuel as AnimatedSprite
onready var _charged_audio_node := $Boost/Charged as AudioStreamPlayer2D


func charged() -> void:
    _fuel_anim_node.playing = true


func _on_Fuel_frame_changed() -> void:
    if not _charged_is_playing:
        _charged_is_playing = true
        _charged_audio_node.play()

    if _fuel_anim_node.frame % _TICK_FOR_EACH == 0:
        _charged_is_playing = false
        _fuel_anim_node.playing = false
