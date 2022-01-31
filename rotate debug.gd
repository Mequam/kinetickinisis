extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export(NodePath) var player_node
export(NodePath) var stupidfreakingthingugh
export(NodePath) var ugh

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var camera : PlayerCamera = get_node(player_node).get_cam()
	camera.look_at_point(get_node(stupidfreakingthingugh).global_transform.origin)
#	pass


func recieve_rotational_debug_data(n_data):
	$CanvasLayer/Control/Label.text = n_data
