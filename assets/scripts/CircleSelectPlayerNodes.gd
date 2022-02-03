extends CircleSelectControl

#this class is a NON GENERAL UI class inteanded for the player
#to select movemnt nodes using a circle with two different settings

class_name CircleSelectPlayerControl
#reference to the player
var player : Node
var active_circle : bool = true

func _ready():
	connect("gui_input",self,"circle_select_detected_input")
	connect("selected_option",self,"_player_selected_circle_option")
	connect("option_hover_changed",self,"_circle_hover_changed")
	if active_circle:
		set_circle_options_from_list(get_active_nodes())
		self.focus_color = Color.green
	else:
		set_circle_options_from_list(get_inventory_nodes())
		self.focus_color = Color.red
	sync_options()
	grab_focus()

func _circle_hover_changed(option):
	if option <= 0:
		centerText.text = options[option]
	elif active_circle:
		centerText.text = player.get_node(player.movement_node_manager_node).get_child(option-1).get_input_string()
	else:
		#inventory circle
		centerText.text = options[option]

func _player_selected_circle_option(option):
	if option > 0:
		if active_circle:
			player.move_node_into_inventory(player.get_movement_node(last_option - 1))
		else:
			player.move_node_into_movements(player.movement_inventory[option-1])
	remove_circle_select()

func remove_circle_select()->void:
	queue_free()

func _input(event):
	if active_circle and last_option > 0 and (event is InputEventKey) and event.is_pressed():
		var action = player.get_movement_node(last_option - 1).input_action
		if InputMap.action_has_event(action,event):
			InputMap.action_erase_event(action,event)
		else:
			InputMap.action_add_event(action,event)
		centerText.text = player.get_movement_node(last_option - 1).get_input_string()

#takes an array of movement nodes and sets the options in our circle UI to their proper values
func set_circle_options_from_list(movement_node_list : Array,default_options : Array = ["Cancel"])->void:
	options = default_options
	for node in movement_node_list:
		options.append(node.get_display_name())

func get_inventory_nodes()->Array:
	return player.movement_inventory
func get_active_nodes()->Array:
	return player.get_movement_nodes()

func _on_CircleSelect_tree_entered():
	pass
