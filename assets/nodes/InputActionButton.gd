extends Button

var movement_node : Node
export(String) var action_name setget set_action_name
export(bool) var is_mouse_over

func set_action_name(n_name):
	action_name = n_name
	text = action_name
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

signal mouse_over(node)
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Action_Input_Button_mouse_entered():
	is_mouse_over = true
	emit_signal("mouse_over", self)
	pass # Replace with function body.


func _on_Action_Input_Button_mouse_exited():
	is_mouse_over = false
	emit_signal("mouse_over", self)
	pass # Replace with function body.


func _on_Action_Input_Button_gui_input(event):
	if event is InputEventKey and pressed and action_name != "":
		var input_events = InputMap.get_action_list(action_name)
		for event in input_events:
			InputMap.action_erase_event(action_name, event)
		var new_event = InputEventKey.new()
		new_event.scancode = event.scancode
		InputMap.action_add_event(action_name,event)
		pressed = false
		release_focus()
		pass
	pass # Replace with function body.
