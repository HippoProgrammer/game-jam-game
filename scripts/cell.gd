extends Node2D

var controlled_by = "enemy"
var regen = 5 # Regenerated health per second, while state = regen

enum State {no_regen,regen}
var state = State.no_regen

# --- SET IN ready() ---
var max_health
var health
var light
var health_bar

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# --- SET VARIABLES ---
	max_health = get_meta("max_health",500)
	health = max_health
	
	light = $Sprite2D/PointLight2D
	health_bar = $HealthBar
	
	if controlled_by == "player":
		light.color = "1CEE24"
	else:
		light.color = "EE1C24"
	
	_change_health(health,max_health)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if state == State.regen:
		health += regen * delta
		_change_health(health,max_health)
	
	if health <= 0:
		state = State.regen
		
		if controlled_by == "player":
			_virus_capture()
		elif controlled_by == "enemy":
			_player_capture()
		
		health += 1
	
	elif health == max_health:
		state = State.no_regen

func _virus_capture() -> void:
	controlled_by = "enemy"
	light.color = "EE1C24"
	
	state = State.regen
func _player_capture() -> void:
	controlled_by = "player"
	light.color = "1CEE24"
	
	state = State.regen

func _change_health(new: float, max_value: float):
	health_bar.max_value = max_value
	health_bar.value = new

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("Antigens") and controlled_by == "enemy":
		health -= body.get_meta("attack_damage")
		body.queue_free()
			
	if body.is_in_group("Toxins") and controlled_by == "player":
		health -= body.get_meta("attack_damage")
		body.queue_free()
	_change_health(health,max_health)
