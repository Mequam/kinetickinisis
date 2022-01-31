extends Control

export(NodePath) var keyboard_ui_node_path
export(NodePath) var mouse_ui_node_path
export(NodePath) var controller_ui_node_path
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func clear_inputs():
	var keyboard_ui = get_node_or_null(keyboard_ui_node_path)
	if keyboard_ui:
		keyboard_ui.clear_keys()
	pass

func highlight_action_inputs(action : String, clear = true):
	if clear: clear_inputs()
	if InputMap.has_action(action):
		for event in InputMap.get_action_list(action):
			if event is InputEventKey:
				get_node(keyboard_ui_node_path).press_scancode(event.scancode)
# Called when the node enters the scene tree for the first time.

func highlight_multi_action_inputs(actions : Dictionary):
	clear_inputs()
	for key in actions.keys():
		highlight_action_inputs(actions[key], false)

func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
