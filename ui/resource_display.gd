extends MarginContainer

## UI component to display AP and Coins for the active player.

@onready var ap_label = $VBoxContainer/APLabel
@onready var coin_label = $VBoxContainer/CoinLabel
@onready var player_label = $VBoxContainer/PlayerLabel

func _ready():
	# Connect to game state signals
	# In a real project, GameState would be an Autoload.
	# For now we'll assume it's available or we find it in the tree.
	var gs = get_node_or_null("/root/GameState")
	if gs:
		gs.resources_updated.connect(_on_resources_updated)
		gs.player_switched.connect(_on_player_switched)
		
		# Initial update
		_update_display(gs.active_player, gs.player_resources[gs.active_player]["ap"], gs.player_resources[gs.active_player]["coins"])

func _on_resources_updated(player_index: int, ap: int, coins: int):
	if player_index == get_node("/root/GameState").active_player:
		_update_display(player_index, ap, coins)

func _on_player_switched(new_player_index: int):
	var gs = get_node("/root/GameState")
	_update_display(new_player_index, gs.player_resources[new_player_index]["ap"], gs.player_resources[new_player_index]["coins"])

func _update_display(player: int, ap: int, coins: int):
	player_label.text = "Player: " + ("1" if player == 0 else "2")
	ap_label.text = "AP: " + str(ap)
	coin_label.text = "Coins: " + str(coins)
