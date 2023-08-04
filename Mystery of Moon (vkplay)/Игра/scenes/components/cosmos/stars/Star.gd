extends Sprite

const MIN_SIZE := 1.0
const MAX_SIZE := 1.4
const ANGLE_RAD := 180.0


func _ready() -> void:
    var size := GC.external_get_random_float(MIN_SIZE, MAX_SIZE)
    scale = Vector2(size, size)

    rotation_degrees = GC.external_get_random_float(0, ANGLE_RAD)
