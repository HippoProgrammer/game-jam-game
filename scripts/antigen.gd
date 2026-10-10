extends CharacterBody2D

var speed = 750
var bounces: int = 0
const max_bounces: int = 2

func _physics_process(delta):
	position += transform.x * speed * delta
	
	var collision = move_and_collide(transform.x * speed * delta)
	if collision:
		bounces += 1
		if bounces > 2:
			queue_free()
		else:
			rotation = transform.x.bounce(collision.get_normal()).angle()
