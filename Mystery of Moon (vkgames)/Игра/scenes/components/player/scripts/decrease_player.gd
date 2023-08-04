extends Node

const DECREASE_RATIO := 2.0


func external_decrease_player(delta: float, body_node: Node2D, fuel_node: Fuel) -> void:
    var reduction_value := Vector2(DECREASE_RATIO, DECREASE_RATIO) * delta
    body_node.scale -= reduction_value
    fuel_node.scale -= reduction_value * 2.0

    if body_node.scale < Vector2.ZERO:
        body_node.scale = Vector2.ZERO

    if fuel_node.scale < Vector2.ZERO:
        fuel_node.scale = Vector2.ZERO
