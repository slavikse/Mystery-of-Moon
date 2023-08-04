extends Node2D

const EXTERNAL_SCREEN_WIDTH := 1920
const EXTERNAL_SCREEN_HEIGHT := 1080
const _LEVELS_FILE_NAME := "user://mystery_of_moon.pixsynt"
const _PUZZLES_FILE_NAME := "user://mystery_of_moon_puzzles.pixsynt"

#enum ExtDeviceType { PC, MOBILE }
enum EndingType { NONE, VERY_GOOD_ENDING, GOOD_ENDING, BAD_ENDING, VERY_BAD_ENDING }

#warning-ignore:UNUSED_CLASS_VARIABLE
#export(ExtDeviceType) var ext_device_type := ExtDeviceType.MOBILE

var random := RandomNumberGenerator.new()
var ext_player_state: Dictionary = {}
var puzzles_state: Array = []
var is_game_restored := false

#warning-ignore:UNUSED_CLASS_VARIABLE
var is_the_end := false
#warning-ignore:UNUSED_CLASS_VARIABLE
var is_bad_ending := false
var ending_type := int(EndingType.NONE)

#warning-ignore:UNUSED_CLASS_VARIABLE
onready var _menu_timer_node := $MenuTimer as Timer

onready var _hello_luna_node := $'/root/Level/HelloLuna' as HelloLuna
onready var _menu_node := $'/root/Level/Player/Menu' as Menu


func _ready() -> void:
    if ext_restore_saved_game():
        _hello_luna_node.ext_destroy()

    restore_saved_puzzles()
    _menu_node.show_puzzles_collected()


func _on_MenuTimer_timeout() -> void:
    if not is_game_restored:
        _menu_node.pause_switcher()


#func _on_ShareWithFriends_pressed() -> void:
#    var message := "'Я играю в #Лунный_Путь! #PixSynt'"
#    var attachments := "'https://vk.com/app8205035'"
#    JavaScript.eval("externalWallPost(" + message + "," + attachments + ")")
#
#
#func _on_InviteFriendsToGame_pressed() -> void:
#    JavaScript.eval("externalShowInviteBox()")


#func get_js_params() -> void:
#    var window = JavaScript.get_interface("window")
#    if window and (window.deviceType == 'pc_mail_games' or window.deviceType == 'pc'):
#        pass


func ext_restore_saved_game() -> bool:
    var file := File.new() as File
    is_game_restored = false

    if file.file_exists(_LEVELS_FILE_NAME):
        #warning-ignore:RETURN_VALUE_DISCARDED
        file.open(_LEVELS_FILE_NAME, File.READ)
        #warning-ignore:UNSAFE_CAST
        var save_data := str2var(file.get_as_text()) as Dictionary
        file.close()

        if save_data:
            is_game_restored = true
            ext_player_state = save_data
            #warning-ignore:UNSAFE_METHOD_ACCESS
            ($'/root/Level/Player' as Area2D).ext_restore_state() # Player

    return is_game_restored


func ext_save_game(save_data: Dictionary) -> void:
    var file := File.new() as File
    #warning-ignore:RETURN_VALUE_DISCARDED
    file.open(_LEVELS_FILE_NAME, File.WRITE)
    file.store_string(var2str(save_data))
    file.close()


func restore_saved_puzzles() -> void:
    var file := File.new() as File

    if file.file_exists(_PUZZLES_FILE_NAME):
        #warning-ignore:RETURN_VALUE_DISCARDED
        file.open(_PUZZLES_FILE_NAME, File.READ)
        #warning-ignore:UNSAFE_CAST
        var save_data := str2var(file.get_as_text()) as Array
        file.close()

        if save_data:
            puzzles_state = save_data


func save_puzzles(number: int) -> void:
    if not puzzles_state.has(number):
        puzzles_state.append(number)

    var file := File.new() as File
    #warning-ignore:RETURN_VALUE_DISCARDED
    file.open(_PUZZLES_FILE_NAME, File.WRITE)
    file.store_string(var2str(puzzles_state))
    file.close()


func ext_delete_save_game_files() -> void:
    var dir := Directory.new()
    #warning-ignore:RETURN_VALUE_DISCARDED
    dir.remove(_LEVELS_FILE_NAME)
    #warning-ignore:RETURN_VALUE_DISCARDED
    dir.remove(_PUZZLES_FILE_NAME)


func external_get_random_float(from: float, to: float) -> float:
    random.randomize()
    return random.randf_range(from, to)


func external_get_random_int(from: int, to: int) -> int:
    random.randomize()
    return random.randi_range(from, to)


func external_round_to_decimal(value: float, digits: int) -> float:
    var numbers := pow(10, digits)
    return round(value * numbers) / numbers


func ext_ads() -> void:
    JavaScript.eval("externalShowAds()")
