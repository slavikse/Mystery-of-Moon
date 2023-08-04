extends Node2D

export(bool) var is_puzzle_inside := false

onready var _meteor_node := $Meteor as Meteor
onready var _puzzle_container_node := $Meteor/PuzzleContainer as Node2D
onready var _puzzle_node := $Meteor/PuzzleContainer/Puzzle as Puzzle
onready var _puzzle_lift_anim_node := $Meteor/PuzzleContainer/Puzzle/Lift as AnimationPlayer


func _ready() -> void:
    if is_puzzle_inside:
        _puzzle_container_node.hide()
        _puzzle_node.set_collision_disabled(true)
    else:
        _puzzle_container_node.queue_free()


func puzzle_show() -> void:
    if is_puzzle_inside:
        if not _meteor_node.is_meteor_falled:
            _puzzle_container_node.scale = Vector2.ONE / _meteor_node.scale

        _puzzle_node.set_collision_disabled(false)
        _puzzle_container_node.show()
        _puzzle_lift_anim_node.play('top')
