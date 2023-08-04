extends Node2D


func ext_start_arrival() -> void:
    ($Arrival as AnimationPlayer).play('Arrival')


func external_airdrop_animation() -> void:
    ($Desk/Player as Node2D).hide()
    var player_node := $'/root/Level/Player' as Player
    player_node.ext_is_airdrop = true

    if not player_node.ext_is_state_restored:
        player_node.show()
