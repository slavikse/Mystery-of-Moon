extends CanvasLayer
class_name ControlManager

var ext_is_takeoff := false
var ext_is_takeoff_current_for_cosmos_buffer := false

#warning-ignore:UNUSED_CLASS_VARIABLE
var ext_energy_shield_enabled := false
#warning-ignore:UNUSED_CLASS_VARIABLE
var ext_energy_shield_active := false

onready var _menu_button_node := $Menu as Button
onready var _takeoff_button_node := $Takeoff as Button
onready var _jumping_button_node := $Jumping as Button
onready var _shield_button_node := $Shield as Button

onready var _menu_node := $'../Menu' as CanvasLayer # Menu
onready var _player_node := $'/root/Level/Player' as Area2D # Player


func _process(_delta: float) -> void:
    #warning-ignore:UNSAFE_PROPERTY_ACCESS
    if _player_node.ext_is_game_over:
        _menu_button_node.hide()
        _takeoff_button_node.hide()
        _jumping_button_node.hide()
        _shield_button_node.hide()
        return

    #warning-ignore:UNSAFE_PROPERTY_ACCESS
    if _menu_node.is_menu_showed:
        _menu_button_node.hide()
        _takeoff_button_node.hide()
        _jumping_button_node.hide()
        _shield_button_node.hide()
    else:
        ext_set_state()

    #warning-ignore:UNSAFE_PROPERTY_ACCESS
    if _player_node.is_jumping_gameplay:
        #warning-ignore:UNSAFE_PROPERTY_ACCESS
        _jumping_button_node.disabled = not _player_node.ext_is_can_jump

    # Признак того, что топливо закончилось.
    #warning-ignore:UNSAFE_PROPERTY_ACCESS
    _shield_button_node.disabled = _player_node.is_jumping_gameplay

    #warning-ignore:UNSAFE_PROPERTY_ACCESS
    if ext_energy_shield_enabled and not _menu_node.is_menu_showed:
        _shield_button_node.show()
    else:
        _shield_button_node.hide()


func set_visible_up_buttons(is_visible: bool) -> void:
    if not is_visible:
        _takeoff_button_node.hide()
        _jumping_button_node.hide()


func _on_Takeoff_button_down() -> void:
    ext_is_takeoff = true
    ext_is_takeoff_current_for_cosmos_buffer = true


func _on_Takeoff_button_up() -> void:
    ext_is_takeoff = false
    ext_is_takeoff_current_for_cosmos_buffer = false


func _on_Jumping_button_down() -> void:
    #warning-ignore:UNSAFE_METHOD_ACCESS
    _player_node.ext_jump()


func _on_Menu_button_down() -> void:
    #warning-ignore:UNSAFE_METHOD_ACCESS
    _menu_node.pause_switcher()

    #warning-ignore:UNSAFE_PROPERTY_ACCESS
    if _menu_node.is_menu_showed:
        _menu_node.show()
    else:
        _menu_node.hide()


func _on_Shield_button_down() -> void:
    ext_energy_shield_active = true


func _on_Shield_button_up() -> void:
    ext_energy_shield_active = false


func ext_set_state() -> void:
    _menu_button_node.show()
    _shield_button_node.show()

    #warning-ignore:UNSAFE_PROPERTY_ACCESS
    if _player_node.is_jumping_gameplay:
        _takeoff_button_node.hide()
        _jumping_button_node.show()
    else:
        _takeoff_button_node.show()
        _jumping_button_node.hide()
