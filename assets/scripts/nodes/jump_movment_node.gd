extends VelocityMoveNode

class_name JumpMoveNode

func _ready():
	add_to_group("JumpMoveNode")

var jump_dir : Vector3 = Vector3(0,10,0)

func _input(event):
	if event.is_action_pressed("jump"):
		velocity += jump_dir
