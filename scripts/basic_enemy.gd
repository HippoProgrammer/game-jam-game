extends Node2D

@export var data: enemy_data

var health = data.max_health
var glucose = data.max_glucose

func _ready() -> void:
	$Sprite2D.texture = data.texture
	$CollisionShape2D.shape = data.collision_shape
