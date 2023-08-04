extends Area2D
class_name MeteorInCosmos

const _MIN_SIZE := 2.1
const _MAX_SIZE := 3.9
const _PLAYBACK_SPEED_SLOWED := 5.0
const _DECREASE_TEXTURE_SIZE := Vector2(0.2, 0.2)

var _is_puzzle_inside := false
var _is_cosmos := false
var is_meteor_falled := false

onready var _collision_node := $Collision as CollisionPolygon2D
onready var _texture_node := $Texture as Sprite
onready var _burst_bubble_node := $BurstBubble as Particles2D
onready var _burst_meteor_node := $BurstMeteor as Particles2D
onready var _rise_anim_node := $Rise as AnimationPlayer

onready var _puzzle_container_node := $PuzzleContainer as Node2D
onready var _puzzle_collision_node := $PuzzleContainer/Puzzle/Collision as CollisionPolygon2D
onready var _puzzle_lift_anim_node := $PuzzleContainer/Puzzle/Lift as AnimationPlayer

onready var _destroyed_audio_node := $Destroyed as AudioStreamPlayer2D


func _ready() -> void:
    var _size := float(GC.external_get_random_float(_MIN_SIZE, _MAX_SIZE))
    scale = Vector2(_size, _size)
    _rise_anim_node.playback_speed = _size / _PLAYBACK_SPEED_SLOWED


func _process(delta: float) -> void:
    if _is_cosmos and not is_meteor_falled:
        _texture_node.scale -= _DECREASE_TEXTURE_SIZE * delta

        if _texture_node.scale < Vector2.ZERO:
            _texture_node.scale = Vector2.ZERO


func set_puzzle_inside(is_puzzle_inside: bool) -> void:
    _is_puzzle_inside = is_puzzle_inside

    if _is_puzzle_inside:
        _puzzle_collision_node.set_deferred('disabled', true)
        _puzzle_container_node.hide()
    else:
        _puzzle_container_node.queue_free()


func _meteor_anim_reset_state() -> void:
    is_meteor_falled = false
    _collision_node.set_deferred('disabled', false)

    _is_cosmos = false
    _texture_node.scale = Vector2.ONE
    _texture_node.show()


func _on_MeteorInCosmos_area_entered(area: Area2D) -> void:
    #warning-ignore:UNSAFE_PROPERTY_ACCESS
    if 'IS_SIMPLE_METEOR' in area and area.IS_SIMPLE_METEOR: # is Meteor
        destroy()

    elif area is Cosmos:
        _is_cosmos = true


func _on_MeteorInCosmos_body_entered(body: RigidBody2D) -> void:
    if body is Bubble:
        (body as Bubble).burst()


func destroy() -> void:
    is_meteor_falled = true
    _collision_node.set_deferred('disabled', true)
    _texture_node.hide()

    _burst_bubble_node.emitting = true
    _burst_meteor_node.emitting = true
    _destroyed_audio_node.play()

    _puzzle_show()


func _puzzle_show() -> void:
    if _is_puzzle_inside:
        _puzzle_collision_node.set_deferred('disabled', false)
        _puzzle_container_node.scale = Vector2.ONE / scale
        _puzzle_container_node.show()

        _rise_anim_node.stop()
        _puzzle_lift_anim_node.play('top')
