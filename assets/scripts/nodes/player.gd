extends KinematicBody

#this is the player class that the player controls
#TODO: impliment this

class_name Player

export(NodePath) var camera
export(NodePath) var movement_node_manager_node
export(NodePath) var movement_inventory_manager_node
export(NodePath) var movement_ui
export(int) var collision_window : int = int(1e+6/15)

export(bool) var do_player_input : bool = true setget set_do_player_input, get_do_player_input
func set_do_player_input(val : bool):
	do_player_input = val
func get_do_player_input():
	return do_player_input and not get_node(movement_ui).get_child(0).visible and circle_select.get_parent() != self
var time_of_last_collision : int = 0

var circle_select : CircleSelectControl = preload("res://assets/nodes/UI/CircleSelect.tscn").instance()
var movement_inventory = []

#input map used by nodes that are added to the scene
#the keys in this dictionary are references to movement nodes
#and the values are an array of action strings for that node to reference with
#intagers on an index basis
var input_map : Dictionary = {}

signal collided

var collision setget set_col , get_col
func set_col(val)->void:
	print("[WARNING] external node attempting to set player collision")
func get_col():
	return collision

func get_cam()->Camera:
	return (get_node(camera) as Camera)

func get_movement_nodes():
	return get_node(movement_node_manager_node).get_children()

func get_inventory_nodes():
	return movement_inventory

func move_node_into_movements(node : Node):
	if node.get_parent():
		node.get_parent().remove_child(node)
#		node.set_process(true)
#		node.set_process_input(true)
	if node in movement_inventory:
		movement_inventory.erase(node)
	get_node(movement_node_manager_node).add_child(node)
	pass

func move_node_into_inventory(node : Node):
	if node.get_parent():
		node.get_parent().remove_child(node)
#		node.set_process(false)
#		node.set_process_input(false)
#	get_node(movement_inventory_manager_node).add_child(node)
	movement_inventory.append(node)
	pass

func get_vector(a : String,b : String,c: String,d:String,default_return : Vector2 = Vector2(0,0))->Vector2:
	if not self.do_player_input:
		return default_return
	return Input.get_vector(a,b,c,d)

func move_and_collide(rel_vec: Vector3, infinite_inertia: bool = true, exclude_raycast_shapes: bool = true, test_only: bool = false)->KinematicCollision:
	var col = .move_and_collide(rel_vec, infinite_inertia, exclude_raycast_shapes, test_only)
	var col_time = OS.get_ticks_usec()
	get_tree().call_group("Debug UI", "recieve_collision_time", col_time - time_of_last_collision)
	
	if col:
		if not collision:
			if col_time - time_of_last_collision > collision_window:
#				print("EMITTING COLLIDED SIGNAL")
				emit_signal("collided",collision)
		time_of_last_collision = col_time
	
	collision = col
#	time_of_last_collision = col_time
	return collision
	
#func rotate_cam(Vector2)

# Called when the node enters the scene tree for the first time.
func _ready():
	for node in get_inventory_nodes():
		node.set_process(false)
		node.set_process_input(false)
	pass # Replace with function body.
func display_circle(var circle_type : String)->void:
	add_child(circle_select)
	circle_select.flags["circle_type"] = circle_type
	circle_select.sync_options()
	circle_select.connect("gui_input",self,"circle_select_detected_input")
	circle_select.connect("selected_option",self,"_player_selected_circle_option")
	circle_select.connect("option_hover_changed",self,"_circle_hover_changed")
	circle_select.grab_focus()
#takes an array of movement nodes and sets the options in our circle UI to their proper values
func set_circle_options_from_list(movement_node_list : Array,default_options : Array = ["Cancel"])->void:
	circle_select.options = default_options
	for node in movement_node_list:
		circle_select.options.append(node.get_display_name())
#displays the circle UI for node binding
func display_circle_binds()->void:
	set_circle_options_from_list(get_node(movement_node_manager_node).get_children())
	display_circle("active")
	circle_select.focus_color = Color.green
#displays the circle UI for activating nodes
func display_circle_inventory()->void:
	set_circle_options_from_list(movement_inventory)
	display_circle("inventory")
	circle_select.focus_color = Color.red
	
func _input(event):
	if circle_select.get_parent() == self and circle_select.flags["circle_type"] == "active" and (event is InputEventKey) and event.is_pressed():
		var action = get_node(movement_node_manager_node).get_child(circle_select.last_option-1).input_action
		if InputMap.action_has_event(action,event):
			InputMap.action_erase_event(action,event)
		else:
			InputMap.action_add_event(action,event)
		circle_select.centerText.text = get_node(movement_node_manager_node).get_child(circle_select.last_option-1).get_input_string()
	if self.do_player_input:
		for node in get_movement_nodes():
			node._player_input(event)
	if event.is_action_pressed("inventory"):
		get_node(movement_ui).toggle()
	elif event.is_action_pressed("quick_inventory"):
		display_circle_inventory()
	elif event.is_action_pressed("quick_map"):
		display_circle_binds()


func _circle_hover_changed(option):
	var circle_type = circle_select.flags["circle_type"]
	if option <= 0:
		circle_select.centerText.text = circle_select.options[option]
	elif circle_type == "active":
		circle_select.centerText.text = get_node(movement_node_manager_node).get_child(option-1).get_input_string()
	elif circle_type == "inventory":
		circle_select.centerText.text = circle_select.options[option]
func _player_selected_circle_option(option):
	var circle_type = circle_select.flags["circle_type"]
	if circle_type == "inventory":
		if option > 0:
			move_node_into_movements(movement_inventory[option-1])
	remove_circle_select()
func remove_circle_select()->void:
	circle_select.disconnect("option_hover_changed",self,"_circle_hover_changed")
	circle_select.disconnect("selected_option",self,"_player_selected_circle_option")
	remove_child(circle_select)
func get_movement_velocities() -> Vector3:
	var ret_val : Vector3 = Vector3(0,0,0)
	for node in get_node(movement_node_manager_node).get_children():
		if node.is_in_group("VelocityMoveNode"):
			ret_val += node.velocity
	return ret_val
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	move_and_collide(get_movement_velocities()*delta)
	get_tree().call_group("Debug UI", "recieve_player_velocity", get_movement_velocities())
	get_tree().call_group("Debug UI", "recieve_player_matrix", transform)
#	print(OS.get_ticks_usec())
#	print("PLAYER VELOCITY ", get_movement_velocities())
#	print("PLAYER FRAME VELOCITY ", get_movement_velocities()*delta)
#	print("PLAYER COLLISION NORMAL", collision.normal if collision else " null")
#	if col:
#		signal hey collided (col)
#	move_and_slide(get_movement_velocities()*delta)
#	move_and_slide_with_snap(get_movement_velocities()*delta, Vector3(0,0,0))
func _process(delta):
	get_tree().call_group("Debug UI", "recieve_player_matrix", transform)
#	get_tree().call_group("Debug UI", "recieve_camera_view_vector", Vector3(3,14,159))
	get_tree().call_group("Debug UI", "recieve_camera_view_vector", get_cam().global_transform.basis.z)
