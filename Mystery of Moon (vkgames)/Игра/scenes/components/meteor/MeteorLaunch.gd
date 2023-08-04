extends Area2D
class_name MeteorLaunch

onready var meteor_node := $'../Meteor' as Area2D # Meteor


func meteor_launch() -> void:
    # warning-ignore:UNSAFE_METHOD_ACCESS
    meteor_node.meteor_launch()
