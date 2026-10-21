extends Node2D

enum Breathing {b_in, b_out}
var breathing = Breathing.b_in
var breathing_timer: Timer
@export var breathing_time: float
@export var breathe_distance: float
@export var shrink_scale: float = 0.85  # scale when breathed out

@onready var lungs_tilemap: TileMapLayer = $Lungs
@onready var centre: Marker2D = $Centre

var lungs_base_pos: Vector2

func _ready() -> void:
	lungs_base_pos = lungs_tilemap.position

	breathing_timer = Timer.new()
	breathing_timer.wait_time = breathing_time
	breathing_timer.one_shot = false
	breathing_timer.autostart = true
	breathing_timer.timeout.connect(_breathe_switch)
	add_child(breathing_timer)
	breathing_timer.start()

func _breathe_switch() -> void:
	var offset: Vector2
	var target_scale: float
	if breathing == Breathing.b_in:
		breathing = Breathing.b_out
		offset = Vector2(0, -breathe_distance)
		target_scale = shrink_scale
	else:
		breathing = Breathing.b_in
		offset = Vector2(0, breathe_distance)
		target_scale = 1.0

	for node in get_tree().get_nodes_in_group("movable"):
		if not is_ancestor_of(node):
			return
		var tween = create_tween()
		tween.tween_property(node, "position", node.position + offset, breathing_time)\
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	var scale_tween = create_tween()
	scale_tween.tween_method(_set_lungs_scale, lungs_tilemap.scale.x, target_scale, breathing_time)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _set_lungs_scale(s: float) -> void:
	lungs_tilemap.scale = Vector2(s, s)
	lungs_tilemap.position = centre.position - (centre.position - lungs_base_pos) * s
