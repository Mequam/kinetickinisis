extends MovementNode

#this script is a generic script inteanded to be overloaded
#velocity movements

class_name VelocityMoveNode

func _ready():
	add_to_group("VelocityMoveNode")

export(Vector3) var velocity : Vector3 = Vector3(0,0,0) setget set_vel,get_vel
func set_vel(val : Vector3)->void:
	velocity = val
func get_vel()->Vector3:
	return velocity
