extends PositionMoveNode

class_name RayCastTeleportMove

export(float) var length : float = 10.0
var tele_count : int = 0
var max_tele : int = 2

func on_player_collided(col):
	tele_count = 0
	.on_player_collided(col)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func update_position():
	if tele_count < max_tele:
		var data = camera_node.cast_view_ray(length)
		
		player_node.global_transform.origin = data["position"]+Vector3(0,10,0)*0
		tele_count += 1

func _player_input(event : InputEvent):
	if input_action != "" and event.is_action_pressed(input_action):
		update_position()
