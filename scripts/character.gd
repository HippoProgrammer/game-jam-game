extends Sprite2D

# --- MOVEMENT ---
var velocity = Vector2(0,0)
var max_speed : float = 800
var time_to_max_speed : float = 0.2
var current_speed : float = 0
var angle_deg = 0 # store angle at start

func _physics_process(delta: float) -> void:
	look_at(get_global_mouse_position()) # Makes the player look at the mouse
	
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

# obligatory pf 🏳️‍🌈
