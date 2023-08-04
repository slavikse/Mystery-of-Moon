extends CanvasLayer
class_name EndCredits

onready var _tree := get_tree() as SceneTree
onready var _end_screen_anim_node := $Background/EndScreen as AnimationPlayer
onready var _final_title_node := $Background/TitlesContainer/FinalTitle as Label
onready var _reset_tips_node := $Background/TitlesContainer/Reset/Tips as Label


func end_screen() -> void:
    # Концовки:
    if GC.is_bad_ending:
        # Плохая: Луч.
        _final_title_node.text = 'Технология сохранения снимком была отключена! Возвращения не будет...'
    else:
        # Хорошая: Плащ.
        _final_title_node.text = 'Вы стали ещё одним жителем Луны!'

    show()
    _end_screen_anim_node.play('end')


func _on_Reset_pressed() -> void:
    GC.ext_delete_save_game_files()
    _tree.quit()


func _on_Reset_mouse_entered() -> void:
    _reset_tips_node.show()


func _on_Reset_mouse_exited() -> void:
    _reset_tips_node.hide()


func _on_Exit_pressed() -> void:
    _tree.quit()
