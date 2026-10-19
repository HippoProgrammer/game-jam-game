extends Node2D

@onready var character = $CharacterBody2D

# --- VARIABLES ---
var rand : float


# import toxins
var toxin_scene = preload("res://scenes/enemy_stuff/toxin.tscn")

@onready var toxin_spawner = $CharacterBody2D/ToxinSpawner

# stats and meta
@onready var max_health = get_meta("max_health")
@onready var max_glucose = get_meta("max_glucose")
@onready var health = max_health
@onready var glucose = max_glucose
@onready var movement_speed = get_meta("movement_speed")
var movement_delta: float

# attack
var attack_timer: Timer
@onready var reload = get_meta("attack_reload")
@onready var attack_damage = get_meta("attack_damage")

# target the player
@onready var player_character = get_tree().get_first_node_in_group("Player")


# state
enum State {idle, spotted, attack, dying}
var state := State.idle
#enum Target_type {player, cell}
@onready var target := _get_target()


# get navigation agent and raycast
@onready var nav: NavigationAgent2D = $CharacterBody2D/NavigationAgent2D
@onready var raycast: RayCast2D = $CharacterBody2D/LOS

# cloning
var probability_health_change = 100

# health bar
@onready var health_bar: ProgressBar = $CharacterBody2D/HealthBar


# Godot functions

func _ready() -> void:
	attack_timer = Timer.new()
	attack_timer.wait_time = reload
	attack_timer.autostart = true
	attack_timer.one_shot = false
	attack_timer.timeout.connect(_attack.bind())
	add_child(attack_timer)
	
	nav.velocity_computed.connect(Callable(_on_velocity_computed))
	_change_health(health, max_health)

func _physics_process(delta: float) -> void:
	state = _check_state()
	if state == State.spotted:
		_spotted(delta)
	if state == State.attack:
		attack_timer.paused = false
	else:
		attack_timer.paused = true
	
	#if (state != State.idle or state != State.dying) and target != null:
		#look_at(target.global_position) 
	look_at(target.global_position) 
	character.move_and_slide()
# --- USER FUNCTIONS ---

func _change_health(new: float, max_value: float):
	health_bar.max_value = max_value
	health_bar.value = new

func _check_state() -> State:
	if state == State.dying:
		return State.dying
	elif _check_attack():
		return State.attack
	elif _check_los():
		if not attack_timer.paused:
			attack_timer.paused = true
		return State.spotted
	else:
		if not attack_timer.paused:
			attack_timer.paused = true
		return State.idle


# then we can just derive behavoiur from here, ie. state idle has its own distinct behavoiur from attack...

# attack

func _check_attack() -> bool:
	if target == null:
		return false
	if global_position.distance_to(target.global_position) > get_meta("attack_range"):
		return false
	if not get_meta("needs_los"):
		return true

	raycast.target_position = raycast.to_local(target.global_position)
	raycast.force_raycast_update()
	return raycast.is_colliding() and raycast.get_collider().is_in_group("Player")

func _attack() -> void:
	var toxin = toxin_scene.instantiate()
	#print(target)
	get_parent().add_child(toxin)
	toxin.global_transform = toxin_spawner.global_transform
	toxin.set_meta("attack_damage",attack_damage)
	toxin.set_meta("shooter",toxin.get_path_to(self))

func _check_los() -> bool:
	if target == null:
		return false
	if global_position.distance_to(target.global_position) > get_meta("los_range"):
		return false

	if not get_meta("needs_los"):
		return true

	raycast.target_position = raycast.to_local(target.global_position)
	raycast.force_raycast_update()
	return raycast.is_colliding() and raycast.get_collider().is_in_group("Player")

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

# i don't actually think this is necessary
func _on_velocity_computed(safe_velocity: Vector2) -> void: #https://docs.godotengine.org/en/stable/tutorials/navigation/navigation_using_navigationagents.html
	character.global_position += safe_velocity * get_physics_process_delta_time()

func _duplicate_self() -> void:
	# Make an animation, add that here
	
	var new_enemy = duplicate()
	if randf() * 100 <= probability_health_change:
		rand = randf_range(0.9,1.2)
		new_enemy.set_meta("max_health",get_meta("max_health")*rand)
		new_enemy.set_meta("scale",new_enemy.get_meta("scale")*rand)
		new_enemy.scale *= rand
	get_parent().call_deferred("add_child",new_enemy)



func _die() -> void:
	state = State.dying
	
	var mat := $CharacterBody2D/Sprite2D.material as ShaderMaterial
	var tween = create_tween()
	tween.tween_property(mat, "shader_parameter/progress", 1.0, 0.6)
	await tween.finished
	queue_free()

func _on_hitbox_body_entered(body: Node2D) -> void:
	if state == State.dying:
		return
	
	if body.is_in_group("Antigens"):
		health -= body.get_meta("attack_damage")
		_change_health(health,max_health)
	if health <= 0:
		Events.enemy_died_sound.emit()
		_die()
  
func _ext_heal(amount:float, delta):
	health += amount*delta

func _get_target() -> Node2D:
	var closest_cell = get_closest_cell()
	if closest_cell == null:
		return player_character
	elif global_position.distance_squared_to(closest_cell.global_position) < global_position.distance_squared_to(player_character.global_position):
		return closest_cell
	else:
		return player_character

func get_closest_cell() -> Node2D:
	var closest: Node2D = null
	var closest_dist := INF # apparently you can do this...

	for cell in get_tree().get_nodes_in_group("cells"):
		var distance := global_position.distance_squared_to(cell.global_position)
		if distance < closest_dist and not cell.controlled_by == "enemy":
			closest_dist = distance
			closest = cell
	if closest_dist != INF:
		return closest
	else:
		return null



# --- SAVING ---
func save() -> Dictionary:
	var save_dict = {
		"filename": get_scene_file_path(),
		"parent": get_tree().current_scene.get_path_to(get_parent()),
		"pos_x": position.x,
		"pos_y": position.y,
		"rotation": rotation,
		"scale_x": scale.x,
		"scale_y": scale.y,
		"body_x": character.position.x,
		"body_y": character.position.y,
		"health": health,
		"max_health": max_health,
		"glucose": glucose,
		"max_glucose": max_glucose,
		"movement_speed": movement_speed,
		"attack_damage": attack_damage,
		"reload": reload,
	}

	return save_dict

func load_data(data: Dictionary) -> void:
	rotation = data["rotation"]
	scale = Vector2(data["scale_x"], data["scale_y"])
	character.position = Vector2(data["body_x"], data["body_y"])
	health = data["health"]
	max_health = data["max_health"]
	glucose = data["glucose"]
	max_glucose = data["max_glucose"]
	movement_speed = data["movement_speed"]
	attack_damage = data["attack_damage"]
	reload = data["reload"]

	attack_timer.wait_time = reload
	_change_health(health, max_health)
  
# obligatory pf 🏳️‍🌈
