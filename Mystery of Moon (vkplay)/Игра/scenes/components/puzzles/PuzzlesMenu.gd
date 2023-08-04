extends Node2D
class_name PuzzlesMenu

onready var _puzzles_menu_items := get_children()


func puzzles_hide() -> void:
    for puzzle_index in len(_puzzles_menu_items):
        _puzzles_menu_items[puzzle_index].lock_show()


func puzzle_show(number: int) -> void:
    if not _puzzles_menu_items:
        _puzzles_menu_items = get_children()

    _puzzles_menu_items[number - 1].lock_hide()
