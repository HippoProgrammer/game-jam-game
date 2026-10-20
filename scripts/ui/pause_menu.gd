extends CanvasLayer

var button_index = 0
var paused_for_frame = false

@onready var buttons_group = $Buttons
@onready var buttons = buttons_group.find_children("*")
@onready var button_indicator = $SelectedButtonIndicator
@onready var options_menu: CanvasLayer = get_tree().get_first_node_in_group("options_menu")
@onready var minimap: CanvasLayer = get_tree().get_first_node_in_group("Minimap")

# Godot functions

func _ready() -> void:
	hide()

func _process(_delta: float) -> void:
	if visible:
		if minimap.visible:
			minimap.hide()
		if get_tree().paused == false:
			get_tree().paused = true
		
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
		
		if Input.is_action_just_pressed("escape") and paused_for_frame: # Needed to prevent instant returning to game
				_resume()
		if Input.is_action_just_pressed("ui_accept") and paused_for_frame:
			call(buttons[button_index].name)
			
		paused_for_frame = true
	else:
		paused_for_frame = false

# User functions

func _resume() -> void:
	hide()
	minimap.show()
	get_tree().paused = false

func _options() -> void:
	hide()
	options_menu.show()

func _save_game():
	GameState.save_game()

func _quit_game() -> void:
	get_tree().quit()
