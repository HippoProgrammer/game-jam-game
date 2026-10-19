extends Node2D

@onready var player_SFX: AudioStreamPlayer = $player_SFX
@onready var enemy_SFX: AudioStreamPlayer = $enemy_SFX

#@onready var character = get_tree().get_first_node_in_group("Player")

# player_SFX:
var error_sound = preload("res://sounds/win_xp_error.mp3")
var dash_sound = preload("res://sounds/dash_sound.mp3")
var take_damage_sound = preload("res://sounds/take_damage_player.mp3")
var take_damage_meme_sound = preload("res://sounds/take_damage_player_meme.mp3")

# enemy_SFX
var enemy_die_sound = preload("res://sounds/enemy_dying.mp3")

func play_sound(player: AudioStreamPlayer, sound: AudioStream, meme_SFX = null) -> void:
	player.stop()
	if Events.meme_SFX and meme_SFX != null:
		player.stream = meme_SFX
	else:
		player.volume_linear = Events.sfx_volume * (Events.master_volume/100)
		player.stream = sound
	player.play()

func _ready() -> void:
	Events.error_sound.connect(play_sound.bind(player_SFX, error_sound))
	Events.enemy_died_sound.connect(play_sound.bind(enemy_SFX, enemy_die_sound))
	Events.dash_sound.connect(play_sound.bind(player_SFX, dash_sound))
	Events.player_take_damage.connect(play_sound.bind(player_SFX, take_damage_sound, take_damage_meme_sound))
