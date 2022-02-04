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
	return do_player_input and not get_node(movement_ui).get_child(0).visible and not get_node("CircleSelectPlayer")
var time_of_last_collision : int = 0

#saved circle select UI
var circle_select : PackedScene = preload("res://assets/nodes/UI/CircleSelectPlayerNodes.tscn")
#movement inventory that keeps nodes
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
	if camera:
		return (get_node(camera) as Camera)
	return ($HRotation/VRotation/DRoate/Camera as Camera)

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
func overload_ready():
	for node in get_inventory_nodes():
		node.set_process(false)
		node.set_process_input(false)
# Called when the node enters the scene tree for the first time.
func _ready():
	overload_ready()


#the player decides when to add the circle to the tree 
func display_circleUI(var circle_type : bool)->void:
	#clear out the old UI if it exists
	if get_node("CircleSelectPlayer"):
		get_node("CircleSelectPlayer").queue_free()
	var cs = circle_select.instance()
	cs.active_circle  = circle_type
	cs.player = self
	add_child(cs)
#syntactic sugary to help remember what true and false go to
#displays the circle UI for node binding
func display_circleUI_binds()->void:
	display_circleUI(true)
#displays the circle UI for activating nodes
func display_circleUI_inventory()->void:
	display_circleUI(false)

#this returns a movment node
func get_movement_node(idx : int):
	return get_node(movement_node_manager_node).get_child(idx)

#this is the input function for the player that is inteanded
#to be overloaded
func overload_input(event):
	if self.do_player_input:
		for node in get_movement_nodes():
			node._player_input(event)
	if event.is_action_pressed("inventory"):
		get_node(movement_ui).toggle()
	elif event.is_action_pressed("quick_inventory"):
		display_circleUI_inventory()
	elif event.is_action_pressed("quick_map"):
		display_circleUI_binds()
func _input(event):
	overload_input(event)

func get_movement_velocities() -> Vector3:
	var ret_val : Vector3 = Vector3(0,0,0)
	for node in get_node(movement_node_manager_node).get_children():
		if node.is_in_group("VelocityMoveNode"):
			ret_val += node.velocity
	return ret_val

func overload_physics_process(delta):
	move_and_collide(get_movement_velocities()*delta)
	get_tree().call_group("Debug UI", "recieve_player_velocity", get_movement_velocities())
	get_tree().call_group("Debug UI", "recieve_player_matrix", transform)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	overload_physics_process(delta)

func overload_process(delta):
	get_tree().call_group("Debug UI", "recieve_player_matrix", transform)
	get_tree().call_group("Debug UI", "recieve_camera_view_vector", get_cam().global_transform.basis.z)

func _process(delta):
	overload_process(delta)
