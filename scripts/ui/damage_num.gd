extends Label

func setup(amount: int, colour: Color = Color(0.987, 0.215, 0.0, 1.0)) -> void:
	
	text = str(amount)
	
	modulate = colour
	
	_animate()

func _animate() -> void:
	
	var drift := Vector2(randf_range(-20, 20), -50)
	var target_pos := position + drift
	
	var tween := create_tween()
	tween.set_parallel(true)
	
	tween.tween_property(self, "position", target_pos, 0.8).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 0.0, 0.8)
	
	tween.chain().tween_callback(queue_free)
