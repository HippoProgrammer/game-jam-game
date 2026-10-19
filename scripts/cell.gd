extends Node2D

# Variables for Enemy Replication
var enemy_max_health = 100.0
var enemy_max_glucose = 100.0
var enemy_glucose_regen = 0.0
var enemy_health_regen = 0.0
var enemy_movement_speed = 100.0
var enemy_attack_range = 400.0
var enemy_los_range = 800.0
var enemy_scale = 1.0
var enemy_attack_damage = 10.0
var enemy_attack_reload = 2.0

# Percentage chances for mutation
var max_health_mutation_chance =  2.0
var max_glucose_mutation_chance =  2.0
var glucose_regen_mutation_chance =  2.0
var health_regen_mutation_chance =  2.0
var movement_speed_mutation_chance =  2.0
var attack_range_mutation_chance =  2.0
var los_range_mutation_chance =  2.0
var attack_damage_mutation_chance =  2.0
var attack_reload_mutation_chance =  2.0

var controlled_by = "player"

var rand

var regen = 5 # Regenerated health per second, while state = regen

var friendly_regen = 10.0
var regen_range = 200
@onready var regen_emitter: GPUParticles2D = $RegenEmitter # maybe use CPU but idk..
@onready var enemy_regen_texture = preload("res://artwork/enemy_stuff/enemy_heal_particle.png")
@onready var player_regen_texture = preload("res://artwork/MainChara/player_heal_particle.png")
var regen_particle_speed = 700
var base_particle_amount = 2.5
var particle_speed

@onready var player = get_tree().get_first_node_in_group("Player")

enum State {no_regen,regen}
var state = State.no_regen

var time_until_regen = 10 # The time in seconds after being hit by an opponent until the cell can regen
var timer_until_regen = time_until_regen

var virus_cell_attack_mult = 4

var recent_shooter : Node
var previous_collisions = []

var spawn_timer
var spawn_time = 30 # How long it takes for enemies to spawn in seconds

# --- SET IN ready() ---
var max_health
var health
var light
var health_bar

func _ready() -> void:
	spawn_timer = Timer.new()
	spawn_timer.wait_time = spawn_time
	spawn_timer.autostart = true
	spawn_timer.one_shot = false
	spawn_timer.timeout.connect(_mutate_chance.bind())
	add_child(spawn_timer)
	if controlled_by == "player":
		spawn_timer.paused = true
	else:
		spawn_timer.paused = false
	
	regen_emitter.amount = round(base_particle_amount * (Events.effects_scale/100))
	
	# --- SET VARIABLES ---
	max_health = get_meta("max_health",500)
	health = max_health
	
	light = $Sprite2D/PointLight2D
	health_bar = $HealthBar
	
	if controlled_by == "player":
		light.color = "1CEE24"
		regen_emitter.texture = player_regen_texture
	else:
		light.color = "EE1C24"
		regen_emitter.texture = enemy_regen_texture
	
	_change_health(health,max_health)


func _process(delta: float) -> void:
	timer_until_regen += delta
	
	if state == State.regen:
		health += regen * delta
		_change_health(health,max_health)
	
	if health <= 0:
		health = 0.1
		
		if controlled_by == "player":
			_virus_capture()
		elif controlled_by == "enemy":
			_player_capture()
	elif health == max_health:
		state = State.no_regen
	elif timer_until_regen >= time_until_regen:
		state = State.regen
	regen_entites(controlled_by, delta)

func _virus_capture() -> void:
	controlled_by = "enemy"
	regen_emitter.texture = enemy_regen_texture
	light.color = "EE1C24"
	
	state = State.regen
	timer_until_regen = time_until_regen
	
	spawn_timer.paused = false
	
	# Set variables for duplication

func _player_capture() -> void:
	controlled_by = "player"
	regen_emitter.texture = player_regen_texture
	light.color = "1CEE24"
	
	state = State.regen
	timer_until_regen = time_until_regen
	
	spawn_timer.paused = true
	
func _change_health(new: float, max_value: float):
	health_bar.max_value = max_value
	health_bar.value = new

func regen_entites(_controlled_by, delta) -> void:
	var target: Node2D = null
	if _controlled_by == "player":
		target = player
	else:
		target = get_closest_enemy()
	

	if target != null and global_position.distance_to(target.global_position) < regen_range:
		regen_emitter.look_at(target.global_position)
		particle_speed = global_position.distance_to(target.global_position) * 2 / regen_emitter.lifetime 
		
		var mat = regen_emitter.process_material as ParticleProcessMaterial
		if mat:
			mat.set_param_min(ParticleProcessMaterial.PARAM_INITIAL_LINEAR_VELOCITY, particle_speed)
			mat.set_param_max(ParticleProcessMaterial.PARAM_INITIAL_LINEAR_VELOCITY, particle_speed)
		regen_emitter.emitting = true
		
		if controlled_by == "enemy":
			target.get_parent()._ext_heal(friendly_regen,delta)
		else:
			target._ext_heal(friendly_regen,delta)
		
	else:
		regen_emitter.emitting = false

