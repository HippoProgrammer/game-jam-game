extends Sprite2D

var antigen_scene = preload("res://scenes/antigen.tscn")

func shoot_antigen():
	var antigen = antigen_scene.instantiate()
	owner.add_child(antigen)
	antigen.global_transform = $AntigenSpawner.global_transform

# --- PLAYER STATS ---

var max_health: float = 100.0
var health: float = 100.0
var max_glucose: float = 100.0
var glucose: float = 100.0
var glucose_regen: float = 5.0

signal health_changed(new_health: float, max_health: float)
signal glucose_changed(new_glucose: float, max_glucose: float)

# --- MOVEMENT ---
var velocity = Vector2(0,0)
var max_speed : float = 800
var time_to_max_speed : float = 0.2
var current_speed : float = 0
var angle_deg = 0 # store angle at start

# --- DASHING ---

var dash_tween: Tween
var is_dashing: bool = false
var dash_speed: float = 2000.0
var dash_duration: float = 0.15
var dash_direction: Vector2 = Vector2.ZERO
var dashing: bool = false
var base_scale: Vector2
var dash_glucose_use: float = 20.0

func _ready() -> void:
	base_scale = scale
	
	glucose_changed.emit.call_deferred(glucose, max_glucose)
	health_changed.emit.call_deferred(health, max_health)

func dash():
	if dashing or glucose < dash_glucose_use:
		return
	
	glucose -= dash_glucose_use
	
	dashing = true
	dash_direction = Vector2.RIGHT.rotated(rotation)

	if dash_tween:
		dash_tween.kill()
	scale = base_scale

	dash_tween = create_tween()
	dash_tween.tween_property(self, "scale", base_scale * Vector2(1.6, 0.5), 0.04)
	dash_tween.tween_interval(dash_duration - 0.04)
	dash_tween.tween_property(self, "scale", base_scale, 0.15)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)

	await get_tree().create_timer(dash_duration).timeout
	dashing = false

func _physics_process(delta: float) -> void:
	# --- SHOOTING ---
	if not dashing:
		look_at(get_global_mouse_position()) # Makes the player look at the mouse
	# @GoldenFootie i think this is irrelevent now...
	#if Input.is_action_just_pressed("left_click"):
	#	add_child(antigen_scene.instantiate())
	
	if Input.is_action_just_pressed("left_click"):
		shoot_antigen()
	
	# --- DASHING ---
	
	if Input.is_action_just_pressed("right_click"):
		dash()
	
	
	if dashing:
		position += dash_direction * dash_speed * delta
		return
	
	# --- MOVEMENT ---
	var moving = true

	# hopefully self explanatory
	if Input.is_action_pressed("ui_up") and Input.is_action_pressed("ui_right"):
		angle_deg = 45
		current_speed = clamp(current_speed + (delta/time_to_max_speed) * max_speed,0,max_speed) # Calculates speed with acceleration
	elif Input.is_action_pressed("ui_up") and Input.is_action_pressed("ui_left"):
		angle_deg = 315
		current_speed = clamp(current_speed + (delta/time_to_max_speed) * max_speed,0,max_speed)
	elif Input.is_action_pressed("ui_down") and Input.is_action_pressed("ui_right"):
		angle_deg = 135
		current_speed = clamp(current_speed + (delta/time_to_max_speed) * max_speed,0,max_speed)
	elif Input.is_action_pressed("ui_down") and Input.is_action_pressed("ui_left"):
		angle_deg = 225
		current_speed = clamp(current_speed + (delta/time_to_max_speed) * max_speed,0,max_speed)
	elif Input.is_action_pressed("ui_up"):
		angle_deg = 0
		current_speed = clamp(current_speed + (delta/time_to_max_speed) * max_speed,0,max_speed)
	elif Input.is_action_pressed("ui_right"):
		angle_deg = 90
		current_speed = clamp(current_speed + (delta/time_to_max_speed) * max_speed,0,max_speed)
	elif Input.is_action_pressed("ui_down"):
		angle_deg = 180
		current_speed = clamp(current_speed + (delta/time_to_max_speed) * max_speed,0,max_speed)
	elif Input.is_action_pressed("ui_left"):
		angle_deg = 270
		current_speed = clamp(current_speed + (delta/time_to_max_speed) * max_speed,0,max_speed)
	else:
		moving = false
		current_speed = 0
		
		
	
	
	
	if moving:
		velocity = Vector2.UP.rotated(deg_to_rad(angle_deg)) * current_speed
		position += velocity * delta

func _process(delta: float) -> void:
	var old_glucose := glucose
	var old_health := health
	
	glucose = min(glucose + glucose_regen * delta, max_glucose)
	
	if glucose != old_glucose:
		glucose_changed.emit(glucose, max_glucose)
	if health != old_health:
		health_changed.emit(health, max_health)


# obligatory pf 🏳️‍🌈
