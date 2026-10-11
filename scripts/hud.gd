extends CanvasLayer

@onready var character = get_tree().get_first_node_in_group("Player") # find the player instance... i hope

# --- HEALTH AND GLUCOSE ---
@onready var glucose_bar: ProgressBar = $GlucoseBar
@onready var health_bar: ProgressBar = $HealthBar


func _ready() -> void:
	character.glucose_changed.connect(_on_glucose_change)
	character.health_changed.connect(_on_health_change)

func _on_glucose_change(new: float, max_value: float) -> void:
	glucose_bar.max_value = max_value
	glucose_bar.value = new

func _on_health_change(new: float, max_value: float) -> void:
	health_bar.max_value = max_value
	health_bar.value = new
