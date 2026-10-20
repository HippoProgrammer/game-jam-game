extends CharacterBody2D

var lifetime = 20 # Max amount of time in seconds that the bullet can exist for
var bounces: int = 0
const max_bounces: int = 5

func _physics_process(delta: float) -> void:
	var collision = move_and_collide(velocity * delta)
	if collision:
		var collider = collision.get_collider()
		if collider.is_in_group("Antigens"):
			add_collision_exception_with(collider)
			collider.add_collision_exception_with(self)
		else:
			bounces += 1
			if bounces > max_bounces:
				queue_free()
			else:
				velocity = velocity.bounce(collision.get_normal())
	if lifetime <= 0:
		queue_free()
	else:
		lifetime -= delta
