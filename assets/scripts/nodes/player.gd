extends KinematicBody

#this is the player class that the player controls
#TODO: impliment this

class_name Player

export(NodePath) var camera
export(NodePath) var movement_node_manager_node
export(int) var collision_window : int = int(1e+6/15)

var time_of_last_collision : int = 0

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
func move_and_collide(rel_vec: Vector3, infinite_inertia: bool = true, exclude_raycast_shapes: bool = true, test_only: bool = false)->KinematicCollision:
	var col = .move_and_collide(rel_vec, infinite_inertia, exclude_raycast_shapes, test_only)
	var col_time = OS.get_ticks_usec()
	get_tree().call_group("Debug UI", "recieve_collision_time", col_time - time_of_last_collision)
	
	if col:
		if not collision:
			if col_time - time_of_last_collision > collision_window:
				print("EMITTING COLLIDED SIGNAL")
				emit_signal("collided",collision)
		time_of_last_collision = col_time
	
	collision = col
#	time_of_last_collision = col_time
	return collision
	
#func rotate_cam(Vector2)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

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


#returs all nodes subscribed to the given action
func get_action_subscribed_nodes(action : String)->Array:
	var ret_val  : Array = []
	for move_node in input_map.keys():
		if action in input_map[move_node]:
			ret_val.append(action)
	return ret_val

#returns the index of the action the node is subsribed to -1 if not subscribed
func get_node_action_code(move_node : MovementNode,action : String)->int:
	if input_map.has(move_node):
		for i in range(0,len(input_map[move_node])):
			if input_map[move_node][i] == "action":
				return (i as int)
	return -1

#syntactic sugar to get the nodes that are subscribed to an action
func get_subscribed_nodes()->Array:
	return input_map.keys()

#call the event for all movement nodes subscribed to the given input
func _input(event):
	if event is InputEventAction:
		for move_node in get_action_subscribed_nodes(event.action):
			(move_node as MovementNode).on_player_input(get_node_action_code(move_node,event.action))
