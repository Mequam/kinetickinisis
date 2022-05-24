extends Node
#this script is a generic script for
#interacting with movement nodes from the disc

class_name MovementNodeUtils
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

#gets an array for integer mapping of
#movement nodes
#this should allways return nodes in the same order
#we can hard code this in the release of the game with a python script
#in the mean time this works just fine :)
static func get_movement_node_paths(ret_val = [],path : String = "res://assets/scripts/nodes/movement_nodes/")->Array:
	var dir : Directory = Directory.new()
	dir.open(path)
	if path[-1] != "/":
		path+= "/"
	dir.list_dir_begin(true,true)
	var mov_node_path = dir.get_next()
	while mov_node_path != "":
		if dir.current_is_dir():
			pass
			get_movement_node_paths(ret_val,path + mov_node_path)
		else:
			ret_val.append(path + mov_node_path)
		mov_node_path = dir.get_next()
	print("movement node paths")
	print(ret_val)
	return ret_val
static func get_movment_node_instance(id : int):
	var ret_val = load(get_movement_node_paths()[id]).new()
	ret_val._movement_id = id
	return ret_val
