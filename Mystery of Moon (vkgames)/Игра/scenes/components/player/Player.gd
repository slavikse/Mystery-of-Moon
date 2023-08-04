extends Area2D
class_name Player

enum GameOverType { COSMOS, METEOR, SAND_DEATH, BURN, TENTACLE, LASER }

const FLY_MAX_UP_HEIGHT_SPEED := 400.0
const UP_HEIGHT_SPEED_STEP := 4.0
const FIRST_UP_HEIGHT_SPEED := UP_HEIGHT_SPEED_STEP * 3.0
const DOWN_HEIGHT_SPEED_STEP := 5.0
const BEAM_UPWARD_ACCELERATION := 4.3
const BUBBLE_UPWARD_ACCELERATION := 8.0
const BUFFER_UPWARD_DECELERATION := 2.0

const BODY_CENTERING_X := 50.0
const BODY_CENTERING_Y := 18.0
const _POSITION_Y_SAVE_OFFSET := 5.0

const MAX_RIGHT_SPEED := 200.0
const RIGHT_SPEED_STEP := 3.0
const FIRST_RIGHT_SPEED := RIGHT_SPEED_STEP * 4.0
const RIGHT_DECELERATION := RIGHT_SPEED_STEP * 0.1
const GROUND_DECELERATION := RIGHT_SPEED_STEP * 0.8 # < 1.0

const FUEL_MAX := 1.0
const FUEL_CONSUMPTION := 0.08
const FUEL_POSITION_UP := 681.2 # hack
const FUEL_POSITION_DOWN := 683.2 # hack
const SHIELD_FUEL_CONSUMPTION := 0.04

const JUMP_MAX_UP_HEIGHT_SPEED := 300.0
const JUMP_UPWARD_ACCELERATION := 40.0
const JUMP_RIGHT_SPEED_ACCELERATION := 50.0
const JUMP_TEMPO_ACCELERATION := 60.0

const JUMPING_GAMEPLAY_SWITCH_TIME := 0.05
const CAMERA_ZOOM_CUSTOM_MIN := Vector2(0.6, 0.6)
const CAMERA_ZOOM_CUSTOM_MAX := Vector2(0.8, 0.8)
const CAMERA_OFFSET_CUSTOM := Vector2(0, 200)
const CAMERA_SHAKE := 4.0

const SCRAPS_QUANTITY := 1
const _PUZZLE_NUMBERS_FOR_BAD_ENDING := 7 # из 9 пазлов
const _ADDED_ABILITY_SHIELD_COLOR := '#6d8686'
const _ADDED_ABILITY_RAY_COLOR := '#d66255'

var is_ready := false
var ext_is_airdrop := false
var ext_is_state_restored := false
var is_cosmos_buffer_zone_entered := false

var is_up_height_increase := false
var up_height_speed := -120.0 # ускорение после высадки из корабля.
var upward_acceleration_value := 0.0
var max_up_height_speed := FLY_MAX_UP_HEIGHT_SPEED
var right_speed := FIRST_RIGHT_SPEED
var fuel := FUEL_MAX

var is_tempo_area_entered := false
var is_jumping_gameplay := false
var ext_is_can_jump := false
var tempo_jumps := 0

var is_entered_lifting_up_beam := false
var is_entered_bubble_upward := false
var is_entered_lifting_down_beam := false
var is_entered_space := false
var is_entered_earth := false
var is_entered_sand_death := false
var ext_is_game_over := false
var _game_over_type := -1
var _game_over_counter := 0

var decrease_player_script := preload('./scripts/decrease_player.gd').new()

onready var camera_node := $Camera as Camera2D
onready var camera_bumps_node := $Camera/Bumps as AnimationPlayer
onready var camera_shake_node := $Camera/Shake as AnimationPlayer
onready var camera_death_node := $Camera/Death as AnimationPlayer

onready var body_node := $Body as Polygon2D
onready var body_pusher_anim_node := $Body/PusherAnim as AnimationPlayer
onready var body_player_anim_node := $Body/Player as AnimatedSprite
onready var body_captured_tentacle_node := $Body/CapturedTentacle as Sprite
onready var body_destroy_node := $Body/Destroy as CPUParticles2D
onready var _body_falled_audio_node := $Body/Falled as AudioStreamPlayer
onready var _body_glides_audio_node := $Body/Glides as AudioStreamPlayer
onready var _body_jump_audio_node := $Body/Jump as AudioStreamPlayer
onready var _body_destroyed_audio_node := $Body/Destroyed as AudioStreamPlayer

