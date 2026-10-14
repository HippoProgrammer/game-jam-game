extends Node2D

var rand : float

@onready var max_health = get_meta("max_health")
@onready var max_glucose = get_meta("max_glucose")

@onready var health = max_health
@onready var glucose = max_glucose

enum State {idle, spotted, attack}
var state := State.idle

@onready var target = get_tree().get_first_node_in_group("Player")

@onready var nav: NavigationAgent2D = $NavigationAgent2D
@onready var raycast: RayCast2D = $LOS

@onready var movement_speed = get_meta("movement_speed")
var movement_delta: float

# --- Cloning ---
var probability_health_change = 100

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
	#print("chasing")
	movement_delta = movement_speed * delta
	nav.set_target_position(target.global_position)
	#print(target)

	if NavigationServer2D.map_get_iteration_id(nav.get_navigation_map()) == 0:
		#print(NavigationServer2D.map_get_iteration_id(nav.get_navigation_map()))
		return
	if nav.is_navigation_finished():
		#print(nav.is_navigation_finished())
		return
	
	var next_path_position: Vector2 = nav.get_next_path_position()
	#print(nav.get_next_path_position())
	#var new_velocity: Vector2 = global_position.direction_to(next_path_position) * movement_delta

	nav.set_velocity(global_position.direction_to(next_path_position) * movement_speed)
	var direction: Vector2 = global_position.direction_to(next_path_position)
	global_position += direction * movement_delta

func _spotted(delta) -> void:
	#print("player spotted")
	_chase(delta)
	# sound effects, animations etc..

func _ready() -> void:
	nav.velocity_computed.connect(Callable(_on_velocity_computed))
	_change_health(health, max_health)

func _physics_process(delta: float) -> void:
	state = _check_state()
	if state == State.spotted:
		_spotted(delta)

func _on_velocity_computed(safe_velocity: Vector2) -> void: #https://docs.godotengine.org/en/stable/tutorials/navigation/navigation_using_navigationagents.html
	global_position += safe_velocity * get_physics_process_delta_time()

func _duplicate_self() -> void:
	# Make an animation, add that here
	
	var new_enemy = duplicate()
	if randf() * 100 <= probability_health_change:
		rand = randf_range(0.9,1.2)
		new_enemy.set_meta("max_health",get_meta("max_health")*rand)
		new_enemy.set_meta("scale",new_enemy.get_meta("scale")*rand)
		new_enemy.scale *= rand
	get_parent().call_deferred("add_child",new_enemy)

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("Antigens"):
		health -= body.get_meta("attack_damage")
		_change_health(health,max_health)
		body.queue_free()
	if health <= 0:
		queue_free()



# obligatory pf 🏳️‍🌈
