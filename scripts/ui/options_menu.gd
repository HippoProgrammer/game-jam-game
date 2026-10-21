extends CanvasLayer

var buttons = []
var button_index = 0
var open_for_frame = false

@export var return_node_path: NodePath
@onready var buttons_group = $Buttons
@onready var button_indicator = $SelectedButtonIndicator
@onready var master_volume: HSlider = $Buttons/MasterVolume/_effects_scale_bar
@onready var music_volume: HSlider = $Buttons/MusicVolume/_effects_scale_bar
@onready var sfx_volume: HSlider = $Buttons/SFXVolume/_effects_scale_bar
@onready var pause_menu: CanvasLayer = get_tree().get_first_node_in_group("PauseMenu")
@onready var minimap = get_tree().get_first_node_in_group("Minimap")

# Godot functions

func _ready() -> void:
	hide()
	for child in buttons_group.get_children():
		if child.is_in_group("Buttons"):
			buttons.append(child)
	
	master_volume.value = Events.master_volume
	music_volume.value = Events.music_volume
	sfx_volume.value = Events.sfx_volume
	
	if Events.meme_SFX == true:
		$Buttons/_meme_SFX.text = "Meme Sound Effects: On"
	else:
		$Buttons/_meme_SFX.text = "Meme Sound Effects: Off"
	
	master_volume.value_changed.connect(Events._change_master_volume)
	music_volume.value_changed.connect(Events._change_music_volume)
	sfx_volume.value_changed.connect(Events._change_sfx_volume)

func _process(_delta: float) -> void:
	if visible:
		if get_tree().paused == false:
			get_tree().paused = true
		
		button_indicator.position.y = buttons[button_index].global_position.y
		
		if Input.is_action_just_pressed("ui_down") or Input.is_action_just_pressed("ui_right"):
			# Move button selector down
			button_index += 1
			
			if button_index > len(buttons) - 1:
				button_index -= len(buttons)
			
		if Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed("ui_left"):
			# Move button selector up
			button_index -= 1
			
			if button_index < 0:
				button_index += len(buttons)
			
			button_indicator.position.y = buttons[button_index].global_position.y
		
		if Input.is_action_just_pressed("escape") and open_for_frame: # Needed to prevent instant returning to game
			if get_node(return_node_path).name != "PauseMenu":
				_back()
			else:
				hide()
				minimap.show()
				get_tree().paused = false
		if Input.is_action_just_pressed("ui_accept") and open_for_frame:
			call(buttons[button_index].name)
			
		open_for_frame = true
	else:
		open_for_frame = false

# User functions

func _back() -> void:
	hide()
	get_node(return_node_path).show()

func _meme_SFX() -> void:
	if Events.meme_SFX:
		Events.meme_SFX = false
		$Buttons/_meme_SFX.text = "Meme Sound Effects: Off"
	else:
		Events.meme_SFX = true
		$Buttons/_meme_SFX.text = "Meme Sound Effects: On"

# obligatory pf 🏳️‍🌈
