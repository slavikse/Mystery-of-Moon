extends Node2D
class_name HelloLuna

var is_control_manager_showed := false

onready var _landing_ship_audio_node := $LandingShip as AudioStreamPlayer
onready var luna_node := $Luna as Node2D
onready var landing_node := $Landing as Node2D
onready var skip_node := $Skip as Button
onready var _start_click_audio_node := $FirstStartGame/ButtonBackground/Start/Click as AudioStreamPlayer
onready var _audios_playing_container_node := $FirstStartGame/ButtonBackground/AudiosPlayingContainer as Node2D
onready var _volume_on_node := $FirstStartGame/ButtonBackground/AudiosPlayingContainer/AudiosPlaying/VolumeOn as Sprite
onready var _hover_click_audio_node := $FirstStartGame/ButtonBackground/HoverClick as AudioStreamPlayer
onready var _menu_node := $'/root/Level/Player/Menu' as Menu


func _ready() -> void:
    luna_node.show()
    landing_node.hide()
    skip_node.hide()
    show()

    if not is_control_manager_showed:
        get_control_manager_node().hide()


func _on_Start_mouse_entered() -> void:
    _hover_click_audio_node.play()


func _on_Start_pressed() -> void:
    skip_node.show()
    ($FirstStartGame/ButtonBackground/Start/Started as AnimationPlayer).play('started')

    _start_click_audio_node.play()
    _landing_ship_audio_node.play()


func _on_Started_animation_finished(_anim_name: String) -> void:
    $FirstStartGame.queue_free()
    ($Luna/Landing as AnimationPlayer).play('Landing')
    ($Luna/PlayerShip/Shaking as AnimationPlayer).play('shake')
    ($Luna/PlayerShip/PanelShaking as AnimationPlayer).play('move')
    ($Luna/PlayerShip/PlayerMoving as AnimationPlayer).play('move')


func get_control_manager_node() -> ControlManager:
    return $'/root/Level/Player/ControlManager' as ControlManager


func ext_destroy() -> void:
    ($Luna/Landing as AnimationPlayer).stop(true)
    ($Landing/Landing as AnimationPlayer).stop(true)

    #warning-ignore:UNSAFE_METHOD_ACCESS
    ($'/root/Level/Ship' as Node2D).ext_start_arrival()

    is_control_manager_showed = true
    get_control_manager_node().show()
    queue_free()
    (get_tree() as SceneTree).paused = false


func _on_Landing_animation_finished(_anim_name: String) -> void:
    ($Luna as Node2D).hide()
    ($Landing as Node2D).show()
    ($Landing/Landing as AnimationPlayer).play('Landing')


func _on_Landing2_animation_finished(_anim_name: String) -> void:
    _menu_node.playing_audios('clip')
    ext_destroy()


func _on_Skip_pressed() -> void:
    _on_Landing2_animation_finished('')


func _on_AudiosPlaying_pressed() -> void:
    _menu_node.on_AudiosPlaying_pressed()

    if _menu_node.is_audios_playing:
        _volume_on_node.show()
    else:
        _volume_on_node.hide()


func _on_AudiosPlaying_mouse_entered() -> void:
    _audios_playing_container_node.modulate = _menu_node.COLOR_WHITE
    _hover_click_audio_node.play()


func _on_AudiosPlaying_mouse_exited() -> void:
    _audios_playing_container_node.modulate = _menu_node.COLOR_GRAY


func _on_Exit_mouse_entered() -> void:
    _hover_click_audio_node.play()


func _on_Exit_pressed() -> void:
    (get_tree() as SceneTree).quit()