onready var fuel_node := $Fuel as Fuel
onready var fuel_refill_front_node := $Fuel/RefillFront as CPUParticles2D

onready var recovery_recover_front_node := $Recovery/RecoverFront as CPUParticles2D
onready var recovery_refill_front_node := $Recovery/RefillFront as CPUParticles2D

onready var energy_shield_node := $EnergyShield as EnergyShield
onready var _added_ability_front_node := $AddedAbility/AddedAbilityFront as CPUParticles2D
onready var _added_ability_node := $AddedAbility/AddedAbility as CPUParticles2D
onready var _added_ability_absorb_anim_node := $AddedAbility/AddedAbility/Absorb as AnimationPlayer
onready var _alert_node := $Alert as CanvasLayer
onready var control_manager_node := $ControlManager as ControlManager

onready var menu_node := $Menu as Menu
onready var menu_puzzles_node := $Menu/OptionsContainer/Background2/PuzzlesMenu as PuzzlesMenu
onready var _ship_node := $'/root/Level/Ship' as Node2D # Ship
onready var _scraps_node := $'/root/Level/Scraps' as Scraps


func _ready() -> void:
    menu_node.show()
    fuel_node.show()
    is_ready = true

    if ext_is_state_restored:
        ext_player_restore()

    _to_display_spheres_in_pause_menu()


func _process(delta: float) -> void:
    if not ext_is_airdrop:
        return

    if not ext_is_game_over:
        takeoff()

    tempo_area_entered()
    acceleration_up()

    if _game_over_type != GameOverType.TENTACLE:
        movement_up_down(delta)

    movement_right(delta)

    if ext_is_game_over:
        energy_shield_node.deactivate()
        control_manager_node.ext_energy_shield_active = false
    else:
        fuel_node.external_apply_fuel_quantity(fuel, is_up_height_increase)
        energy_shield(delta)
        decrease_fuel_quantity(delta)
        _camera_bumps()

        if fuel <= 0.0:
            fuel = 0.0
            jumping_gameplay(true)

        if is_entered_space:
            game_over(int(GameOverType.COSMOS))
        elif is_entered_sand_death:
            game_over(int(GameOverType.SAND_DEATH))

    if is_entered_space:
        decrease_player_script.external_decrease_player(delta, body_node, fuel_node)

    switch_camera_zoom()


func _to_display_spheres_in_pause_menu() -> void:
    menu_node.tree.paused = false

    var timer := Timer.new()
    timer.autostart = true
    timer.wait_time = 0.01
    #warning-ignore:RETURN_VALUE_DISCARDED
    timer.connect('timeout', self, "_tree_paused_timeout", [timer])
    add_child(timer)


func _tree_paused_timeout(timer: Timer) -> void:
    timer.queue_free()
    menu_node.tree.paused = true


func ext_restore_state() -> void:
    ext_is_state_restored = true
    ext_is_airdrop = true

    if is_ready:
        ext_player_restore()


# Новые поля в ext_player_state после релиза проверять на существование.
func ext_player_restore() -> void:
    _alert_node.hide()
    _ship_node.hide()

    is_up_height_increase = false
    is_entered_lifting_up_beam = false
    is_entered_bubble_upward = false
    is_entered_lifting_down_beam = false
    is_entered_space = false
    is_entered_earth = false
    is_entered_sand_death = false
    ext_is_game_over = false

    position = Vector2(GC.ext_player_state.position)
    is_jumping_gameplay = bool(GC.ext_player_state.is_jumping_gameplay)
    up_height_speed = float(GC.ext_player_state.up_height_speed)
    upward_acceleration_value = float(GC.ext_player_state.upward_acceleration_value)
    right_speed = float(GC.ext_player_state.right_speed)

    fuel = float(GC.ext_player_state.fuel)
    fuel_node.show()
    fuel_node.scale = Vector2.ONE
    fuel_node.ext_quantity_node.scale = Vector2(GC.ext_player_state.ext_quantity_node_scale)
    fuel_node.external_apply_fuel_quantity(fuel, is_up_height_increase)
    fuel_node.ext_flame_node.show()

    recovery_recover_front_node.emitting = true
    recovery_refill_front_node.emitting = true

    camera_node.current = true
    body_node.scale = Vector2.ONE
    body_player_anim_node.show()
    show()

    control_manager_node.ext_is_takeoff = false
    control_manager_node.ext_energy_shield_enabled = bool(GC.ext_player_state.ext_energy_shield_enabled)

    if control_manager_node.ext_energy_shield_enabled:
        menu_node.show_sphere('shield')

    puzzles_restore()

    GC.is_the_end = bool(GC.ext_player_state.is_the_end)
    menu_node.shown_options_restart() # Зависит от GC.is_the_end

    control_manager_node.ext_set_state()


