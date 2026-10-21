extends Control

var percentage: float
var tween: Tween

@onready var character = get_tree().get_first_node_in_group("Player")
@onready var liquid: TextureRect = $Liquid

# Godot functions

func _ready() -> void:
	character.glucose_changed.connect(_on_glucose_change)

func _process(_delta: float) -> void:
	if not is_instance_valid(character):
		character = get_tree().get_first_node_in_group("Player")
		character.glucose_changed.disconnect(_on_glucose_change) # Just ignore the error here
		character.glucose_changed.connect(_on_glucose_change)
		
# User functions
func _on_glucose_change(new: float, max_value: float) -> void:
	percentage = new/max_value
	if tween:
		tween.kill()
	
	var current: float = liquid.material.get_shader_parameter("water_level_percentage")
	tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_method(apply, current, percentage, 0.4)
	
func apply(value: float) -> void:
	liquid.material.set_shader_parameter("water_level_percentage", value)

# obligatory pf 🏳️‍🌈
