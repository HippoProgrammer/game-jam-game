extends Node2D

@onready var character = $CharacterBody2D

# --- VARIABLES ---
var rand : float

# import toxins
var toxin_speed = 750
var toxin_scene = preload("res://scenes/enemy_stuff/toxin.tscn")

# stats and meta
@onready var max_health = get_meta("max_health")
@onready var max_glucose = get_meta("max_glucose")
@onready var health = max_health
@onready var glucose = max_glucose
@onready var movement_speed = get_meta("movement_speed")
@onready var attack_range = get_meta("attack_range")
@onready var los_range = get_meta("los_range")
var movement_delta: float

# attack
var attack_timer: Timer
@onready var reload = get_meta("attack_reload")
@onready var attack_damage = get_meta("attack_damage")

# target the player
@onready var player_character = get_tree().get_first_node_in_group("Player")

var target_pos

# state
enum State {idle, spotted, attack, dying}
var state := State.idle
#enum Target_type {player, cell}
@onready var target


# get navigation agent and raycast
@onready var nav: NavigationAgent2D = $CharacterBody2D/NavigationAgent2D
@onready var raycast: RayCast2D = $CharacterBody2D/LOS

# cloning
var probability_health_change = 100

# health bar
@onready var health_bar: ProgressBar = $CharacterBody2D/HealthBar


# Godot functions

func _ready() -> void:
	scale = Vector2(get_meta("scale")/4,get_meta("scale")/4)

	attack_timer = Timer.new()
	attack_timer.wait_time = reload
	attack_timer.autostart = true
	attack_timer.one_shot = false
	attack_timer.timeout.connect(_attack.bind())
	add_child(attack_timer)

	nav.velocity_computed.connect(Callable(_on_velocity_computed))
	_change_health(health, max_health)

func _physics_process(delta: float) -> void:
	target = _get_target()

	state = _check_state()
	if state == State.spotted:
		_chase(delta)
	if state == State.attack:
		attack_timer.paused = false
		var closest_cell = get_closest_cell()
		if closest_cell:
			if closest_cell.global_position.distance_to(player_character.global_position) < 2 * attack_range:
				target_pos = closest_cell.global_position.lerp(player_character.global_position, 0.5) # Find Midpoint
			else:
				var dir_cell_to_player = (player_character.global_position - closest_cell.global_position).normalized()

				if target == player_character && character.global_position.distance_to(closest_cell.global_position) \
					< los_range && closest_cell.global_position.distance_to(character.global_position) < los_range:
					target_pos = player_character.global_position - (dir_cell_to_player * attack_range)

				elif target == closest_cell && character.global_position.distance_to(closest_cell.global_position) \
					 < los_range && closest_cell.global_position.distance_to(character.global_position) < los_range:
					target_pos = closest_cell.global_position + (dir_cell_to_player * attack_range)
			var direction = character.global_position.direction_to(target_pos)
			character.velocity = direction * movement_speed

	else:
		attack_timer.paused = true

	character.move_and_slide()


# --- USER FUNCTIONS ---

func _change_health(new: float, max_value: float):
	health_bar.max_value = max_value
	health_bar.value = new

func _check_state() -> State:
	if state == State.dying:
		return State.dying
	elif _check_attack():
		character.velocity = Vector2(0,0)
		return State.attack
	elif _check_los():
		if not attack_timer.paused:
			attack_timer.paused = true
		return State.spotted
	else:
		if not attack_timer.paused:
			attack_timer.paused = true
		return State.idle

# attack

func _check_attack() -> bool:
	if target == null:
		return false
	if character.global_position.distance_to(target.global_position) > attack_range:
		return false
	if not get_meta("needs_los"):
		return true

	raycast.target_position = raycast.to_local(target.global_position)
	raycast.force_raycast_update()
	return raycast.is_colliding() and \
		(raycast.get_collider().is_in_group("Player") or \
		raycast.get_collider().is_in_group("cells"))

func _attack() -> void:
	var toxin = toxin_scene.instantiate()
	toxin.set_meta("attack_damage",attack_damage)
	get_parent().add_child(toxin)
	toxin.set_meta("shooter",toxin.get_path_to(self))
	toxin.global_position = character.global_position
	toxin.velocity = (target.global_position - character.global_position).normalized() * toxin_speed

func _check_los() -> bool:
	if target == null:
		return false
	if character.global_position.distance_to(target.global_position) > los_range:
		return false

	if not get_meta("needs_los"):
		return true

	raycast.target_position = raycast.to_local(target.global_position)
	raycast.force_raycast_update()
	return raycast.is_colliding() and \
	(raycast.get_collider().is_in_group("Player") or \
	raycast.get_collider().is_in_group("cells"))

func _chase(_delta: float) -> void:
	nav.set_target_position(target.global_position)

	if NavigationServer2D.map_get_iteration_id(nav.get_navigation_map()) == 0:
		character.velocity = Vector2.ZERO
		return
	if nav.is_navigation_finished():
		character.velocity = Vector2.ZERO
		return

	var next_path_position: Vector2 = nav.get_next_path_position()
	var target_direction: Vector2 = character.global_position.direction_to(next_path_position)
	var preferred_velocity: Vector2 = target_direction * movement_speed

	if nav.avoidance_enabled:
		nav.set_velocity(preferred_velocity)
	else:
		character.velocity.x = clamp(preferred_velocity.x,-movement_speed,movement_speed)
		character.velocity.y = clamp(preferred_velocity.y,-movement_speed,movement_speed)

func _on_velocity_computed(safe_velocity: Vector2) -> void:
	character.velocity = safe_velocity


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
	health = clamp(health + amount * delta, -max_health, max_health)

func _get_target() -> Node2D:
	var closest_cell = get_closest_cell()
	if closest_cell:
		if character.global_position.distance_squared_to(closest_cell.global_position) \
			<= character.global_position.distance_squared_to(player_character.global_position) + 80000: # The 80000 makes it more likely to target the enemy
			return closest_cell
		else:
			return player_character
	else:
		return player_character

func get_closest_cell() -> Node2D:
	var closest: Node2D = null
	var closest_dist := INF # apparently you can do this...

	for cell in get_tree().get_nodes_in_group("cells"):
		var distance = character.global_position.distance_squared_to(cell.global_position)
		if distance < closest_dist and not \
		cell.controlled_by == "enemy":
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
