extends PositionMoveNode

#teleports the player back to the original position that the input they 
#pressed down was pressed
class_name TimePortMoveNode

#simple node that snaps the player to the last position that they pressed
#the input at

var snap_position : Vector3 = Vector3(0,0,0)

func _ready():
	add_to_group("TimePortMoveNode")
func get_display_name()->String:
	return "Time Port"
func get_required_controls()->Array:
	return ["jump"]

func _on_player_input_recived(event):
	if (event as InputEvent).is_action_pressed("jump"):
		snap_position = player_node.global_transform.origin
	elif (event as InputEvent).is_action_released("jump"):
		player_node.global_transform.origin = snap_position
