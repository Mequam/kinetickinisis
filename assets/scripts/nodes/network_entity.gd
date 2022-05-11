#this class is an entity that updates its position from a server
extends Entity

class_name NetEntityIndicator

var target_pos : Vector3
var velocity : Vector3

func update_entity_position_state(id : int, pos : Vector3, vel : Vector3):
	if id == get_entity_id():
		target_pos = pos
		velocity = vel

#generic entty state, inteanded to be overiden
func update_entity_state(data : PoolByteArray):
	pass

func _process(delta):
	transform.origin = transform.origin.linear_interpolate(target_pos,delta*10)
	target_pos += velocity
	
func _ready():
	add_to_group("NetworkEntity")
