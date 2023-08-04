extends Area2D
class_name Meteor

const IS_SIMPLE_METEOR := true
const _MIN_SIZE := 2.1
const _MAX_SIZE := 5.9
const _PLAYBACK_SPEED_SLOWED := 2.6

var _size := float(GC.external_get_random_float(_MIN_SIZE, _MAX_SIZE))
var _is_screen_entered := false
var _is_meteor_destroyed := false
# После проигрыша, игрок начинает заново, но кратеры должны остаться если метеор уже упал и не должен быть запущен снова.
var is_meteor_falled := false

onready var _collision_node := $Collision as CollisionPolygon2D
onready var _texture_node := $Texture as Sprite
onready var _fall_anim_node := $Fall as AnimationPlayer
onready var _delay_falled_node := $Fall/DelayFalled as Timer
onready var _fall_path_node := $FallPath as Polygon2D

onready var _lifting_beam_node := $LiftingBeam as LiftingBeam
onready var _destroy_node := $Destroy as CPUParticles2D

onready var _flight_audio_node := $Flight as AudioStreamPlayer2D
onready var _destroyed_audio_node := $Destroyed as AudioStreamPlayer2D

onready var _meteor_container_node := get_parent() as Node2D
onready var _player_node := $'/root/Level/Player' as Area2D # Player


func _ready() -> void:
    hide()
    scale = Vector2(_size, _size)
    _lifting_beam_node.hide()
    _fall_path_node.hide()


func _process(_delta: float) -> void:
    if _is_screen_entered:
        #warning-ignore:UNSAFE_METHOD_ACCESS
        _player_node.ext_camera_shake('low_shake')


func meteor_launch() -> void:
    if not is_meteor_falled and not _is_meteor_destroyed:
        show()
        _fall_anim_node.playback_speed = _size / _PLAYBACK_SPEED_SLOWED
        _fall_anim_node.play('fall')


func destroy() -> void:
    _is_meteor_destroyed = true
    _collision_node.set_deferred('disabled', true)
    _texture_node.hide()
    _fall_anim_node.stop()

    #warning-ignore:UNSAFE_METHOD_ACCESS
    _meteor_container_node.puzzle_show()

    _is_screen_entered = false

    _destroy_node.emitting = true
    _flight_audio_node.stop()
    _destroyed_audio_node.play()


func _on_Meteor_area_entered(area: Area2D) -> void:
    if area is MeteorInCosmos:
        destroy()

    elif not is_meteor_falled and not _is_meteor_destroyed:
        if area is Ground:
            _delay_falled_node.start()


func _on_DelayFalled_timeout() -> void:
    is_meteor_falled = true
    destroy()
    scale = Vector2.ONE

    _lifting_beam_node.show()
    _lifting_beam_node.set_disable_collision(false)

    #warning-ignore:UNSAFE_METHOD_ACCESS
    _player_node.ext_camera_shake('shake')


func _on_VisibilityNotifier_screen_entered() -> void:
    if not is_meteor_falled and not _is_meteor_destroyed:
        _is_screen_entered = true
        _flight_audio_node.play()


func _on_VisibilityNotifier_screen_exited() -> void:
    _is_screen_entered = false


func _on_Meteor_body_entered(body: RigidBody2D) -> void:
    if body is Bubble:
        (body as Bubble).burst()