func puzzles_restore() -> void:
    menu_puzzles_node.puzzles_hide()

    for puzzle_number in GC.puzzles_state:
        menu_puzzles_node.puzzle_show(int(puzzle_number))

    _calc_bad_ending()


func _calc_bad_ending() -> void:
    #warning-ignore:UNSAFE_PROPERTY_ACCESS
    GC.is_bad_ending = len(GC.puzzles_state) >= _PUZZLE_NUMBERS_FOR_BAD_ENDING and control_manager_node.ext_energy_shield_enabled


func save_game() -> void:
    GC.ext_save_game({
        "position": Vector2(position[0], position[1] - _POSITION_Y_SAVE_OFFSET),
        "is_jumping_gameplay": is_jumping_gameplay,
        "up_height_speed": up_height_speed,
        "upward_acceleration_value": upward_acceleration_value,
        "right_speed": right_speed,
        "fuel": fuel,
        "ext_quantity_node_scale": fuel_node.ext_quantity_node.scale,
        "ext_energy_shield_enabled": control_manager_node.ext_energy_shield_enabled,
        "is_the_end": GC.is_the_end,
    })

    menu_node.shown_options_restart()


func takeoff() -> void:
    is_up_height_increase = fuel > 0.0 and control_manager_node.ext_is_takeoff


func tempo_area_entered() -> void:
    if is_tempo_area_entered and is_jumping_gameplay:
        tempo_jumps += 1
        ext_is_can_jump = true


func acceleration_up() -> void:
    if upward_acceleration_value > 0.0:
        upward_acceleration_value -= UP_HEIGHT_SPEED_STEP

        if upward_acceleration_value < 0.0:
            upward_acceleration_value = 0.0

        up_height_speed += upward_acceleration_value

        if up_height_speed > max_up_height_speed:
            up_height_speed = max_up_height_speed
            upward_acceleration_value = 0.0

    if is_entered_lifting_up_beam:
        upward_acceleration_value += BEAM_UPWARD_ACCELERATION

    if is_entered_bubble_upward:
        upward_acceleration_value += BUBBLE_UPWARD_ACCELERATION

    elif is_cosmos_buffer_zone_entered:
        control_manager_node.ext_is_takeoff = false
        upward_acceleration_value = 0.0

        if not is_entered_space:
            up_height_speed -= BUFFER_UPWARD_DECELERATION


func movement_up_down(delta: float) -> void:
    var movement_side := 'down'

    if is_up_height_increase or is_entered_space or ext_is_can_jump:
        up_height_speed += UP_HEIGHT_SPEED_STEP

        if up_height_speed > max_up_height_speed and not is_entered_space:
            up_height_speed = max_up_height_speed

        position.y -= up_height_speed * delta
        movement_side = 'up'

    elif not is_entered_earth:
        up_height_speed -= DOWN_HEIGHT_SPEED_STEP

        if up_height_speed > 0:
            position.y -= up_height_speed * delta
            movement_side = 'up'
        else:
            position.y += -1 * up_height_speed * delta
            movement_side = 'down'

    movement_up_down_fuel_hack(movement_side)

    if is_entered_earth:
        body_player_anim_node.animation = 'up'
    else:
        body_player_anim_node.animation = movement_side


func movement_up_down_fuel_hack(movement_side: String) -> void:
    if movement_side == 'down':
        fuel_node.position[1] = FUEL_POSITION_DOWN
    else:
        fuel_node.position[1] = FUEL_POSITION_UP

    if is_entered_earth:
        fuel_node.position[1] = FUEL_POSITION_UP


func movement_right(delta: float) -> void:
    if not is_up_height_increase or is_entered_space:
        if right_speed > 0.0:
            right_speed -= RIGHT_DECELERATION

    elif right_speed < MAX_RIGHT_SPEED:
        right_speed += RIGHT_SPEED_STEP

    if is_entered_earth:
        right_speed -= GROUND_DECELERATION

    if right_speed < GROUND_DECELERATION:
        right_speed = 0.0

    elif right_speed > MAX_RIGHT_SPEED:
        right_speed = MAX_RIGHT_SPEED

    position.x += right_speed * delta

    var not_is_playing := not _body_falled_audio_node.is_playing() and not _body_glides_audio_node.is_playing()

    if is_entered_earth and right_speed > 0.0 and not_is_playing:
        _body_glides_audio_node.play()


