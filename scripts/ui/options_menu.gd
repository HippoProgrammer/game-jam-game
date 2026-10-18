extends CanvasLayer

@onready var buttons_group = $Buttons
@onready var buttons = buttons_group.find_children("*")
@onready var button_indicator = $SelectedButtonIndicator

@onready var effects_scale: HSlider = $Sliders/_effects_scale_bar

@onready var pause_menu: CanvasLayer = get_tree().get_first_node_in_group("PauseMenu")

var button_index = 0
var paused_for_frame = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	effects_scale.value_changed.connect(Events._change_effects_scale)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if visible:
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
				_back()
		if Input.is_action_just_pressed("ui_accept"):
			call(buttons[button_index].name)
			
		paused_for_frame = true
	else:
		paused_for_frame = false

func _back() -> void:
	hide()
	pause_menu.show()
	get_tree().paused = false
func _meme_SFX() -> void:
	if Events.meme_SFX:
		Events.meme_SFX = false
		$Buttons/_meme_SFX.text = "Meme Sound Effects: Off"
	else:
		Events.meme_SFX = true
		$Buttons/_meme_SFX.text = "Meme Sound Effects: On"
