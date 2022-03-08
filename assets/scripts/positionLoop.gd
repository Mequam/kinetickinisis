extends Node
#this node impliments the position looping feature for
#client side correction

var parent : Spatial
export(NodePath) var parent_path : NodePath

var stored_position = []

func _ready():
	if parent_path.is_empty():
		parent = get_parent()
	else:
		parent = get_node(parent_path)
