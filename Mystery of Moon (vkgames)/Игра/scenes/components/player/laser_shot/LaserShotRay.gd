extends Area2D
class_name LaserShotRay

export(bool) var _is_bad_ending := false

var _laser_shot_node: LaserShot
var _is_shooting := false

onready var _collision_node := $Collision as CollisionPolygon2D
onready var _ray_cast_node := $RayCast as RayCast2D
onready var _ray_dust_node := $'/root/Level/RayDust' as CPUParticles2D


func _ready() -> void:
    if not _is_bad_ending:
        _laser_shot_node = $'../../..' as LaserShot


func _physics_process(_delta: float):
    if _is_shooting or (_laser_shot_node and _laser_shot_node.is_shooting and _ray_cast_node.is_colliding()):
        #warning-ignore:UNSAFE_METHOD_ACCESS
        _ray_dust_node.emit(_ray_cast_node.get_collision_point() + Vector2(0, -5))


func _on_LaserShotRay_area_entered(area: Area2D) -> void:
    if area is Meteor:
        (area as Meteor).destroy()

    elif area is MeteorInCosmos:
        (area as MeteorInCosmos).destroy()

    elif area is AlienBody:
        (area as AlienBody).destroy()

    elif area is AlienMob:
        (area as AlienMob).destroy()


func _turn_off_laser() -> void:
    Input.action_release('laser_shot')
    _laser_shot_node.laser_shot(false)


func _on_LaserShotRay_body_entered(body: Node2D) -> void:
    if body is Bubble:
        var bubble_node := body as Bubble
        bubble_node.is_destroyed = true
        bubble_node.burst()


func set_collision_disabled(is_disabled: bool) -> void:
    _is_shooting = not is_disabled
    _collision_node.set_deferred('disabled', is_disabled)
