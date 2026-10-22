extends MeshInstance3D

@export var speed: float = 2.0

func _process(delta: float) -> void:
	rotate_y(speed * delta)
