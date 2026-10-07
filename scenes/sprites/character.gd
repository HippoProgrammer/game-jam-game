extends Sprite2D

# --- MOVEMENT ---

var speed = 400
var angle_deg = 0 # store angle at start

func _process(delta):
	var moving = true

	# hopefully self explanatory
	if Input.is_action_pressed("ui_up") and Input.is_action_pressed("ui_right"):
		angle_deg = 45
	elif Input.is_action_pressed("ui_up") and Input.is_action_pressed("ui_left"):
		angle_deg = 315
	elif Input.is_action_pressed("ui_down") and Input.is_action_pressed("ui_right"):
		angle_deg = 135
	elif Input.is_action_pressed("ui_down") and Input.is_action_pressed("ui_left"):
		angle_deg = 225
	elif Input.is_action_pressed("ui_up"):
		angle_deg = 0
	elif Input.is_action_pressed("ui_right"):
		angle_deg = 90
	elif Input.is_action_pressed("ui_down"):
		angle_deg = 180
	elif Input.is_action_pressed("ui_left"):
		angle_deg = 270
	else:
		moving = false

	if moving:
		var velocity = Vector2.UP.rotated(deg_to_rad(angle_deg)) * speed
		position += velocity * delta

# obligatory pf 🏳️‍🌈
