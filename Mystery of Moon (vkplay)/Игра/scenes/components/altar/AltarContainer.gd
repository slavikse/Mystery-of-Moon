extends Node2D
class_name AltarContainer

enum AltarType { ENERGY_SHIELD, LASER_SHOT }
export(AltarType) var altar_type := AltarType.ENERGY_SHIELD

var _is_collecting := false

onready var _save_point_shadow_node := $SavePoint/SaveShadow as Node2D
onready var _mouse_click_node := $MouseClick as MouseClick

onready var _altar_sphere_anim_node := $AltarSphere/Sphere as AnimatedSprite
onready var _altar_sphere_collision_node := $AltarSphere/Collision as CollisionPolygon2D
onready var _altar_sphere_collect_anim_node := $AltarSphere/Collect as AnimationPlayer

onready var _altar_node := $Altar as Altar
onready var _altar_hiding_anim_node := $Altar/Hiding as AnimationPlayer
onready var _dust_node := $Altar/Dust as Dust

onready var _player_node := $'/root/Level/Player' as Area2D # Player


func _ready() -> void:
    _save_point_shadow_node.scale[1] = 22.222 # На алтаре точка сохранения уменьшена до 1/x.
    _dust_node.setting(Vector2(-32, 40), Vector2(48, 40))

    if int(AltarType.ENERGY_SHIELD) == altar_type:
        _altar_sphere_anim_node.play('shield')
        _mouse_click_node.playing('right')

    elif int(AltarType.LASER_SHOT) == altar_type:
        _altar_sphere_anim_node.play('ray')
        _mouse_click_node.playing('left')


func _process(_delta: float) -> void:
    if _is_collecting:
        #warning-ignore:UNSAFE_METHOD_ACCESS
        _player_node.ext_camera_shake('middle_shake')
        _dust_node.emitting()


func activation() -> void:
    _altar_node.activation()
    _altar_sphere_collision_node.set_deferred('disabled', true)
    _altar_sphere_collect_anim_node.play('collect')
    _mouse_click_node.showing()


func _on_Collect_animation_finished(_anim_name: String) -> void:
    _is_collecting = true
    _altar_hiding_anim_node.play('hiding')
    #warning-ignore:UNSAFE_METHOD_ACCESS
    _player_node.ext_camera_shake('low_shake')


func _on_Hiding_animation_finished(_anim_name: String) -> void:
    _is_collecting = false
