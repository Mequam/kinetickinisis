extends VelocityMoveNode

class_name JumpMoveNode

func _ready():
	add_to_group("JumpMoveNode")
func get_display_name()->String:
	return "Jump"
func get_required_controls()->Array:
	return ["jump"]

var jump_dir : Vector3 = Vector3(0,10,0)

var jumps : int = 0
export(int) var max_jumps : int = 1

func overload_process(delta)->void:
	if player_node.collision:
		velocity = Vector3(0,0,0)
	.overload_process(delta)

func on_player_collided(collision):
	jumps = 0
	.on_player_collided(collision)

func _on_player_input_recived(event):
	if jumps < max_jumps and event.is_action_pressed("jump"):
		velocity += jump_dir
		jumps += 1
