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
func get_movement_node_paths(ret_val = [],path : String = "res://assets/scripts/nodes/movement_nodes/")->Array:
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
	return ret_val
func get_movment_node_instance(id : int):
	return (load(get_movement_node_paths()[id]).instance())
