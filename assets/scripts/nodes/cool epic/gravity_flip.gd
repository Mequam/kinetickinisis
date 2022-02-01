extends AccelerationMoveNode
class_name GravityFlipMove


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func get_display_name()->String:
	return "Grav Flip"

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("GravityFlipMove")
	pass # Replace with function body.

func _player_input(event : InputEvent):
	if input_action != "" and event.is_action_pressed(input_action):
		acceleration.y *= -1
#		player_node.transform = player_node.transform.rotated(camera_node.project_local_ray_normal(get_viewport().get_mouse_position()),PI)
#		player_node.rotation_degrees.z += 180
#		player_node.rotate(Vector3(0,1,0),PI)
#		var rotate_vec = player_node.global_transform.affine_inverse()*(camera_node.global_transform*Vector3(0,0,-1)-camera_node.global_transform.origin)-player_node.global_transform.origin
		var rotate_vec = (Vector3(1,0,1)*(player_node.global_transform.affine_inverse().basis*camera_node.global_transform.basis.z)).normalized()
#		print("player rotate ", rotate_vec)
#		player_node.rotate(rotate_vec,1)
#		print("berfor ", player_node.transform)
#		print("computed thingydyd ",player_node.transform.basis.rotated(rotate_vec, PI))
		var look_at_point = camera_node.global_transform*Vector3(0,0,-1)
		player_node.global_transform.basis = player_node.global_transform.basis.rotated(rotate_vec, PI)
#		camera_node.gimbal_rotation_degrees.y *= -1
		camera_node.look_at_point(look_at_point)
#		print("atfer ", player_node.transform)
#		camera_node.rotate_d(180)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
