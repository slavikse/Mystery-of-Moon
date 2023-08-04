extends Polygon2D
class_name Fuel

export(PackedScene) var _BubbleScene: PackedScene

const FUEL_REPLENISHMENT_STEP := 0.4
const FUEL_REPLENISHMENT_STEP_UP_MULT := 0.05

var ext_is_fuel_replenishment := false

onready var ext_quantity_node := $Quantity as Polygon2D
onready var _quantity_replenishment_audio_node := $Quantity/Replenishment as AudioStreamPlayer
onready var _quantity_refill_audio_node := $Quantity/Refill as AudioStreamPlayer
#warning-ignore:UNUSED_CLASS_VARIABLE
onready var ext_flame_node := $Flame as Node2D
onready var _flame_bubbles_initiator_anim_node := $Flame/BubblesInitiator as AnimationPlayer
onready var _flame_bubble_spawn_node := $Flame/BubbleSpawn as Position2D
onready var _flame_hisses_audio_node := $Flame/Hisses as AudioStreamPlayer

onready var _lifting_beams_bubbles_node := $'/root/Level/LiftingBeams/Bubbles' as Node2D


func _process(_delta: float) -> void:
    if not is_visible():
        stop_bubbles_anim()


func external_apply_fuel_quantity(fuel: float, is_up_height_increase: bool) -> void:
    if fuel == 0.0:
        ext_quantity_node.hide()
    else:
        ext_quantity_node.show()

        if ext_is_fuel_replenishment:
            ext_quantity_node.scale[1] += FUEL_REPLENISHMENT_STEP * FUEL_REPLENISHMENT_STEP_UP_MULT
        else:
            ext_quantity_node.scale[1] += FUEL_REPLENISHMENT_STEP

        if ext_quantity_node.scale[1] > fuel:
            ext_is_fuel_replenishment = false
            ext_quantity_node.scale[1] = fuel
            _quantity_replenishment_audio_node.stop()

    if is_up_height_increase:
        run_bubbles_anim()
    else:
        stop_bubbles_anim()

    if ext_is_fuel_replenishment and not _quantity_replenishment_audio_node.is_playing():
        _quantity_replenishment_audio_node.play()
        _quantity_refill_audio_node.play()


func run_bubbles_anim() -> void:
    _flame_bubbles_initiator_anim_node.play('create')

    if not _flame_hisses_audio_node.is_playing():
        _flame_hisses_audio_node.play()


func stop_bubbles_anim() -> void:
    _flame_bubbles_initiator_anim_node.play('RESET')
    _flame_hisses_audio_node.stop()


func _create_bubble_anim() -> void:
    var bubble_node := _BubbleScene.instance() as Bubble
    bubble_node.position = _flame_bubble_spawn_node.global_position
    bubble_node.bubble_type = int(bubble_node.BubbleType.FUEL)
    _lifting_beams_bubbles_node.add_child(bubble_node)
