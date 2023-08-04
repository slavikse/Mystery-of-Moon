extends Area2D
class_name LiftingBeam

export(bool) var is_puzzle_inside := false
export(bool) var is_crater_death := false
export(bool) var is_launch_meteor_in_cosmos := false

const _COLOR_RED := '#ff4646'

onready var _collision_node := $Collision as CollisionPolygon2D
onready var _bubble_particles_node := $BubbleParticles as BubbleParticles
onready var _meteor_in_cosmos_node := $MeteorInCosmos as MeteorInCosmos


func _ready() -> void:
    if is_puzzle_inside and not is_launch_meteor_in_cosmos:
        is_puzzle_inside = false
        print('Кратер без запуска метеора не может содержать внутри пазл!')

    _meteor_in_cosmos_node.set_puzzle_inside(is_puzzle_inside)
    _meteor_in_cosmos_node.hide()

    if is_crater_death and not is_launch_meteor_in_cosmos:
        _bubble_particles_node.stop()
    else:
        _bubble_particles_node.run()

    if is_launch_meteor_in_cosmos:
        _meteor_in_cosmos_node.show()
    else:
        _meteor_in_cosmos_node.queue_free()


func _on_CraterDeath_area_entered(_area: Area2D) -> void:
    _bubble_particles_node.modulate = _COLOR_RED
    _bubble_particles_node.set_bubbles_modulate(_COLOR_RED)


func particles_run() -> void:
    is_crater_death = false
    _bubble_particles_node.run()


func set_disable_collision(is_disabled: bool) -> void:
    _collision_node.set_deferred('disabled', is_disabled)
