extends VelocityMoveNode

class_name JumpMoveNode

func _ready():
	add_to_group("JumpMoveNode")
#	print(name)

export(Vector3) var jump_dir : Vector3 = Vector3(0,10,0)

var jumps : int = 0
export(int) var max_jumps : int = 1

func get_display_name()->String:
	return "Jump"

func overload_process(delta)->void:
	if player_node.collision:
		velocity = Vector3(0,0,0)
	.overload_process(delta)

func on_player_collided(collision):
	print("DETECTED PLAYER COLLISION")
	jumps = 0
	.on_player_collided(collision)

func _player_input(event : InputEvent):
	if event.is_action_pressed("jump"):
		print("JUMP GOT PLAYER INPUTSSSS")
	if jumps < max_jumps and event.is_action_pressed(input_action):
		print()
		print(event.is_pressed())
		print(jump_dir)
		print(player_node.transform.basis)
		print(player_node.transform.basis*jump_dir)
		velocity += player_node.transform.basis*jump_dir
		print(velocity)
		print()
		jumps += 1
