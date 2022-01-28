extends KinematicBody

#this is the player class that the player controls
#TODO: impliment this

class_name Player

export(NodePath) var camera
export(NodePath) var movement_node_manager_node
export(NodePath) var movement_inventory_manager_node
export(NodePath) var movement_ui
export(int) var collision_window : int = int(1e+6/15)

var time_of_last_collision : int = 0

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
	return get_node(movement_inventory_manager_node).get_children()

func move_node_into_movements(node : Node):
	if node.get_parent():
		node.get_parent().remove_child(node)
		node.set_process(true)
		node.set_process_input(true)
	get_node(movement_node_manager_node).add_child(node)
	pass

func move_node_into_inventory(node : Node):
	if node.get_parent():
		node.get_parent().remove_child(node)
		node.set_process(false)
		node.set_process_input(false)
	get_node(movement_inventory_manager_node).add_child(node)
	pass

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
	pass # Replace with function body.

func _input(event):
	if event.is_action_pressed("inventory"):
		get_node(movement_ui).toggle()

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
#	print(OS.get_ticks_usec())
#	print("PLAYER VELOCITY ", get_movement_velocities())
#	print("PLAYER FRAME VELOCITY ", get_movement_velocities()*delta)
#	print("PLAYER COLLISION NORMAL", collision.normal if collision else " null")
#	if col:
#		signal hey collided (col)
#	move_and_slide(get_movement_velocities()*delta)
#	move_and_slide_with_snap(get_movement_velocities()*delta, Vector3(0,0,0))
