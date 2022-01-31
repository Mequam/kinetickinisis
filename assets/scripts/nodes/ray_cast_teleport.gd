extends PositionMoveNode

class_name RayCastTeleportMove

export(float) var length : float = 10.0
var tele_count : int = 0
var max_tele : int = 2

func get_display_name()->String:
	return "Teleport"
func get_class_relations()->Array:
	return ["PlanarMoveNode"]
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

func _on_player_input_recived(event):
	if event.is_action_pressed("action_0"):
		update_position()
