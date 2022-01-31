extends CameraMoveNode

class_name CameraFPSMoveNode

export(Vector2) var sensitivity : Vector2 = Vector2(50,50)

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("CameraFPSMoveNode")
func get_display_name():
	return "FPS Camera"
func _on_player_input_recived(event):
	var l_vec = Vector2(0,0)
	if event is InputEventJoypadMotion:
		l_vec += Input.get_vector("look_left","look_right","look_down","look_up")
	if event is InputEventMouseMotion:
		l_vec += event.relative/100
	rotate_cam(-l_vec*sensitivity)
