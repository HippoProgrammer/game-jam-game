extends SubViewport

@export var camera_node: Camera2D
@onready var player_node: Node2D = get_tree().get_first_node_in_group("Player")

# Godot functions

func _ready() -> void:
	world_2d = get_tree().root.world_2d
	camera_node.zoom= Vector2(0.075, 0.075)

func _process(_delta: float) -> void:
	if not is_instance_valid(player_node):
		player_node = get_tree().get_first_node_in_group("Player")
		return
	camera_node.global_position = player_node.global_position

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("minimap_toggle") and \
		Events.allowed_actions["toggle_minimap"]:
		Events.minimap_toggle.emit()
		if self.get_parent().visible:
			self.get_parent().visible = false
		else:
			self.get_parent().visible = true

# obligatory pf 🏳️‍🌈
