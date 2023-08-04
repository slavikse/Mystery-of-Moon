extends CanvasLayer
class_name ControlManager

var ext_is_takeoff := false
var ext_is_takeoff_current_for_cosmos_buffer := false

var ext_energy_shield_enabled := false
var ext_energy_shield_active := false

#onready var takeoff_node := $Takeoff as Button
#onready var jumping_node := $Jumping as Button
onready var _player_node := $'/root/Level/Player' as Area2D # Player


#func _ready() -> void:
    # if GC.ext_device_type == GC.ExtDeviceType.PC:
    #     set_visible_up_buttons(false)


func _process(_delta: float) -> void:
    #warning-ignore:UNSAFE_PROPERTY_ACCESS
    if _player_node.ext_is_game_over:
        return

    # if GC.ext_device_type == GC.ExtDeviceType.PC:
    #warning-ignore:UNSAFE_PROPERTY_ACCESS
    _has_keyboards_up_buttons_pressed()
    _has_active_energy_shield()

    #warning-ignore:UNSAFE_PROPERTY_ACCESS
    # takeoff_node.disabled = not _player_node.external_is_player_moving

    #warning-ignore:UNSAFE_PROPERTY_ACCESS
    # if _player_node.is_jumping_gameplay:
    #warning-ignore:UNSAFE_PROPERTY_ACCESS
    # jumping_node.disabled = not _player_node.ext_is_can_jump


#func set_visible_up_buttons(is_visible: bool) -> void:
#    if not is_visible:
#        takeoff_node.hide()
#        jumping_node.hide()


func _has_keyboards_up_buttons_pressed() -> void:
    if Input.is_action_just_pressed("movement_up"):
        #warning-ignore:UNSAFE_METHOD_ACCESS
        _player_node.ext_jump()

        #warning-ignore:UNSAFE_PROPERTY_ACCESS
        if not _player_node.is_jumping_gameplay:
            _on_Takeoff_button_down()

    elif Input.is_action_just_released("movement_up"):
        _on_Takeoff_button_up()


func _has_active_energy_shield() -> void:
    if ext_energy_shield_enabled:
        if Input.is_action_just_pressed('energy_shield'):
            ext_energy_shield_active = true

        elif Input.is_action_just_released('energy_shield'):
            ext_energy_shield_active = false


# todo интересная кнопка (большая) для запуска двигателя (анимация?)
func _on_Takeoff_button_down() -> void:
    ext_is_takeoff = true
    ext_is_takeoff_current_for_cosmos_buffer = true


func _on_Takeoff_button_up() -> void:
    ext_is_takeoff = false
    ext_is_takeoff_current_for_cosmos_buffer = false


func _on_Jumping_button_down() -> void:
    #warning-ignore:UNSAFE_METHOD_ACCESS
    _player_node.ext_jump()


# todo при смене кнопок сделать акцент, что геймплей изменился - обучение.
# todo интересная кнопка (большая) для прыжков (анимация?)
#func ext_set_state() -> void:
#    #warning-ignore:UNSAFE_PROPERTY_ACCESS
#    if _player_node.is_jumping_gameplay:
#        takeoff_node.hide()
#        jumping_node.show()
#    else:
#        takeoff_node.show()
#        jumping_node.hide()
