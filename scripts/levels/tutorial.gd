extends Node2D

@onready var instructor: Label = $CanvasLayer/Instructor
@onready var test1 = $ExampleIcon1/Area2D


# Godot functions

func _ready() -> void:
	tutorial()

# User functions

func show_line(text: String, hold: bool = false, hold_time := 1.5):
	instructor.text = text
	if hold:
		await get_tree().create_timer(hold_time).timeout

func tutorial() -> void:
	await show_line("Hello there; welcome to our game", true, 3)
	
	Events.allowed_actions["move"] = true
	await show_line("Use WASD to move", true, 2.0)
	await show_line("Move over to the Godot icon")
	await test1.body_entered
	await show_line("Well done!", true, 2.0)
	
	Events.allowed_actions["shoot"] = true
	await show_line("Left click to shoot")
	await Events.player_shoot
	await show_line("Well done!", true, 2.0)
	
	Events.allowed_actions["dash"] = true
	await show_line("Right click to dash")
	await Events.dash_sound
	await show_line("Well done", true, 2.0)
	
	await show_line("Press M to toggle the minimap", false, 2.0)
	await Events.minimap_toggle
	await show_line("Well done", true, 2.0)
	await show_line("You're ready for the real game now!", true, 2.0)
	get_tree().change_scene_to_file("res://scenes/ui/main-menu.tscn")
