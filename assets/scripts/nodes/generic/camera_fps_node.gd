extends CameraMoveNode

class_name CameraFPSMoveNode

export(Vector2) var sensitivity : Vector2 = Vector2(1,1)

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("CameraFPSMoveNode")
	pass # Replace with function body.

func _input(event):
	var l_vec = Vector2(0,0)
	if event is InputEventJoypadMotion:
		l_vec += Input.get_vector("look_left","look_right","look_down","look_up")
	if event is InputEventMouseMotion:
		l_vec += event.relative/100
	rotate_cam(-l_vec*sensitivity)
	
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