func energy_shield(delta: float) -> void:
    if control_manager_node.ext_energy_shield_enabled:
        if control_manager_node.ext_energy_shield_active and fuel > 0.0:
            fuel -= SHIELD_FUEL_CONSUMPTION * delta
            energy_shield_node.activate()
        else:
            energy_shield_node.deactivate()


func decrease_fuel_quantity(delta: float) -> void:
    if is_up_height_increase and not is_jumping_gameplay:
        fuel -= FUEL_CONSUMPTION * delta


func ext_jump() -> void:
    if ext_is_can_jump:
        var tempo := (tempo_jumps + 1) * JUMP_TEMPO_ACCELERATION
        upward_acceleration_value = JUMP_UPWARD_ACCELERATION + tempo
        right_speed = JUMP_RIGHT_SPEED_ACCELERATION + tempo
        body_pusher_anim_node.play('push')
        _body_jump_audio_node.play()


func fuel_refill() -> void:
    fuel_node.ext_is_fuel_replenishment = true
    fuel = FUEL_MAX
    fuel_refill_front_node.emitting = true


func game_over(type: int) -> void:
    _game_over_type = type

    if type == int(GameOverType.METEOR):
        camera_death_node.play('meteor')
        body_player_anim_node.hide()
        fuel_node.hide()
        body_destroy_node.emitting = true
        _body_destroyed_audio_node.play()
        _create_scraps()

    elif type == int(GameOverType.SAND_DEATH):
        camera_death_node.play('sand_death')

    elif type == int(GameOverType.COSMOS):
        camera_death_node.play('cosmos')

    elif type == int(GameOverType.TENTACLE):
        is_up_height_increase = false
        up_height_speed = 0.0
        upward_acceleration_value = 0.0
        right_speed = 0.0
        fuel_node.stop_bubbles_anim()

    elif type == int(GameOverType.LASER): # Камера трясётся при выстреле с корабля.
        body_player_anim_node.hide()
        fuel_node.hide()
        body_destroy_node.emitting = true
        _body_destroyed_audio_node.play()
        _create_scraps()

    ext_is_game_over = true
    #fix: включало двигатель при возобновлении игры
    control_manager_node.ext_is_takeoff_current_for_cosmos_buffer = false

    if type != int(GameOverType.TENTACLE):
        _alert_node.show()

    is_up_height_increase = false
    upward_acceleration_value = 0.0

    GC.ext_ads()


func _create_scraps() -> void:
    var scraps := _scraps_node.create_scraps(SCRAPS_QUANTITY,
        Vector2(_get_global_body_position_x(), _get_global_body_position_y()))

    for scrap in scraps:
        _scraps_node.call_deferred('add_child', scrap)


func ext_camera_shake(anim_name: String) -> void:
    camera_shake_node.play(anim_name)


func _on_Death_animation_finished(anim_name: String) -> void:
    if anim_name == 'final_tentacle':
        # В даннои случае это признак концовки, чтобы камера больше не двигалась.
        ext_is_airdrop = false
    else:
        #warning-ignore:RETURN_VALUE_DISCARDED
        GC.ext_restore_saved_game()


func jumping_gameplay(is_jumping: bool) -> void:
    is_jumping_gameplay = is_jumping
    control_manager_node.ext_set_state()

    if is_jumping:
        max_up_height_speed = JUMP_MAX_UP_HEIGHT_SPEED
    else:
        max_up_height_speed = FLY_MAX_UP_HEIGHT_SPEED


func _camera_bumps() -> void:
    if is_entered_earth and right_speed > 0.0:
        camera_bumps_node.play('bumps')
    else:
        camera_bumps_node.play('RESET')


func switch_camera_zoom() -> void:
    if is_jumping_gameplay:
        camera_node.zoom = camera_node.zoom.linear_interpolate(CAMERA_ZOOM_CUSTOM_MIN, JUMPING_GAMEPLAY_SWITCH_TIME)
        camera_node.offset = camera_node.offset.linear_interpolate(CAMERA_OFFSET_CUSTOM, JUMPING_GAMEPLAY_SWITCH_TIME)
    else:
        camera_node.zoom = camera_node.zoom.linear_interpolate(CAMERA_ZOOM_CUSTOM_MAX, JUMPING_GAMEPLAY_SWITCH_TIME)
        camera_node.offset = camera_node.offset.linear_interpolate(Vector2.ZERO, JUMPING_GAMEPLAY_SWITCH_TIME)


func _get_global_body_position_x() -> float:
    return body_node.get_global_position()[0] + BODY_CENTERING_X


func _get_global_body_position_y() -> float:
    return body_node.get_global_position()[1] + BODY_CENTERING_Y


