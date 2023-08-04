extends Node2D

const MIN_SIZE := 1.2
const MAX_SIZE := 1.6

onready var _blink_delay_node := $BlinkDelay as Timer
onready var _blink_anim_node := $Blink as AnimationPlayer


func _ready() -> void:
    var size := GC.external_get_random_float(MIN_SIZE, MAX_SIZE)
    scale = Vector2(size, size)

    _blink_delay_node.start(GC.external_get_random_int(1, 3))


func _on_BlinkDelay_timeout() -> void:
    _blink_anim_node.play('blink')
