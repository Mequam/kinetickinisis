extends VelocityMoveNode

#this class impliments basic movment in a 2d perpendicular to up and with 
#respect to the camera 

class_name PlanarMoveNode

func _ready():
	multi_input_actions = {"move_left": "move_left", "move_right": "move_right","move_forward":"move_forward", "move_back":"move_back"}
	add_to_group("PlanarMoveNode")
	
export(float) var movement_speed : float = 100
func get_vel()->Vector3:
	var inp_dir = Input.get_vector(multi_input_actions["move_left"], multi_input_actions["move_right"], multi_input_actions["move_forward"], multi_input_actions["move_back"])
	return velocity+apply_cam_transform(Vector3(inp_dir.x,0,inp_dir.y)*movement_speed)
