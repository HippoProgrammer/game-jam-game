extends Node2D

var controlled_by = "enemy"

var regen = 5 # Regenerated health per second, while state = regen

var friendly_regen = 5.0
var regen_range = 200
@onready var regen_emitter: GPUParticles2D = $RegenEmmiter # maybe use CPU but idk..
@onready var enemy_regen_texture = preload("res://artwork/enemy_stuff/enemy_heal_particle.png")
@onready var player_regen_texture = preload("res://artwork/MainChara/player_heal_particle.png")
var regen_particle_speed = 700
var base_particle_amount = 5

@onready var player = get_tree().get_first_node_in_group("Player")

enum State {no_regen,regen}
var state = State.no_regen

var time_until_regen = 10 # The time in seconds after being hit by an opponent until the cell can regen
var timer_until_regen = time_until_regen

# --- SET IN ready() ---
var max_health
var health
var light
var health_bar

func _ready() -> void:
	regen_emitter.amount = base_particle_amount * (Events.effects_scale/100)
	
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
	regen_entites(controlled_by)

func _virus_capture() -> void:
	controlled_by = "enemy"
	regen_emitter.texture = enemy_regen_texture
	light.color = "EE1C24"
	
	state = State.regen
	timer_until_regen = time_until_regen

func _player_capture() -> void:
	controlled_by = "player"
	regen_emitter.texture = player_regen_texture
	light.color = "1CEE24"
	
	state = State.regen
	timer_until_regen = time_until_regen

func _change_health(new: float, max_value: float):
	health_bar.max_value = max_value
	health_bar.value = new

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("Antigens") and controlled_by == "enemy":
		if state == State.regen:
			timer_until_regen = 0
			state = State.no_regen
		health -= body.get_meta("attack_damage")
		body.queue_free()
			
	if body.is_in_group("Toxins") and controlled_by == "player":
		if state == State.regen:
			timer_until_regen = 0
			state = State.no_regen
			
		health -= body.get_meta("attack_damage")
		body.queue_free()
		
	_change_health(health,max_health)

func regen_entites(controlled_by) -> void:
	
	var target: Node2D = null
	if controlled_by == "player":
		target = player
	else:
		target = get_closest_enemy()
	
	if target != null and global_position.distance_to(target.global_position) < regen_range:
		regen_emitter.look_at(target.global_position)
		# idk how to get the next line to work
		#regen_emitter.lifetime = global_position.distance_to(target.global_position) / 700
		regen_emitter.emitting = true
		#print("regenning")
		#print(target)
		
	else:
		regen_emitter.emitting = false

func get_closest_enemy() -> Node2D:
	var closest: Node2D = null
	var closest_dist := INF # apparently you can do this...

	for enemy in get_tree().get_nodes_in_group("enemies"):
		var distance := global_position.distance_squared_to(enemy.global_position)
		if distance < closest_dist:
			closest_dist = distance
			closest = enemy

	return closest
