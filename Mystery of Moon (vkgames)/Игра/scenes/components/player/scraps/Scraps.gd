extends Node2D
class_name Scraps

export(PackedScene) var _ScrapScene: PackedScene


func create_scraps(quantity: int, position_value: Vector2) -> Array:
    var scraps := []

    for i in quantity:
        var scrap_node := _ScrapScene.instance() as Scrap
        scrap_node.position = position_value
        scraps.append(scrap_node)

    return scraps
