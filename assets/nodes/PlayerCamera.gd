extends Camera
class_name PlayerCamera

export(NodePath) var H_Rotate
export(NodePath) var V_Rotate
export(NodePath) var D_Rotate

func rotate_h(degree : float) -> void:
	(get_node(H_Rotate) as Position3D).rotation_degrees.y += degree
	pass

func rotate_v(degree : float) -> void:
	(get_node(V_Rotate) as Position3D).rotation_degrees.x += degree
	pass

func rotate_d(degree : float) -> void:
	(get_node(D_Rotate) as Position3D).rotation_degrees.z += degree
	pass



func rotate_hv(vec : Vector2) -> void:
	rotate_h(vec.x)
	rotate_v(vec.y)
	pass
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pass # Replace with function body.

#func _input(event):
#	if event is InputEventMouseMotion:
#		rotate_hv(-event.relative)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
