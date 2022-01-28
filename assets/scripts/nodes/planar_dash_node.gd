extends PlanarMoveNode

#this class impliments basic movment in a 2d perpendicular to up and with 
#respect to the camera 

class_name PlanarDashMoveNode


export(float) var wait_time : float = 0.5
var timer_node : Timer
func on_player_collided(col):

	.on_player_collided(col)
func get_vel()->Vector3:
	if timer_node.time_left != 0:
		return .get_vel()
	return velocity

func overload_process(delta):
	.overload_process(delta)

func _input(event):
	if input_action != "" and event.is_action_pressed(input_action):
		timer_node.start() 
		
func _ready():
	timer_node = Timer.new()
	timer_node.one_shot = true
	timer_node.wait_time = wait_time
	timer_node.connect("timeout",self,"on_timer_out")
	add_child(timer_node)

func on_timer_out():
	pass
