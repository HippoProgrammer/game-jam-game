extends Sprite2D

var speed = 400
var angular_speed = PI


func _process(delta):
	var velocity = Vector2.ZERO
	if Input.is_action_pressed("ui_up"):
		velocity = Vector2.UP.rotated(deg_to_rad(0)) * speed
	elif Input.is_action_pressed("ui_down"):
		velocity = Vector2.UP.rotated(deg_to_rad(180)) * speed
	elif Input.is_action_pressed("ui_left"):
		velocity = Vector2.UP.rotated(deg_to_rad(270)) * speed
	elif Input.is_action_pressed("ui_right"):
		velocity = Vector2.UP.rotated(deg_to_rad(90)) * speed

	position += velocity * delta
