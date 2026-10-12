extends Node2D

@onready var max_health = get_meta("max_health")
@onready var max_glucose = get_meta("max_glucose")

enum State {idle, spotted, attack}

var state := State.idle
@onready var target = get_tree().get_first_node_in_group("Player")

@onready var nav: NavigationAgent2D = $NavigationAgent2D
@onready var raycast: RayCast2D = $LOS

func _check_los() -> bool:
	if get_meta("needs_los"): # https://www.makeuseof.com/godot-raycast2d-nodes-line-of-sight-detection/
		raycast.target_position = target.global_position
		if raycast.is_colliding(): # if the enemy can see the player
			return false
		else:
			return true
	elif global_position.distance_to(target.global_position) < get_meta("los_range"): # if it doesnt need los, just check how far between them
		return true
	else:
		return false

func _check_attack() -> bool: # similar here; indirect weapons dont need direct sight
	if global_position.distance_to(target.global_position) < get_meta("attack_range"):
		raycast.target_position = target.global_position
		if raycast.is_colliding() and raycast.get_collider() == target:
			print("a")
			return true
		else:
			return false
	else:
		return false

func _check_state() -> State:
	if _check_los():
		return State.spotted
	elif _check_attack():
		return State.attack
	else:
		return State.idle

# then we can just derive behavoiur from here, iestate idle has its own distinct behavoiur from attack...


func _spotted() -> void:
	pass

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	state = _check_state()
	if state == State.spotted:
		_spotted()

# obligatory pf 🏳️‍🌈
