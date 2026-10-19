extends CharacterBody2D

var lifetime = 20 # Max amount of time in seconds that the bullet can exist for
var bounces: int = 0
const max_bounces: int = 2

func _physics_process(delta: float) -> void:
	var collision = move_and_collide(velocity * delta)
	if collision:
		print("bounce")
		bounces += 1
		if bounces > max_bounces:
			queue_free()
		else:
			rotation = transform.x.bounce(collision.get_normal()).angle()
	if lifetime <= 0:
		queue_free()
	else:
		lifetime -= delta
