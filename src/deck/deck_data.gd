class_name DeckData
extends Resource

@export var cards: Array[CardData] = []

func _init():
	cards = []

func add_card(card):
	cards.append(card)

func remove_card(card):
	if card in cards:
		cards.erase(card)