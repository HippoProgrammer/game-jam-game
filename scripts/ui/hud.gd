extends CanvasLayer

@onready var character = get_tree().get_first_node_in_group("Player")

@onready var notifier = $Notifications

# --- HEALTH AND GLUCOSE ---
@onready var health_bar: TextureProgressBar = $HealthBar

# Godot functions

func _ready() -> void:
	character.health_changed.connect(_on_health_change)
	Events.notify_send.connect(_notify)

# User functions

func _on_health_change(new: float, max_value: float) -> void:
	health_bar.max_value = max_value
	health_bar.value = new

func _notify(text: String, hold: bool = false, hold_time := 1.5):
	notifier.text = text
	if hold:
		await get_tree().create_timer(hold_time).timeout
