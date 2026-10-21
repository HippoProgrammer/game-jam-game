extends NavigationAgent2D

func _ready() -> void:
	var agent: RID = get_rid()
	NavigationServer2D.agent_set_avoidance_enabled(agent, true)

# obligatory pf 🏳️‍🌈
