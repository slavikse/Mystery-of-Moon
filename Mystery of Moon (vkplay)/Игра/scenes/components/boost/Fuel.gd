extends Node2D
class_name FuelCharger

export(bool) var _is_deactivated := false
export(bool) var _is_one_charge := false

const _TICK_FOR_EACH := 3
var _charged_is_playing := false

onready var _boost_node := $Boost as Boost
onready var _fuel_anim_node := $Boost/Fuel as AnimatedSprite
onready var _charged_audio_node := $Boost/Charged as AudioStreamPlayer2D


func _ready() -> void:
    _boost_node.is_one_charge = _is_one_charge

    if _is_deactivated:
        _boost_node.collision_deactivated(true)


func charged() -> void:
    _fuel_anim_node.playing = true


func _on_Fuel_frame_changed() -> void:
    if not _charged_is_playing:
        _charged_is_playing = true
        _charged_audio_node.play()

    if _fuel_anim_node.frame % _TICK_FOR_EACH == 0:
        _charged_is_playing = false
        _fuel_anim_node.playing = false
