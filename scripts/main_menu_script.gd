extends Node2D

var main_game_scene = "res://scenes/main.tscn"

# --- BUTTON STUFF ---
@onready var buttons_group = get_tree().get_first_node_in_group("MMButtonsContainer")
@onready var buttons = buttons_group.find_children("*")
@onready var button_indicator = get_tree().get_first_node_in_group("MMButtonIndicator")
var button_index = 0
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_down") or Input.is_action_just_pressed("ui_right"):
		# Move button selector down
		button_index += 1
		
		if button_index > len(buttons) - 1:
			button_index -= len(buttons)
		
		button_indicator.position.y = buttons[button_index].global_position.y
	if Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed("ui_left"):
		# Move button selector up
		button_index -= 1
		
		if button_index < 0:
			button_index += len(buttons)
		
		button_indicator.position.y = buttons[button_index].global_position.y
	
	if Input.is_action_just_pressed("ui_accept"):
		call(buttons[button_index].name)

func _start_game():
	print("Start Game button pressed")
	get_tree().change_scene_to_file(main_game_scene)
func _options():
	print("Options button pressed")
func _quit_game():
	print("Quit Game button pressed")
	get_tree().quit() # Quits game
