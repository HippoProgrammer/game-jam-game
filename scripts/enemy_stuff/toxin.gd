extends CharacterBody2D

var lifetime = 20 # Max amount of time in seconds that the bullet can exist for
var bounces: int = 0
const max_bounces: int = 1

func _physics_process(delta: float) -> void:
	if velocity.x == 0:
		queue_free() # Probably stuck going up and down
	var collision = move_and_collide(velocity * delta)
	if collision:
		bounces += 1
		if bounces > max_bounces:
			queue_free()
		else:
			velocity = velocity.bounce(collision.get_normal())
	if lifetime <= 0:
		queue_free()
	else:
		lifetime -= delta
	
# obligatory pf 🏳️‍🌈
