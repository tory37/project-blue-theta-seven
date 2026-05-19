extends Node

# Player
@warning_ignore("unused_signal")
signal player_switched(new_player_index: int)

# Resource Management
@warning_ignore("unused_signal")
signal ap_tracker_moved(new_value: float)
@warning_ignore("unused_signal")
signal resources_updated(player_index: int, currency: int)

# Board Interaction
@warning_ignore("unused_signal")
signal tile_clicked(axial: Vector2i)

# Cards
@warning_ignore("unused_signal")
signal deck_clicked(owner_player_id: int)

# Errors
@warning_ignore("unused_signal")
signal ap_spend_failed(player_index: int)
