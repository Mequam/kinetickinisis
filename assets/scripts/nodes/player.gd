extends KinematicBody

#this is the player class that the player controls
#TODO: impliment this

class_name Player

export(NodePath) var camera
export(NodePath) var movement_node_manager_node
export(int) var collision_window : int = int(1e+6/15)
var time_of_last_collision : int = 0

#a reference to a circle select script that we use for equiping nodes
onready var selection_ui : CircleSelectControl = preload("res://assets/nodes/UI/CircleSelect.tscn").instance()

#this variable is a reference to the primary movment node that we 
#get our white lists from
var main_node

#an inventory of nodes that are not equiped
var node_inventory : Array = []
#toggles wether or not the player responds to any input messages
var do_player_input : bool = true

func toggle_do_player_input()->void:
	do_player_input = not do_player_input

#called when we collide with stuff (dur)
signal collided
#called when we want to send input to the lower nodes
signal input_recived

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
				emit_signal("collided",collision)
		time_of_last_collision = col_time
	
	collision = col
#	time_of_last_collision = col_time
	return collision
	
#shuts down all input to the player movement systems
#and displays the selection inventory to the player
func inventory()->void:
	#shut down player input to the movment nodes
	#get the default option
	do_player_input = false
	
	selection_ui.options = ["Cancel"]
	
	for mn in node_inventory:
		selection_ui.options.append(mn.get_display_name())
	
	add_child(selection_ui)
	selection_ui.display_options()
	selection_ui.connect("selected_option",self,"_player_selected_option")

#the player selected an inventory option
func _player_selected_option(option):
	if option != 0 and option-1 < len(node_inventory):
		add_new_movement(node_inventory[option-1])
		node_inventory.remove(option-1)
	remove_child(selection_ui)
	do_player_input  = true

func add_new_movement(mov_node)->void:
	$movement.add_child(mov_node)
# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	#node_inventory.append(PlanarMoveNode.new(),RayCastTeleportMove.new(),JumpMoveNode.new())

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

#a wrapper for the Input.get_vector class
func get_vector(a : String,b : String,c: String,d:String,non_input_default : Vector2 = Vector2(0,0))->Vector2:
	if not do_player_input:
		return non_input_default
	return Input.get_vector(a,b,c,d)
func _input(event):
	if event.is_action_pressed("inventory"):
		inventory()
	elif do_player_input:
		emit_signal("input_recived",event)
