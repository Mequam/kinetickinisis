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

func cast_view_ray(ray_length : float = 10.0)->Dictionary:
	var mouse_pos : Vector2 = get_viewport().get_mouse_position()
	var from = project_ray_origin(mouse_pos)
	var to = from + project_ray_normal(mouse_pos) * ray_length
	var buffer = get_world().direct_space_state.intersect_ray(from,to)
	
	if not "collider" in buffer:
		buffer["position"] = to
	return buffer

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
