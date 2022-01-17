extends MovementNode

#this script is a generic script inteanded to be overloaded
#Position based movements

class_name PositionMoveNode

func _ready():
	add_to_group("PositionMoveNode")


export(Vector3) var delta_position : Vector3 = Vector3(0,0,0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func update_position():
	get_player().transform.origin += delta_position
