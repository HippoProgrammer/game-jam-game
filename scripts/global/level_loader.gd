extends Node2D

func _ready():
	if GameState.pending_load:
		GameState.pending_load = false
		GameState.load_game()
