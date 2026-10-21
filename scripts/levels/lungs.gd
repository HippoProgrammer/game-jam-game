extends Node2D

enum Breathing {b_in, b_out}
var breathing = Breathing.b_in
var breathing_timer: Timer
@export var breathing_time: float
@export var breathe_distance: float

func _ready() -> void:
	breathing_timer = Timer.new()
	breathing_timer.wait_time = breathing_time
	breathing_timer.one_shot = false
	breathing_timer.autostart = true
	breathing_timer.timeout.connect(breathe_switch)
	add_child(breathing_timer)
	breathing_timer.start()

func breathe_switch() -> void:
	var offset: Vector2
	if breathing == Breathing.b_in:
		breathing = Breathing.b_out
		offset = Vector2(0, -breathe_distance)
	else:
		breathing = Breathing.b_in
		offset = Vector2(0, breathe_distance)

	for node in get_tree().get_nodes_in_group("movable"):
		var tween = create_tween()
		tween.tween_property(node, "position", node.position + offset, breathing_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
