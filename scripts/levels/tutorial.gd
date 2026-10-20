extends Node2D

@onready var instructor: Label = $CanvasLayer/Instructor

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	show_line("test")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func show_line(text: String, hold_time := 1.5):
	instructor.text = text
	instructor.visible_ratio = 0.0
	await get_tree().create_timer(hold_time).timeout
