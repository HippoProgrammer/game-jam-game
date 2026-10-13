extends AudioStreamPlayer

var error_sound = preload("res://sounds/win_xp_error.mp3")

func play_sound(sound: AudioStream) -> void:
	stop()
	stream = sound
	play()
