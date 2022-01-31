extends Node

#this is the generic movement node class inteanded to be overiden by subclasses only

class_name MovementNode
export(NodePath) var player_node_path : NodePath
onready var player_node : Player = get_player()
onready var camera_node : PlayerCamera = get_cam()

#this returns a list of other movement nodes that we can use as a black list or white list depending on
#the context we need it in

func get_class_relations()->Array:
	return []
#returns a list of required controls, when we are bieng added to the
#player if any other node has required controls they get rejected

#TODO: this could be a saved array, and we could use integers to map plyer
#actions for a more dynamic form of input
func get_required_controls()->Array:
	return []

#gets the display name for the UI
#we use a function so godot doesnt keep strings in memory
#and so it is NON setable from outside sources
func get_display_name()->String:
	return "movment node"
#returns the player, which serves as a data hub
func get_player()->Player:
	print(player_node_path)
	if player_node != null:
		return player_node
	if player_node_path.is_empty():
		#if we want to ensure this is a player ad code here
		return (get_parent().get_parent() as Player)
	return (get_node(player_node_path) as Player)


#syntactic sugar functions for getting stuffz
func get_cam()->Camera:
	return get_player().get_cam()
func get_transform()->Transform:
	return get_player().transform
func get_position()->Vector3:
	return get_player().transform.origin
func set_position(pos : Vector3)->void:
	get_player().transform.origin = pos
func apply_cam_transform(vec : Vector3) -> Vector3:
	return get_cam().global_transform*vec-get_cam().global_transform.origin

#returns true if the two rays have a non null intersection
func array_intersects(arr1 : Array, arr2 : Array)->bool:
	for n in arr1:
		if arr2.has(n):
			return true
	return false
	
var mov_name : String setget set_mov_name,get_mov_name
func set_mov_name(val : String)->void:
	print("[WARNING] node tried to write to movement_name")
	pass
func get_mov_name()->String:
	return mov_name



#this function is run in the main ready but inteanded to be overloaded
#in child classes
func overload_ready()->void:
	pass
#called when the player collides with an object
func on_player_collided(collision):
	pass
# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("MovementNode")
	player_node.connect("collided",self,"on_player_collided")
	player_node.connect("input_recived",self,"_on_player_input_recived")
	overload_ready()
func overload_process(delta) -> void:
	pass
func _process(delta):
	overload_process(delta)

#returns true if we are compatable with the given node
func check_incomp(mov_node,black_list : bool = true)->bool:
	#godot makes checking if same type sad :(
	if mov_node.is_in_group("MovementNode"):
		return   (black_list == array_intersects(get_class_relations() ,(mov_node).get_groups()) or array_intersects(get_required_controls(),(mov_node).get_required_controls()))
	return false
func check_comp(mov_node,black_list : bool = true)->bool:
	return not check_incomp(mov_node,black_list)
#removes the node from the tree and performs cleaning opeerations
func remove_movement():
	queue_free()
#to be overriden called when the player collides
func player_collided(col):
	pass
#this works EXACTLY like the normal input function, but we only run it
#when the player signals, giving the player a global input toggle
func _on_player_input_recived(event):
	pass
