extends Node2D

export(PackedScene) var _BubbleScene: PackedScene

var _self_bubble_index := -1

onready var _initiator_anim_node := $Initiator as AnimationPlayer
onready var _bubbles_node := $Bubbles as Node2D


func run_bubbles_anim(index: int) -> void:
    _self_bubble_index = index
    _initiator_anim_node.play('create')


func stop_bubbles_anim() -> void:
    _initiator_anim_node.play('RESET')


func _create_bubble_anim() -> void:
    var bubble_node := _BubbleScene.instance() as Bubble
    bubble_node.bubble_type = int(bubble_node.BubbleType.CRATER)
    _bubbles_node.add_child(bubble_node)

    if _self_bubble_index == 0:
        bubble_node.inflate_play()
