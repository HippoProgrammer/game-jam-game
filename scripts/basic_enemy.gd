extends Node2D

@export var data: enemy_data

var health = data.max_health
var glucose = data.max_glucose

enum State {idle, spotted, attack}

var state := State.idle
var target = get_tree().get_first_node_in_group("Player")

@onready var nav: NavigationAgent2D = $NavigationAgent2D
@onready var raycast: RayCast2D = $LOS

func _check_los() -> bool:
	if data.needs_los: # https://www.makeuseof.com/godot-raycast2d-nodes-line-of-sight-detection/
		raycast.target_position = target.global_position()
		if raycast.is_colliding():
			return false
		else:
			return true
	elif global_position.distance_to(target.global_position) < data.los_range:
		return true
	else:
		return false

func _check_attack() -> bool:
	if global_position.distance_to(target.global_position) < data.attk_range:
		if data.attk_direct:
			raycast.target_position = target.global_position()
			if raycast.is_colliding():
				return false
			else:
				return true
		else:
			return true
	else:
		return false

func _check_state() -> State:
	if _check_los():
		return State.spotted
	elif _check_attack():
		return State.attack
	else:
		return State.idle


func _ready() -> void:
	$Sprite2D.texture = data.texture
	$CollisionShape2D.shape = data.collision_shape
