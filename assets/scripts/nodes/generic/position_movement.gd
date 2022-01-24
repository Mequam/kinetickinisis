extends MovementNode

#this script is a generic script inteanded to be overloaded
#Position based movements

class_name PositionMoveNode

func _ready():
	add_to_group("PositionMoveNode")

#updates the players position, inteanded to be overloaded
func update_position()->void:
	pass
