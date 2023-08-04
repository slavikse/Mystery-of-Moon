extends Node2D
class_name BubbleParticles

onready var _lifting_particles_nodes := get_children()


func run() -> void:
    for index in len(_lifting_particles_nodes):
        _lifting_particles_nodes[index].run_bubbles_anim(index)


func stop() -> void:
    for index in len(_lifting_particles_nodes):
        _lifting_particles_nodes[index].stop_bubbles_anim()


func set_bubbles_modulate(color_red: String) -> void:
    for index in len(_lifting_particles_nodes):
        _lifting_particles_nodes[index].get_node('Bubbles').modulate = color_red
