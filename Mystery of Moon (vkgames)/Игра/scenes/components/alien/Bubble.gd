extends RigidBody2D
class_name Bubble

enum BubbleType { CRATER, ALIEN, FUEL }
export(BubbleType) var bubble_type := BubbleType.CRATER

var is_destroyed := false

onready var _collision_node := $Collision as CollisionShape2D
onready var _increase_tween_node := $Increase as Tween
onready var _inflate_audio_node := $Inflate as AudioStreamPlayer2D
onready var _texture_resize_node := $TextureResize as Node2D
onready var _burst_delay_node := $Burst/Delay as Timer
onready var _bursting_audio_node := $Bursting as AudioStreamPlayer2D


func _ready() -> void:
    _interpolate_increase_scale()

    if bubble_type == int(BubbleType.ALIEN):
        inflate_play()


func _interpolate_increase_scale() -> void:
    var target_scale_value := 0.0
    var interpolate_value := 0.0

    if bubble_type == int(BubbleType.ALIEN):
        set_linear_velocity(Vector2(GC.external_get_random_int(-60, -40), GC.external_get_random_int(-50, 50)))
        set_applied_force(Vector2(GC.external_get_random_int(-40, -20), GC.external_get_random_int(-40, 40)))
        target_scale_value = GC.external_get_random_float(0.8, 1.2)
        interpolate_value = 0.4
        _bursting_audio_node.volume_db = -8

    elif bubble_type == int(BubbleType.CRATER):
        set_linear_velocity(Vector2(GC.external_get_random_int(-10, 10), GC.external_get_random_int(-40, -20)))
        set_applied_force(Vector2(GC.external_get_random_int(-3, 3), GC.external_get_random_int(-4, -2)))
        target_scale_value = GC.external_get_random_float(0.8, 1.2)
        interpolate_value = 0.4
        _bursting_audio_node.volume_db = -6

    elif bubble_type == int(BubbleType.FUEL):
        set_linear_velocity(Vector2(GC.external_get_random_int(80, 100), GC.external_get_random_int(500, 600)))
        set_applied_force(Vector2(GC.external_get_random_int(2, 8), GC.external_get_random_int(160, 200)))
        target_scale_value = GC.external_get_random_float(0.3, 0.4)
        _bursting_audio_node.volume_db = -14

    var target_scale := Vector2(target_scale_value, target_scale_value)
    _collision_node.scale = target_scale

    #warning-ignore:RETURN_VALUE_DISCARDED
    _increase_tween_node.interpolate_property(_texture_resize_node, 'scale', Vector2.ZERO,
        target_scale, interpolate_value, Tween.TRANS_LINEAR, Tween.EASE_OUT)
    #warning-ignore:RETURN_VALUE_DISCARDED
    _increase_tween_node.start()


func inflate_play() -> void:
    _inflate_audio_node.play()


func burst() -> void:
    if is_destroyed:
        _collision_node.set_deferred('disabled', true)

    _texture_resize_node.hide()
    _bursting_audio_node.play()
    _burst_delay_node.start()


func _on_Burst_Delay_timeout() -> void:
    queue_free()


func _on_Destroy_timeout() -> void:
    burst()
