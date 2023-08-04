extends Area2D
class_name Ground


func _on_Ground_body_entered(body: RigidBody2D) -> void:
    if body is Bubble:
       (body as Bubble).burst()

    elif body is Scrap:
        var scrap := body as Scrap
        scrap.put(scrap)
