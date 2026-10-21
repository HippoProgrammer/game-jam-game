extends CharacterBody2D

var antigen_scene = preload("res://scenes/player/antigen.tscn")

@onready var antigen_spawner = $AntigenSpawner
@onready var health_bar = get_tree().get_first_node_in_group("PlayerHealthBar")
@onready var pause_menu = get_tree().get_first_node_in_group("PauseMenu")
@onready var parry_anim = $ParryAnim

var health_bar_inter_frame_time = 0.08
var antigen_speed = 750

# --- PLAYER STATS ---

var max_health: float = 100.0
var health: float = 100.0
var max_glucose: float = 100.0
var glucose: float = 100.0
var glucose_regen: float = 5.0
var attack_damage = 50.0

var ammo: int = 10

signal health_changed(new_health: float, max_health: float)
signal glucose_changed(new_glucose: float, max_glucose: float)

# --- MOVEMENT ---
var max_velocity : float = 400
var time_to_max_velocity : float = 0.2

# --- DASHING ---
var dash_tween: Tween
var is_dashing: bool = false
var dash_speed: float = 2000.0
var dash_duration: float = 0.15
var dash_direction: Vector2 = Vector2.ZERO
var dashing: bool = false
@onready var base_scale = scale
var dash_glucose_use: float = 20.0

var antigen_cooldown_timer = 0
var antigen_cooldown_time = 0.2
var parrying = false

# Godot functions

func _ready() -> void:
	glucose_changed.emit.call_deferred(glucose, max_glucose)
	health_changed.emit.call_deferred(health, max_health)
	parry_anim.hide()

func _physics_process(delta: float) -> void:
	if antigen_cooldown_timer <= 0:
		Events.allowed_actions["shoot"] = true
	else:
		Events.allowed_actions["shoot"] = false
		antigen_cooldown_timer -= delta
	if health <= 0:
		_game_over()
	# --- SHOOTING ---
	if not dashing:
		# Makes the player look at the mouse
		look_at(get_global_mouse_position())
	
	if Input.is_action_just_pressed("left_click") and \
	Events.allowed_actions["shoot"]:
		shoot_antigen()
		antigen_cooldown_timer = antigen_cooldown_time
	
	# Parry
	
	if Input.is_action_just_pressed("parry") and \
	Events.allowed_actions["parry"] and \
	Upgrades.action_upgrades["parry"]:
		parry()


	# --- DASHING ---
	
	if Input.is_action_just_pressed("right_click") and \
	Events.allowed_actions["dash"]:
		dash()
	
	if dashing:
		move_and_slide()
		return
	
	# hopefully self explanatory
	if Events.allowed_actions["move"]:
		if Input.is_action_pressed("ui_up"):
			velocity.y = clamp(velocity.y - (delta/time_to_max_velocity) * max_velocity,-max_velocity,max_velocity)
		if Input.is_action_pressed("ui_down"):
			velocity.y = clamp(velocity.y + (delta/time_to_max_velocity) * max_velocity,-max_velocity,max_velocity)
		if Input.is_action_pressed("ui_left"):
			velocity.x = clamp(velocity.x - (delta/time_to_max_velocity) * max_velocity,-max_velocity,max_velocity)
		if Input.is_action_pressed("ui_right"):
			velocity.x = clamp(velocity.x + (delta/time_to_max_velocity) * max_velocity,-max_velocity,max_velocity)
		
		if not(Input.is_action_pressed("ui_up") or \
		Input.is_action_pressed("ui_down")) or (Input.is_action_pressed("ui_up") and \
		Input.is_action_pressed("ui_down")):
			if velocity.y > 0:
				velocity.y = max(velocity.y - (delta / time_to_max_velocity) * max_velocity, 0)
			elif velocity.y < 0:
				velocity.y = min(velocity.y + (delta / time_to_max_velocity) * max_velocity, 0)
		if not(Input.is_action_pressed("ui_left") or \
		Input.is_action_pressed("ui_right")) or \
		(Input.is_action_pressed("ui_left") and \
		Input.is_action_pressed("ui_right")):
			if velocity.x > 0:
				velocity.x = max(velocity.x - (delta / time_to_max_velocity) * max_velocity, 0)
			elif velocity.x < 0:
				velocity.x = min(velocity.x + (delta / time_to_max_velocity) * max_velocity, 0)
		
	move_and_slide()

func _process(delta: float) -> void:
	var old_glucose := glucose
	var old_health := health
	
	glucose = min(glucose + glucose_regen * delta, max_glucose)
	
	if glucose != old_glucose:
		glucose_changed.emit(glucose, max_glucose)
	if health != old_health:
		health_changed.emit(health, max_health)
	
	if Input.is_action_just_pressed("escape"):
		pause_menu.show()

# User functions