func _on_Player_area_entered(area: Area2D) -> void:
    if area is MeteorLaunch:
        (area as MeteorLaunch).meteor_launch()

    if area is Boost:
        var boost_node := area as Boost

        if boost_node.external_boost_type == int(Boost.BoostType.Fuel):
            boost_node.start_refuel_animation()
            fuel_refill()
            jumping_gameplay(false)
            (boost_node.get_parent() as FuelCharger).charged()

    if area is CraterDeath2:
        game_over(int(GameOverType.COSMOS))

    if area is LiftingBeam:
        var lifting_beam_node := area as LiftingBeam

        if lifting_beam_node.is_visible():
            if lifting_beam_node.is_crater_death and not lifting_beam_node.is_launch_meteor_in_cosmos:
                is_entered_lifting_down_beam = true
            else:
                is_entered_lifting_up_beam = true
                is_entered_earth = false

    if area is Meteor or area is MeteorInCosmos:
        #warning-ignore:UNSAFE_PROPERTY_ACCESS
        if not area.is_meteor_falled:
            game_over(int(GameOverType.METEOR))

    if area is SavePoint:
        (area as SavePoint).set_save_shadow(_get_global_body_position_y())
        save_game()

    if area is AltarSphere:
        var altar_container_node := (area as AltarSphere).get_parent() as AltarContainer

        if int(altar_container_node.AltarType.ENERGY_SHIELD) == altar_container_node.altar_type:
            control_manager_node.ext_energy_shield_enabled = true
            _configure_added_ability('shield', altar_container_node)
            _calc_bad_ending()

    if area is Puzzle:
        var puzzle_node := area as Puzzle
        puzzle_node.collect()
        menu_puzzles_node.puzzle_show(puzzle_node.number)
        _calc_bad_ending()

    if area is TempoArea:
        is_tempo_area_entered = true

    if area is Ground:
        if not is_entered_lifting_down_beam and not is_entered_lifting_up_beam:
            if is_jumping_gameplay:
                ext_is_can_jump = true

            is_entered_earth = true
            up_height_speed = 0.0
            upward_acceleration_value = 0.0
            _body_falled_audio_node.play()

    if area is SandDeath:
        is_entered_sand_death = true

    if area is CosmosBufferZone:
        is_cosmos_buffer_zone_entered = true

    if area is Cosmos:
        is_entered_space = true
        fuel_node.hide()

    if area is Final:
        (area as Final).insert_scene()

    if area is LaserShotRay:
        game_over(int(GameOverType.LASER))

    if area is AlienTentacles:
        body_node.z_index = 0
        fuel_node.z_index = 0
        (area as AlienTentacles).grab()

    if area is TentacleHook:
        body_captured_tentacle_node.show()
        game_over(int(GameOverType.TENTACLE))


func _configure_added_ability(sphere: String, altar_container_node: AltarContainer) -> void:
    altar_container_node.activation()

    if sphere == 'shield':
        _added_ability_front_node.modulate = _ADDED_ABILITY_SHIELD_COLOR

    elif sphere == 'ray':
        _added_ability_front_node.modulate = _ADDED_ABILITY_RAY_COLOR

    _added_ability_front_node.emitting = true

    _added_ability_node.modulate = _added_ability_front_node.modulate
    _added_ability_node.emitting = true

    _added_ability_absorb_anim_node.stop(true)
    _added_ability_absorb_anim_node.play('absorb')

    menu_node.show_sphere(sphere)


func _on_Player_area_exited(area: Area2D) -> void:
    if area is LiftingBeam:
        var lifting_beam_node := area as LiftingBeam

        if lifting_beam_node.is_visible():
            if lifting_beam_node.is_crater_death and not lifting_beam_node.is_launch_meteor_in_cosmos:
                is_entered_lifting_down_beam = false
            else:
                is_entered_lifting_up_beam = false

    elif area is TempoArea:
        is_tempo_area_entered = false
        ext_is_can_jump = false

    elif area is Ground:
        tempo_jumps = 0
        is_entered_earth = false

    elif area is CosmosBufferZone:
        is_cosmos_buffer_zone_entered = false

        if control_manager_node.ext_is_takeoff_current_for_cosmos_buffer:
            control_manager_node.ext_is_takeoff = true


func _on_Player_body_entered(body: RigidBody2D) -> void:
    if body is Bubble:
        var bubble_node := body as Bubble
        bubble_node.burst()

        is_entered_bubble_upward = true
        is_entered_earth = false


func _on_Player_body_exited(body: RigidBody2D) -> void:
    if body is Bubble:
        is_entered_bubble_upward = false