func get_closest_enemy() -> Node2D:
	var closest: Node2D = null
	var closest_dist := INF

	for enemy in get_tree().get_nodes_in_group("enemies"):
		var distance := global_position.distance_squared_to(enemy.global_position)
		if distance < closest_dist:
			closest_dist = distance
			closest = enemy

	return closest

func _mutate_chance() -> void:
	if randf() * 100 < attack_damage_mutation_chance:
		print("Attack Damage Mutation in ",self)
		rand = randf_range(0.9,1.2)
		enemy_attack_damage *= rand
		enemy_scale *= rand
	if randf() * 100 < attack_range_mutation_chance:
		print("Attack Range Mutation in ",self)
		rand = randf_range(0.9,1.2)
		enemy_attack_range *= rand
		enemy_scale *= rand
	if randf() * 100 < attack_reload_mutation_chance:
		print("Attack Reload Mutation in ",self)
		rand = randf_range(0.9,1.2)
		enemy_attack_reload *= rand
		enemy_scale *= rand
	if randf() * 100 < los_range_mutation_chance:
		print("LOS Range Mutation in ",self)
		rand = randf_range(0.9,1.2)
		enemy_los_range *= rand
		enemy_scale *= rand
	if randf() * 100 < health_regen_mutation_chance:
		print("Enemy Health Regen Mutation in ",self)
		if enemy_health_regen != 0:
			rand = randf_range(0.9,1.2)
			enemy_health_regen *= rand
			enemy_scale *= rand
		else:
			rand = randf_range(0,1)
			enemy_health_regen = rand
			enemy_scale *= (1+rand)
	if randf() * 100 < max_health_mutation_chance:
		print("Max Health Mutation in ",self)
		rand = randf_range(0.9,1.2)
		enemy_max_health *= rand
		enemy_scale *= rand
	if randf() * 100 < max_glucose_mutation_chance:
		print("Max Glucose Mutation in ",self)
		rand = randf_range(0.9,1.2)
		enemy_max_glucose *= rand
		enemy_scale *= rand
	if randf() * 100 < glucose_regen_mutation_chance:
		print("Glucose Regen Mutation in ",self)
		if enemy_glucose_regen != 0:
			rand = randf_range(0.9,1.2)
			enemy_glucose_regen *= rand
			enemy_scale *= rand
		else:
			rand = randf_range(0,1)
			enemy_glucose_regen = rand
			enemy_scale *= (1+rand)
	if randf() * 100 < movement_speed_mutation_chance:
		print("Movement Speed Mutation in ",self)
		rand = randf_range(0.9,1.2)
		enemy_movement_speed *= rand
		enemy_scale *= rand
	create_enemy()

func create_enemy() -> void:
	var node = load("res://scenes/enemy_stuff/basic_enemy.tscn").instantiate()
	
	print("Setting Properties")
	node.set_meta("attack_damage",enemy_attack_damage)
	node.set_meta("attack_range",enemy_attack_range)
	node.set_meta("glucose_regen",enemy_glucose_regen)
	node.set_meta("health_regen",enemy_health_regen)
	node.set_meta("movement_speed",enemy_movement_speed)
	node.set_meta("attack_range",enemy_attack_range)
	node.set_meta("los_range",enemy_los_range)
	node.set_meta("scale",enemy_scale)
	node.set_meta("max_health",enemy_max_health)
	node.set_meta("max_glucose",enemy_max_glucose)
	print("Finished Setting Properties")
	
	node.global_position = global_position + Vector2(80,0)
	get_parent().add_child(node)
	

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
		"controlled_by": controlled_by,
		"health": health,
		"max_health": max_health,
		"state": state,
		"timer_until_regen": timer_until_regen,
	}

	return save_dict

func load_data(data: Dictionary) -> void:
	rotation = data["rotation"]
	scale = Vector2(data["scale_x"], data["scale_y"])
	controlled_by = data["controlled_by"]
	max_health = data["max_health"]
	health = data["health"]
	state = (data["state"])
	timer_until_regen = data["timer_until_regen"]

	if controlled_by == "player":
		light.color = "1CEE24"
		regen_emitter.texture = player_regen_texture
	else:
		light.color = "EE1C24"
		regen_emitter.texture = enemy_regen_texture

	_change_health(health, max_health)


func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("Antigens") and is_inside_tree():
		if controlled_by == "enemy":
			if state == State.regen:
				timer_until_regen = 0
				state = State.no_regen
			health -= body.get_meta("attack_damage")
			body.queue_free()
		elif controlled_by == "player":
			health = clamp(health + body.get_meta("attack_damage"),0,max_health)
			body.queue_free()
		
	if body.is_in_group("Toxins") and controlled_by == "player" and is_inside_tree():
		
		if state == State.regen:
			timer_until_regen = 0
			state = State.no_regen
			
		health -= body.get_meta("attack_damage") * virus_cell_attack_mult
		if body.get_node(body.get_meta("shooter")):
			recent_shooter = body.get_node(body.get_meta("shooter"))
		body.queue_free()
		
	_change_health(health,max_health)
