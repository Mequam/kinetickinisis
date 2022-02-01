extends CanvasLayer
class_name MovementUI


export(NodePath) var player_node
export(NodePath) var movement_node_container
export(NodePath) var movement_inventory_container
export(NodePath) var movement_input_action_container
export(PackedScene) var movement_button_node
export(PackedScene) var input_action_button_node
export(NodePath) var control_input_ui
export(bool) var is_open = false
var previous_mouse_mode = Input.MOUSE_MODE_VISIBLE
var movement_buttons = []
var inventory_buttons = []
var action_buttons = []
#onready var movement_button : Node = movement_button_node.instance()

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func place_movement_node_buttons():
	for node in get_node(player_node).get_movement_nodes():
		var move_button = movement_button_node.instance()
		move_button.movement_node = node
		move_button.text = node.name.capitalize()
		get_node(movement_node_container).add_child(move_button)
		move_button.connect("selected",self, "_on_button_selected")
		movement_buttons.append(move_button)
	pass

func place_inventory_node_buttons():
	for node in get_node(player_node).get_inventory_nodes():
		var move_button = movement_button_node.instance()
		move_button.movement_node = node
		move_button.text = node.name.capitalize()
		move_button.button_type = 1
		get_node(movement_inventory_container).add_child(move_button)
		move_button.connect("selected",self, "_on_button_selected")
		inventory_buttons.append(move_button)
	pass

func place_action_buttons():
	for node in get_node(player_node).get_movement_nodes():
		var action_button = input_action_button_node.instance()
		action_button.action_name = node.input_action
		get_node(movement_input_action_container).add_child(action_button)
		action_button.connect("mouse_over", self, "_on_action_mouse_over")
		if action_button.action_name == "":
			action_button.modulate = Color.transparent
		action_buttons.append(action_button)
	pass

func refresh_buttons():
	for button in inventory_buttons:
		button.queue_free()
	inventory_buttons = []
	for button in movement_buttons:
		button.queue_free()
	movement_buttons = []
	for button in action_buttons:
		button.queue_free()
	action_buttons = []
	place_movement_node_buttons()
	place_inventory_node_buttons()
	place_action_buttons()

func open():
	previous_mouse_mode = Input.get_mouse_mode()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	refresh_buttons()
	get_child(0).visible = true

func close():
	Input.set_mouse_mode(previous_mouse_mode)
	get_child(0).visible = false

func toggle():
	if !get_child(0).visible:
		open()
	else:
		close()

# Called when the node enters the scene tree for the first time.
func _ready():
	
#	place_movement_node_buttons()
	refresh_buttons()
#	close()
	pass # Replace with function body.

func _on_action_mouse_over(action_button):
	if action_button.action_name != "" and action_button.is_mouse_over:
		get_node(control_input_ui).highlight_action_inputs(action_button.action_name)
	else:
		get_node(control_input_ui).clear_inputs()
	pass

func _on_button_selected(button):
	print(button)
	match button.button_type:
		0:
			get_node(player_node).move_node_into_inventory(button.movement_node)
			refresh_buttons()
		1:
			get_node(player_node).move_node_into_movements(button.movement_node)
			refresh_buttons()
		
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
