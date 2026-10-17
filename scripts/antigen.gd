extends CharacterBody2D

var lifetime = 30 # Max amount of time in seconds that the bullet can exist for
var speed = 750
var bounces: int = 0
const max_bounces: int = 2

func _physics_process(delta):
	position += transform.x * speed * delta
	
	var collision = move_and_collide(transform.x * speed * delta)
	if collision:
		bounces += 1
		if bounces > max_bounces:
			queue_free()
		else:
			rotation = transform.x.bounce(collision.get_normal()).angle()
			
	if lifetime <= 0:
		queue_free()
	else:
		lifetime -= delta
