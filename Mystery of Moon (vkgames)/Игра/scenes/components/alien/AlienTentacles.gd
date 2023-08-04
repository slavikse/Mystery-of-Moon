extends Area2D
class_name AlienTentacles

export(PackedScene) var _BubbleScene: PackedScene

const _SPEED_SCALE_INCREASE := 3.0
const _HERO_HEIGHT_FOR_DIVING := 300.0
const _CAPTURE_OFFSET := 420.0
const _GRAB_TWEEN_IN := 0.4
const _GRAB_TWEEN_OUT := 3.0

var _global_legs_underground_position_y := 0.0
var _is_tentacle_captured := false

onready var _trapper_anim_node := $Trapper as AnimatedSprite
onready var _legs_node := $Legs as Node2D
onready var _legs_grab_tween_node := $Legs/Grab as Tween
onready var _legs_catch_audio_node := $Legs/Catch as AudioStreamPlayer2D
onready var _legs_grabbed_audio_node := $Legs/Grabbed as AudioStreamPlayer2D
onready var _legs_tentacle_anim_node := $Legs/TentacleHook/Tentacle as AnimatedSprite

onready var _grabbed_anim_node := $Grabbed as AnimatedSprite
onready var _grabbed_delay_node := $Grabbed/Delay as Timer
onready var _grabbed_take_on_raincoat_node := $Grabbed/TakeOnRaincoat as AudioStreamPlayer2D
onready var _shot_anim_node := $Shot as AnimationPlayer
onready var _shooting_anim_node := $Shooting as AnimatedSprite
onready var _bubble_spawn_node := $BubbleSpawn as Position2D

onready var _player_node := $'/root/Level/Player' as Area2D # Player
onready var _aliens_bubbles_node := $'/root/Level/Aliens/Bubbles' as Node2D
onready var _end_credits_node := $'/root/Level/EndCredits' as EndCredits


func _process(_delta: float) -> void:
    if _is_tentacle_captured:
        _player_node.global_position[1] = _legs_node.global_position[1] + _CAPTURE_OFFSET


func _on_TentacleSpeedIncrease_area_entered(_area: Area2D) -> void:
    _legs_tentacle_anim_node.speed_scale = _SPEED_SCALE_INCREASE


func grab() -> void:
    if _is_tentacle_captured:
        return

    _trapper_anim_node.stop()
    _trapper_anim_node.hide()
    _legs_tentacle_anim_node.stop()
    _global_legs_underground_position_y = _legs_node.global_position[1] + _HERO_HEIGHT_FOR_DIVING

    #warning-ignore:RETURN_VALUE_DISCARDED
    _legs_grab_tween_node.interpolate_property(_legs_node, 'global_position', _legs_node.global_position,
        Vector2(_legs_node.global_position[0], _legs_node.global_position[1] - GC.EXTERNAL_SCREEN_HEIGHT),
        _GRAB_TWEEN_IN, Tween.TRANS_SINE, Tween.EASE_IN)

    #warning-ignore:RETURN_VALUE_DISCARDED
    _legs_grab_tween_node.start()
    _legs_catch_audio_node.play()


func _on_TentacleHook_area_entered(area: Area2D) -> void:
    if area.name == 'Player':
        _is_tentacle_captured = true
        #warning-ignore:RETURN_VALUE_DISCARDED
        _legs_grab_tween_node.stop_all()
        #warning-ignore:UNSAFE_METHOD_ACCESS
        _player_node.ext_camera_shake('shake')

        #warning-ignore:RETURN_VALUE_DISCARDED
        _legs_grab_tween_node.interpolate_property(_legs_node, 'global_position', _legs_node.global_position,
            Vector2(_legs_node.global_position[0], _global_legs_underground_position_y),
            _GRAB_TWEEN_OUT, Tween.TRANS_SINE, Tween.EASE_OUT)

        #warning-ignore:RETURN_VALUE_DISCARDED
        _legs_grab_tween_node.start()
        _legs_grabbed_audio_node.play()


func _on_Grab_tween_all_completed() -> void:
    #warning-ignore:UNSAFE_PROPERTY_ACCESS
    _player_node.camera_death_node.play('final_tentacle')
    _grabbed_delay_node.start()


func _on_Grabbed_Delay_timeout() -> void:
    _grabbed_anim_node.play('grabbed')
    _grabbed_take_on_raincoat_node.play()


func _on_Grabbed_animation_finished() -> void:
    _is_tentacle_captured = false
    _grabbed_anim_node.hide()
    _shooting_anim_node.show()
    _shot()
    _end_credits_node.end_screen()


func _shot() -> void:
    _shot_anim_node.play('shot')


func _create_bubble_anim() -> void:
    var bubble_node := _BubbleScene.instance() as Bubble
    bubble_node.bubble_type = int(bubble_node.BubbleType.ALIEN)
    bubble_node.position = _bubble_spawn_node.global_position
    _aliens_bubbles_node.add_child(bubble_node)
