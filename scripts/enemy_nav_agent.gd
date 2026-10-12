extends NavigationAgent2D

# Need to attach to node, cant do in vscode. doesnt have a uid so mya be problematic

func _ready() -> void:
	var agent: RID = get_rid()
	NavigationServer2D.agent_set_avoidance_enabled(agent, true)