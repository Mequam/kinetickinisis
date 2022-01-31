extends AccelerationMoveNode
class_name GravityFlipMove


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("GravityFlipMove")
	pass # Replace with function body.

func _input(event):
	if input_action != "" and event.is_action_pressed(input_action):
		acceleration.y *= -1
		var rotate_vec = (camera_node.global_transform.basis.z*Vector3(1,0,1)).normalized()
#		player_node.transform.basis.rotated()
		player_node.global_transform.basis = player_node.global_transform.basis.rotated(rotate_vec,PI)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
