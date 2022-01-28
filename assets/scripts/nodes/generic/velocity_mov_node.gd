extends MovementNode

#this script is a generic script inteanded to be overloaded
#velocity movements

class_name VelocityMoveNode

export(float, -1.0, 0) var slide_threshold : float = -0.001
export(bool) var can_slide : bool = false

func _ready():
	add_to_group("VelocityMoveNode")

export(Vector3) var velocity : Vector3 = Vector3(0,0,0) setget set_vel,get_vel
func set_vel(val : Vector3)->void:
	velocity = val
func get_vel()->Vector3:
	return velocity
func on_player_collided(collided):
#	print("COLLISION SIGNALED!")
	velocity = Vector3(0,0,0)

func overload_process(delta)->void:
	if  player_node.collision and velocity.dot(player_node.collision.normal) < slide_threshold:
		if can_slide:
			velocity = velocity - velocity.project(player_node.collision.normal)
		else:
			velocity = Vector3(0,0,0)
	.overload_process(delta)
