extends Node

#this is the generic movement node class inteanded to be overiden by subclasses only

class_name MovementNode
export(NodePath) var player_node_path : NodePath
onready var player_node : Player = get_player()


#returns the player, which serves as a data hub
func get_player()->Player:
	if player_node is Player:
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

#if another movement node (or node class) is incompatable with this one
#the class and the name of the node should be listed here
var _class_comp : Array = []
var _node_comp : Array = []

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
# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("MovementNode")
	overload_ready()

#returns true if we are compatable with the given node
func check_incomp(mov_node)->bool:
	#godot makes checking if same type sad :(
	if mov_node.is_in_group("MovementNode"):
		return array_intersects(_class_comp,(mov_node as Node).get_groups()) or _node_comp.has((mov_node).get_movement_type)
	return false
func check_comp(mov_node)->bool:
	return not check_incomp(mov_node)
		
#convinence function that removes the node from the tree if the given node is incompatable
func remove_if_comp(mov_node)->void:
	if check_incomp(mov_node):
		remove_movement()
#removes the node from the tree and performs cleaning opeerations
func remove_movement():
	queue_free()
