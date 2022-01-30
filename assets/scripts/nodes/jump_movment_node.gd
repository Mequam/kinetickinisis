extends VelocityMoveNode

class_name JumpMoveNode

func _ready():
	add_to_group("JumpMoveNode")
#	print(name)

export(Vector3) var jump_dir : Vector3 = Vector3(0,10,0)

var jumps : int = 0
export(int) var max_jumps : int = 1

func overload_process(delta)->void:
	if player_node.collision:
		velocity = Vector3(0,0,0)
	.overload_process(delta)

func on_player_collided(collision):
	jumps = 0
	.on_player_collided(collision)

func _input(event):
	if jumps < max_jumps and event.is_action_pressed(input_action):
#		velocity += player_node.global_transform*jump_dir
		velocity += player_node.transform*jump_dir-player_node.transform.origin
#		velocity += player_node.transform
		print(velocity)
		jumps += 1
