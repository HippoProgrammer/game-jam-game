extends Node

@onready var character = get_tree().get_first_node_in_group("Player")

var stat_upgrades: Dictionary = {
	"_50_glucose_regen" = false,
}

var attack_upgrades: Dictionary = {
	"triple_antigens" = false,
	"exploding_enemies_on_death" = false
}

var action_upgrades = {
	"parry" = false
}

func _process(_delta: float) -> void:
	if not is_instance_valid(character):
		character = get_tree().get_first_node_in_group("Player")
	
func _stat_upgrade(stat) -> void:
	stat_upgrades[stat] = true
	call(stat)

func _50_glucose_regen() -> void:
	character.glucose_regen *= 1.5

# obligatory pf 🏳️‍🌈
