extends CanvasLayer
class_name Menu

const COLOR_WHITE := '#fff'
const COLOR_GRAY := '#585858'

var _MASTER_SOUND := AudioServer.get_bus_index('Master')
var is_audios_playing := true
var _menu_audio_playback_position := -1.0
var _game_audio_playback_position := -1.0

var is_menu_showed := false

onready var tree := get_tree() as SceneTree
onready var _narration_node := $OptionsContainer/Background2/Narration as Narration

onready var _shield_sphere_node := $OptionsContainer/Background3/PlayerContainer/ShieldSphere as AnimatedSprite
onready var _audios_playing_container_node := $OptionsContainer/Background3/AudiosPlayingContainer as Node2D
onready var _volume_on_node := $OptionsContainer/Background3/AudiosPlayingContainer/AudiosPlaying/VolumeOn as Sprite

onready var _options_restart_node := $OptionsContainer/Options/Restart as Node2D
onready var _toggler_anim_node := $OptionsContainer/Toggler as AnimationPlayer
onready var _reset_tips_node := $OptionsContainer/Options/Reset/Tips as Label

onready var _hover_click_audio_node := $OptionsContainer/Options/HoverClick as AudioStreamPlayer
onready var _menu_switcher_audio_node := $OptionsContainer/MenuSwitcher as AudioStreamPlayer

onready var _menu_audio_node := $Menu as AudioStreamPlayer
onready var _game_audio_node := $Game as AudioStreamPlayer

onready var _control_manager_node := $'../ControlManager' as ControlManager


func _ready() -> void:
    _options_restart_node.hide()
    pause_switcher()

    if not GC.is_game_restored:
        layer = -1

    _menu_audio_node.play()


func shown_options_restart() -> void:
    if GC.is_the_end:
        _options_restart_node.hide()
    else:
        _options_restart_node.show()


func show_sphere(type: String) -> void:
    if type == 'shield':
        _shield_sphere_node.show()
    else:
        print('show_sphere: передан неизвестный параметр')


func pause_switcher(puzzle_number := -1) -> void:
    is_menu_showed = not is_menu_showed

    if is_menu_showed:
        layer = 2 # Чтобы перекрывало титры.
        _actions_releases()
        _toggler_anim_node.play('show')
        tree.paused = true
    else:
        tree.paused = false
        _toggler_anim_node.play('close')

    if tree.paused:
        if puzzle_number > -1:
            _narration_node.show_puzzle_collected(puzzle_number)
    else:
        _narration_node.close()

    playing_audios('pause&game')


func _actions_releases() -> void:
    Input.action_release('movement_up')
    Input.action_release('energy_shield')

    _control_manager_node._on_Takeoff_button_up()
    _control_manager_node.ext_energy_shield_active = false


func playing_audios(type: String) -> void:
    if type == 'clip':
        _menu_audio_playback_position = _menu_audio_node.get_playback_position()
        _menu_audio_node.stop()
        _game_audio_node.play()

    elif type == 'pause&game':
        # Запуск игры и меню.
        if layer == -1 or is_menu_showed:
            _game_audio_playback_position = _game_audio_node.get_playback_position()
            _game_audio_node.stop()
            _menu_audio_node.play(_menu_audio_playback_position)
        else:
            _menu_audio_playback_position = _menu_audio_node.get_playback_position()
            _menu_audio_node.stop()
            _game_audio_node.play(_game_audio_playback_position)

        if layer == -1:
            _menu_audio_node.play()
        elif layer == 2:
            _menu_switcher_audio_node.play()


func _on_Toggler_animation_finished(_anim_name: String) -> void:
    if not is_menu_showed:
        layer = -1


func show_menu() -> void:
    is_menu_showed = true
    Input.action_press('ui_menu')


func _on_option_mouse_entered(option_index: int) -> void:
    _toggle_visible_option(option_index, true)
    _hover_click_audio_node.play()


func _on_option_mouse_exited(option_index: int) -> void:
    _toggle_visible_option(option_index, false)


func _toggle_visible_option(option_index: int, is_visible: bool) -> void:
    var option_name := ''

    if option_index == 0:
        option_name = 'Continue'
    elif option_index == 1:
        option_name = 'Restart'
    elif option_index == 2:
        option_name = 'Exit'
    else:
        print('Ошибка в _toggle_visible_option')

    var option_node := get_node('./OptionsContainer/Options/' + option_name + '/LaserShot_' + str(option_index)) as Sprite

    if is_visible:
        option_node.show()
    else:
        option_node.hide()


func _on_AudiosPlaying_mouse_entered() -> void:
    _audios_playing_container_node.modulate = COLOR_WHITE
    _hover_click_audio_node.play()


func _on_AudiosPlaying_mouse_exited() -> void:
    _audios_playing_container_node.modulate = COLOR_GRAY


func on_AudiosPlaying_pressed() -> void:
    is_audios_playing = not is_audios_playing
    AudioServer.set_bus_mute(_MASTER_SOUND, not is_audios_playing)

    if is_audios_playing:
        _volume_on_node.show()
        _hover_click_audio_node.play()
    else:
        _volume_on_node.hide()


func for_vkgames_audio_playing(is_playing: bool) -> void:
    AudioServer.set_bus_mute(_MASTER_SOUND, not is_playing)


func _on_Continue_pressed() -> void:
    pause_switcher()
    _hover_click_audio_node.play()


func _on_Restart_pressed() -> void:
    #warning-ignore:RETURN_VALUE_DISCARDED
    GC.ext_restore_saved_game()
    #warning-ignore:RETURN_VALUE_DISCARDED
    GC.restore_saved_puzzles()

    show_puzzles_collected()
    pause_switcher()
    _hover_click_audio_node.play()


func _on_Reset_mouse_entered() -> void:
    _reset_tips_node.show()
    _hover_click_audio_node.play()


func _on_Reset_mouse_exited() -> void:
    _reset_tips_node.hide()


func show_puzzles_collected() -> void:
    var puzzles_menu_node := $OptionsContainer/Background2/PuzzlesMenu as PuzzlesMenu
    var puzzles_nodes := puzzles_menu_node.get_children()

    for puzzle_node_index in len(puzzles_nodes):
        var puzzle_index := int(GC.puzzles_state.find(int(puzzle_node_index)))

        if puzzle_index > -1:
            puzzles_menu_node.puzzle_show(GC.puzzles_state[puzzle_index])


func _on_CallFriends_button_down() -> void:
    GC._on_InviteFriendsToGame_pressed()


func _on_ShareFriends_button_down() -> void:
    GC._on_ShareWithFriends_pressed()


func _on_Reset_pressed() -> void:
    GC.ext_delete_save_game_files()
    _on_Exit_pressed()


func _on_Exit_pressed() -> void:
    tree.quit()
