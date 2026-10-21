extends CanvasLayer

@onready var character = get_tree().get_first_node_in_group("Player")

@onready var notifier = $Notifications

# --- HEALTH AND GLUCOSE ---
@onready var health_bar: TextureProgressBar = $HealthBar

# Godot functions

func _ready() -> void:
	character.health_changed.connect(_on_health_change)

func _process(_delta: float) -> void:
	if not is_instance_valid("Player"):
		character = get_tree().get_first_node_in_group("Player")
		character.health_changed.disconnect(_on_health_change) # Just ignore the error here
		character.health_changed.connect(_on_health_change)
# User functions

func _on_health_change(new: float, max_value: float) -> void:
	health_bar.max_value = max_value
	health_bar.value = new

func _notify(text: String, hold: bool = false, hold_time := 1.5):
	notifier.text = text
	if hold:
		await get_tree().create_timer(hold_time).timeout

# obligatory pf 🏳️‍🌈
