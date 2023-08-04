extends Area2D

var _is_ray_shooting := false

onready var _ship_node := $Ship as Node2D
onready var _laser_shot_ray_node := $Ship/LaserShotRay as LaserShotRay
onready var _laser_shooting_audio_node := $Ship/LaserShotRay/Shooting as AudioStreamPlayer2D
onready var _appearance_anim_node := $Appearance as AnimationPlayer

onready var _player_node := $'/root/Level/Player' as Area2D # Player
onready var _end_credits_node := $'/root/Level/EndCredits' as EndCredits


func _process(_delta: float) -> void:
    if _is_ray_shooting:
        #warning-ignore:UNSAFE_METHOD_ACCESS
        _player_node.ext_camera_shake('shake')


func _on_BadEnding_area_entered(_player: Area2D) -> void: # Player
    _appearance_anim_node.play('run')


func _start_ray_anim() -> void:
    _is_ray_shooting = true
    _laser_shot_ray_node.set_collision_disabled(false)
    _laser_shot_ray_node.show()
    _laser_shooting_audio_node.play()


func _end_ray_anim() -> void:
    _is_ray_shooting = false
    _laser_shot_ray_node.set_collision_disabled(true)
    _laser_shot_ray_node.hide()
    _laser_shooting_audio_node.stop()


func _on_Appearance_animation_finished(_anim_name: String) -> void:
    _ship_node.hide()
    _end_credits_node.end_screen()
