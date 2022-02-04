extends Camera
class_name PlayerCamera

export(NodePath) var H_Rotate
export(NodePath) var V_Rotate
export(NodePath) var D_Rotate
export(Vector3) var gimbal_rotation_degrees setget set_gimbal_rotation_degrees

signal rotated_cam

func set_gimbal_rotation_degrees(n_degrees : Vector3):
#	gimbal_rotation_degrees.x = wrapf(n_degrees.x,-180,180)
#	gimbal_rotation_degrees.y = wrapf(n_degrees.y,-180,180)
#	gimbal_rotation_degrees.z = wrapf(n_degrees.z,-180,180)
	gimbal_rotation_degrees = n_degrees
	if not is_inside_tree(): yield(self, "ready")
	(get_node(H_Rotate) as Position3D).rotation_degrees.y = gimbal_rotation_degrees.x
	(get_node(V_Rotate) as Position3D).rotation_degrees.x = gimbal_rotation_degrees.y
	(get_node(D_Rotate) as Position3D).rotation_degrees.z = gimbal_rotation_degrees.z
	emit_signal("rotated_cam")

func rotate_h(degree : float) -> void:
#	(get_node(H_Rotate) as Position3D).rotation_degrees.y += degree
	self.gimbal_rotation_degrees.x += degree
func rotate_v(degree : float) -> void:
#	(get_node(V_Rotate) as Position3D).rotation_degrees.x += degree
	self.gimbal_rotation_degrees.y += degree
func rotate_d(degree : float) -> void:
#	(get_node(D_Rotate) as Position3D).rotation_degrees.z += degree
	self.gimbal_rotation_degrees.z += degree


func rotate_hv(vec : Vector2) -> void:
	rotate_h(vec.x)
	rotate_v(vec.y)

func look_at_point(point : Vector3):
#	look_at()
	var relative_point = get_node(H_Rotate).global_transform.affine_inverse()*point
#	var relative_point = point - global_transform.origin
	var horizontal_angle = -atan2(relative_point.x,-relative_point.z)
	var vertical_angle = atan2(relative_point.y,sqrt(relative_point.z*relative_point.z+relative_point.x*relative_point.x))
	var debug_string = ""
	debug_string += "Horizontal Rotation: %4.4f"%(get_node(H_Rotate) as Position3D).rotation_degrees.y
#	print("h_rot_rn ", (get_node(H_Rotate) as Position3D).rotation_degrees.y)
#	print("rot_diff ", horizontal_angle)
	debug_string += "\nRotational Difference: %4.4f"%horizontal_angle
	debug_string += "\nRotational Difference Degrees: %4.4f"%rad2deg(horizontal_angle)
#	print("rot_diff_deg ", rad2deg(horizontal_angle))
	rotate_h(rad2deg(horizontal_angle))
#	print("h_rot_new ", (get_node(H_Rotate) as Position3D).rotation_degrees.y)
	get_tree().call_group("thestupidrotation", "recieve_rotational_debug_data", debug_string)
#	rotate_v(rad2deg(vertical_angle))
#	self.gimbal_rotation_degrees.x = rad2deg(horizontal_angle)
	self.gimbal_rotation_degrees.y = rad2deg(vertical_angle)
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
