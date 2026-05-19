class_name Deck
extends Resource

@export var cards: Array[Card] = []

func _init():
	cards = []

func add_card(card):
	cards.append(card)

func remove_card(card):
	if card in cards:
		cards.erase(card)