func shoot_antigen():
	Events.player_shoot.emit()

	var direction = (get_global_mouse_position() - global_position).normalized()
	var angles = [0.0]

	if Upgrades.attack_upgrades["triple_antigens"]:
		angles = [-10.0, 0.0, 10.0]

	for angle in angles:
		var antigen = antigen_scene.instantiate()
		owner.add_child(antigen)
		antigen.global_position = antigen_spawner.global_position
		antigen.velocity = direction.rotated(deg_to_rad(angle)) * antigen_speed
		antigen.rotation = antigen.velocity.angle()
		antigen.set_meta("attack_damage", attack_damage)

func dash():
	if dashing:
		return
	elif glucose < dash_glucose_use:
		Events.error_sound.emit()
		return
	
	glucose -= dash_glucose_use
	
	dashing = true
	Events.dash_sound.emit()
	dash_direction = (get_global_mouse_position() - global_position).normalized()

	if dash_tween:
		dash_tween.kill()
	scale = base_scale

	dash_tween = create_tween()
	dash_tween.tween_property(self, "scale", base_scale * Vector2(1.6, 0.5), 0.04)
	dash_tween.tween_interval(dash_duration - 0.04)
	dash_tween.tween_property(self, "scale", base_scale, 0.15)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)
	
	velocity = (get_global_mouse_position()-global_position).normalized() * dash_speed
	max_velocity = max_velocity * dash_speed
	
	health_bar.material = load("res://palette_swap_resources/1_invuln_health_bar_light.tres")
	await get_tree().create_timer(dash_duration/4).timeout
	health_bar.material = load("res://palette_swap_resources/2_invuln_health_bar_full.tres")
	await get_tree().create_timer(dash_duration/2).timeout
	health_bar.material = load("res://palette_swap_resources/3_invuln_health_bar_dark.tres")
	await get_tree().create_timer(dash_duration/4).timeout
	health_bar.material = load("res://palette_swap_resources/0_health_bar.tres")
	
	velocity = velocity / dash_speed
	max_velocity = max_velocity / dash_speed
	
	dashing = false

func get_closest_toxin() -> Node2D:
	var closest: Node2D = null
	var closest_dist := INF # apparently you can do this...

	for toxin in get_tree().get_nodes_in_group("Toxins"):
		var distance = global_position.distance_squared_to(toxin.global_position)
		if distance < closest_dist:
			closest_dist = distance
			closest = toxin
	if closest_dist != INF:
		return closest
	else:
		return null

func parry() -> void:
	var closest_toxin = get_closest_toxin()
	if closest_toxin != null:
		parry_anim.look_at(closest_toxin.global_positio)
	parry_anim.show()
	parrying = true
	parry_anim.play("default")
	await parry_anim.animation_finished
	parrying = false
	parry_anim.hide()

func _game_over() -> void:
	get_tree().quit()

func _on_hitbox_body_entered(body: Node2D) -> void:
	if not dashing and \
	not parrying:
		if body.is_in_group("Toxins"):
			Events.player_take_damage.emit()
			health -= body.get_meta("attack_damage",0)
			body.queue_free()
			_animate_health_bar()


func _animate_health_bar() -> void:
	health_bar.material = load("res://palette_swap_resources/1_health_bar_inside_white.tres")
	await get_tree().create_timer(health_bar_inter_frame_time).timeout
	health_bar.material = load("res://palette_swap_resources/2_health_bar_white.tres")
	health_changed.emit.call_deferred(health, max_health)
	await get_tree().create_timer(health_bar_inter_frame_time).timeout
	health_bar.material = load("res://palette_swap_resources/3_health_bar_outside_white.tres")
	await get_tree().create_timer(health_bar_inter_frame_time).timeout
	health_bar.material = load("res://palette_swap_resources/0_health_bar.tres")
	
func _ext_heal(amount:float, delta):
	health = clamp(health + amount * delta,-max_health,max_health)
	health_changed.emit(health, max_health)

# --- SAVING ---
func save() -> Dictionary:
	var save_dict = {
		"filename": get_scene_file_path(),
		"parent": get_tree().current_scene.get_path_to(get_parent()),
		"pos_x": position.x,
		"pos_y": position.y,
		"rotation": rotation,
		"velocity_x": velocity.x,
		"velocity_y": velocity.y,
		"health": health,
		"max_health": max_health,
		"glucose": glucose,
		"max_glucose": max_glucose,
		"glucose_regen": glucose_regen,
		"attack_damage": attack_damage,
		"ammo": ammo,
	}

	return save_dict

func load_data(data: Dictionary) -> void:
	rotation = data["rotation"]
	velocity = Vector2(data["velocity_x"], data["velocity_y"])
	health = data["health"]
	max_health = data["max_health"]
	glucose = data["glucose"]
	max_glucose = data["max_glucose"]
	glucose_regen = data["glucose_regen"]
	attack_damage = data["attack_damage"]
	ammo = int(data["ammo"])

	health_changed.emit(health, max_health)
	glucose_changed.emit(glucose, max_glucose)

# obligatory pf 🏳️‍🌈
