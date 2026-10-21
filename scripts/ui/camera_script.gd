extends Camera2D

var max_dist_p2c = 80 
var vector_to_player : Vector2

@onready var player = get_tree().get_first_node_in_group("Player") # If changing player character node, remove old node from player group and add the new one to it

# Godot functions

func _ready() -> void:
	pass # Replace with function body.

func _process(_delta: float) -> void:
	# Camera Movement
	if global_position.distance_to(player.global_position) > max_dist_p2c:
		vector_to_player = (global_position-player.global_position).normalized() # Finds Vector to player, with longest length being 1.0
		global_position = player.global_position + (vector_to_player * max_dist_p2c) # Sets camera to follow behind player

# obligatory pf 🏳️‍🌈
