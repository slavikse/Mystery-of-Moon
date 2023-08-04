extends Area2D
class_name Final

export(PackedScene) var _BadEndingScene: PackedScene
export(PackedScene) var _GoodEndingScene: PackedScene

const _ENDING_POSITION := Vector2(2000.0, 0.0)
var _is_final_added := false

onready var _menu_node := $'/root/Level/Player/Menu' as Menu

# КОНЦОВКИ. Всего 9 пазлов: 7 на уровне и 2 в метеоритах.
# 1. Плохая концовка - Герой уничтожен лучом - Пазлов >=7 и любая сфера.
# 2. Хорошая концовка - Тентакль хватает в плащ - Иначе.

func insert_scene() -> void:
    GC.is_the_end = true
    _menu_node.shown_options_restart()

    if not _is_final_added:
        _is_final_added = true
        var ending_node: Node2D

        if GC.is_bad_ending:
            ending_node = _BadEndingScene.instance() as Node2D
            ending_node.position = _ENDING_POSITION
        else:
            ending_node = _GoodEndingScene.instance() as Node2D
            ending_node.position = _ENDING_POSITION
            ending_node.position[1] = 300.0

        call_deferred('add_child', ending_node)
