extends Area2D
class_name Alien

export(PackedScene) var _BubbleScene: PackedScene
export(bool) var _is_agressive := false
export(bool) var _is_fearful := false
export(bool) var _is_mob := false
export(bool) var _is_mob_with_crater := false

const _MOB_SIZE := Vector2(0.6, 0.22)

var _shot_count := GC.external_get_random_int(6, 10)
var _is_started_hiding := false
var _is_alien_lurked := false

onready var _sprites_anim_node := $Sprites as AnimatedSprite
onready var _alien_lurk_node := $AlienLurk as Area2D
onready var _alien_body_collision_node := $AlienBody/Collision as CollisionPolygon2D
onready var _alien_mob_node := $AlienMob as AlienMob
onready var _alien_jumped_anim_node := $AlienJumped as AnimatedSprite
onready var _alien_take_off_raincoat_audio_node := $AlienJumped/TakeOffRaincoat as AudioStreamPlayer2D
onready var _alien_jumped_lurk_crater_anim_node := $AlienJumped/LurkCrater as AnimationPlayer
onready var _alien_into_crater_audio_node := $AlienJumped/IntoCrater as AudioStreamPlayer2D

onready var _shot_collision_node := $ShotCollision as CollisionPolygon2D
onready var _shot_anim_node := $Shot as AnimationPlayer
onready var _shot_help_audio_node := $ShotHelp as AudioStreamPlayer2D
onready var _bubble_spawn_node := $BubbleSpawn as Position2D
onready var _lifting_beam_node := $LiftingBeam as LiftingBeam

onready var _aliens_bubbles_node := $'/root/Level/Aliens/Bubbles' as Node2D


func _ready() -> void:
    if _is_mob_with_crater:
        _is_mob = true

    if _is_mob:
        _mob_configure()
    else:
        _alien_mob_node.hide()
        _sprites_anim_node.play('idle_left')

    _alien_jumped_anim_node.frame = 0
    _alien_temperament()


func _mob_configure() -> void:
    _alien_body_collision_node.scale = _MOB_SIZE

    _is_agressive = false
    _is_fearful = true

    _sprites_anim_node.hide()
    _alien_jumped_anim_node.hide()
    _alien_mob_node.show()

    if not _is_mob_with_crater:
        _lifting_beam_node.queue_free()


func _alien_temperament() -> void:
    # 1. Нейтральный и Спокойный.
    # 2. Нейтральный и Пугливый.
    # 3. Агрессивный и Пугливый.
    if not _is_agressive:
        _shot_collision_node.queue_free()

    if not _is_fearful:
        _alien_lurk_node.queue_free()


func _on_Alien_area_entered(player: Area2D) -> void: # Player
    if player and not _is_alien_lurked:
        _sprites_anim_node.play('shot')
        _sprites_anim_node.frame = 1
        _shot_help_audio_node.play()


func _on_Sprites_animation_finished() -> void:
    if _sprites_anim_node.animation == 'shot':
        if _shot_count > 0 and not _is_started_hiding:
            _shot()
        elif not _is_started_hiding:
            _hide_in_crater()


func _shot() -> void:
    _shot_count -= 1
    _shot_anim_node.play('shot')


func _on_Shot_animation_finished(_anim_name: String) -> void:
    _sprites_anim_node.play('shot')


func _create_bubble_anim() -> void:
    var bubble_node := _BubbleScene.instance() as Bubble
    bubble_node.bubble_type = int(bubble_node.BubbleType.ALIEN)
    bubble_node.position = _bubble_spawn_node.global_position
    _aliens_bubbles_node.add_child(bubble_node)


func _on_AlienLeft_area_entered(_player: Area2D) -> void: # Player
    _sprites_anim_node.play('idle_left')


func _on_AlienRight_area_entered(_player: Area2D) -> void: # Player
    _sprites_anim_node.play('idle_right')


func _on_AlienLurk_area_entered(_player: Area2D) -> void: # Player
    if _is_fearful and not _is_started_hiding:
        _hide_in_crater()


func _hide_in_crater() -> void:
    _alien_jumped_lurk_crater_anim_node.stop(true)
    _shot_anim_node.stop(true)
    _is_started_hiding = true
    _sprites_anim_node.hide()

    if not _is_alien_lurked:
        if not _is_mob:
            _alien_jumped_anim_node.show()
            _alien_take_off_raincoat_audio_node.play()

        _alien_jumped_anim_node.play('lurk')


func _on_Jumped_animation_finished() -> void:
     if has_mob_exists():
        _is_alien_lurked = true
        _alien_mob_node.show()
        _alien_mob_node.set_collision_disabled(false)

        _alien_jumped_lurk_crater_anim_node.play('lurk_crater')
        _alien_into_crater_audio_node.play()


func has_mob_exists() -> bool:
    return is_instance_valid(_alien_mob_node) and not _alien_mob_node.is_killed


func _on_Crater_animation_finished(_anim_name: String) -> void:
    if has_mob_exists():
        _alien_jumped_anim_node.stop()

        # Может быть удалён когда мобы прыгают в один кратер.
        if is_instance_valid(_lifting_beam_node):
            _lifting_beam_node.particles_run()


func _on_AlienMob_alien_destroy() -> void:
    _alien_jumped_anim_node.stop()
    _alien_jumped_lurk_crater_anim_node.stop()


func destroy() -> void:
    _alien_jumped_lurk_crater_anim_node.stop()

    if _is_mob and has_mob_exists():
        _alien_mob_node.destroy()
    else:
        _hide_in_crater()

    _alien_body_collision_node.queue_free()
