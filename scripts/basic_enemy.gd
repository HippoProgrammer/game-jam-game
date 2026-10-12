extends Node2D

@onready var max_health = get_meta("max_health")
@onready var max_glucose = get_meta("max_glucose")


enum State {idle, spotted, attack}

var state := State.idle
@onready var target = get_tree().get_first_node_in_group("Player")

@onready var nav: NavigationAgent2D = $NavigationAgent2D
@onready var raycast: RayCast2D = $LOS

@onready var movement_speed = get_meta("movement_speed")
var movement_delta: float

# --- Health Bar ---

@onready var health_bar: ProgressBar = $HealthBar

func _change_health(new: float, max_value: float):
	health_bar.max_value = max_value
	health_bar.value = new


func _check_los() -> bool:
	if global_position.distance_to(target.global_position) > get_meta("los_range"):
		return false

	if not get_meta("needs_los"):
		return true

	raycast.target_position = raycast.to_local(target.global_position)
	raycast.force_raycast_update()
	return raycast.is_colliding() and raycast.get_collider().is_in_group("Player")

func _check_attack() -> bool:
	if global_position.distance_to(target.global_position) > get_meta("attack_range"):
		return false

	
	if not get_meta("needs_los"):
		return true

	raycast.target_position = raycast.to_local(target.global_position)
	raycast.force_raycast_update()
	return raycast.is_colliding() and raycast.get_collider().is_in_group("Player")

func _check_state() -> State:
	if _check_attack():
		return State.attack
	elif _check_los():
		return State.spotted
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
	#var new_velocity: Vector2 = global_position.direction_to(next_path_position) * movement_delta

	nav.set_velocity(global_position.direction_to(next_path_position) * movement_speed)

func _spotted(delta) -> void:
	_chase(delta)
	# sound effects, animations etc..

func _ready() -> void:
	nav.velocity_computed.connect(Callable(_on_velocity_computed))
	_change_health(100.0, 100.0)

func _physics_process(delta: float) -> void:
	state = _check_state()
	if state == State.spotted:
		_spotted(delta)


func _on_velocity_computed(safe_velocity: Vector2) -> void: #https://docs.godotengine.org/en/stable/tutorials/navigation/navigation_using_navigationagents.html
	global_position += safe_velocity * get_physics_process_delta_time()



# obligatory pf 🏳️‍🌈
