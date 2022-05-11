#anything that moves :)
extends KinematicBody

class_name Entity

var entity_id : int = 0
func get_entity_id()->int:
	return entity_id
func get_entity_type()->int:
	return -1

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("Entity")
	if Global.network_mode == Global.NETWORK_MODE.SERVER:
		entity_id = Global.entity_id
	print("[entity.gd] adding entity with id " + str(entity_id))
