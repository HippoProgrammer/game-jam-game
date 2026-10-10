extends Resource

class_name enemy_data

@export var name: String = "enemy"

@export_group("stats")
@export var max_health = 100.0
@export var max_glucose = 100.0
@export var gl_regen = 0.0
@export var can_health_regen = false

@export_group("movement")
@export var movement_speed = 0.0

@export_group("visual")
@export var texture: Texture2D
@export var collision_shape: Shape2D
