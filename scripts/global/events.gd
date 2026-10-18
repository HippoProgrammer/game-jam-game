extends Node

signal enemy_died_sound
signal error_sound
signal dash_sound

var effects_scale: float = 100.0

func _change_effects_scale(new: float) -> void:
	effects_scale = new
	print(effects_scale)
