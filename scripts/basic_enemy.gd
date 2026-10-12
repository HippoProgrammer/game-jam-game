extends Node2D

@onready var max_health = get_meta("max_health")
@onready var max_glucose = get_meta("max_glucose")

enum State {idle, spotted, attack}

var state := State.idle
@onready var target = get_tree().get_first_node_in_group("Player")

@onready var nav: NavigationAgent2D = $NavigationAgent2D
@onready var raycast: RayCast2D = $LOS

var movement_speed = get_meta("movement_speed")
var movement_delta: float

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

# then we can just derive behavoiur from here, ie. state idle has its own distinct behavoiur from attack...

func _chase(delta) -> void:
	movement_delta = movement_speed * delta
	nav.set_target_position(target.global_position)

	if NavigationServer2D.map_get_iteration_id(nav.get_navigation_map()) == 0:
		return
	if nav.is_navigation_finished():
		return
	
	var next_path_position: Vector2 = nav.get_next_path_position()
	var new_velocity: Vector2 = global_position.direction_to(next_path_position) * movement_delta

	navigation_agent.set_velocity(new_velocity)

func _spotted(delta) -> void:
	_chase(delta)
	# sound effects, animations etc...
	pass

func _ready() -> void:
	nav.velocity_computed.connect(Callable(_on_velocity_computed))

func _physics_process(delta: float) -> void:
	state = _check_state()
	if state == State.spotted:
		_spotted(delta)

# obligatory pf 🏳️‍🌈
