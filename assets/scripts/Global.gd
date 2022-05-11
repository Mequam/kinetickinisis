#this script contains global things
#its named global, duh
extends Node

enum NETWORK_MODE {
	CLIENT,
	SERVER
}
#determines what mode the game is running in
var network_mode : int = NETWORK_MODE.CLIENT

#counter for the number of entities that we have on the
#server
var entity_id : int = 0 setget set_entity_id,get_entity_id
func set_entity_id(val : int)->void:
	pass
func get_entity_id()->int:
	entity_id += 1
	return entity_id
func read_entity_id()->int:
	return entity_id
