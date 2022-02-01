extends CameraMoveNode

class_name CameraFPSMoveNode

export(Vector2) var sensitivity : Vector2 = Vector2(1,1)

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("CameraFPSMoveNode")

func _player_input(event : InputEvent):
	var l_vec = Vector2(0,0)
	if event is InputEventJoypadMotion:
		l_vec += player_node.get_vector("look_left","look_right","look_down","look_up")
	if event is InputEventMouseMotion:
		l_vec += event.relative/100
	rotate_cam(-l_vec*sensitivity)
