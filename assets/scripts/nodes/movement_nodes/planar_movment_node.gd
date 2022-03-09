extends VelocityMoveNode

#this class impliments basic movment in a 2d perpendicular to up and with 
#respect to the camera 

class_name PlanarMoveNode
func get_display_name()->String:
	return "Planar Move"
func _ready():
	multi_input_actions = {"move_left": "move_left", "move_right": "move_right","move_forward":"move_forward", "move_back":"move_back"}
	add_to_group("PlanarMoveNode")
	coordinate_space = 1
export(float) var movement_speed : float = 100

func get_vel()->Vector3:
	var inp_dir = player_node.get_vector(multi_input_actions["move_left"], multi_input_actions["move_right"], multi_input_actions["move_forward"], multi_input_actions["move_back"])
	match coordinate_space:
		0:
			return velocity+Vector3(inp_dir.x,0,inp_dir.y)*movement_speed
		1:
			var rotate = camera_node.gimbal_rotation_degrees.x
			var input_vector = Vector3(inp_dir.x,0,inp_dir.y)
			input_vector = input_vector.rotated(Vector3(0,1,0),rotate*PI/180)
			var velly = player_node.global_transform.basis*(input_vector*movement_speed)
#			print(velly)
			var velly_local = 0
			return velocity+velly
		2:
			return  velocity+apply_cam_transform(Vector3(inp_dir.x,0,inp_dir.y)*movement_speed)
	return velocity+apply_cam_transform(Vector3(inp_dir.x,0,inp_dir.y)*movement_speed)
