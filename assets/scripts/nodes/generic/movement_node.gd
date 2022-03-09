extends Node

#this is the generic movement node class inteanded to be overiden by subclasses only

class_name MovementNode
export(NodePath) var player_node_path : NodePath
export(String) var input_action setget set_input_action
export(Dictionary) var multi_input_actions = {"input_action":input_action} setget set_multi_input_actions
export(int, "Global", "Local", "Camera", "Custom") var coordinate_space
onready var player_node : Player = get_player()
onready var camera_node : PlayerCamera = get_cam()

var _movement_id : int = 0 setget set_movement_id,get_movement_id
func set_movement_id(val : int)-> void:
	pass
func get_movement_id()->int:
	return _movement_id

func get_display_name()->String:
	return "Movement Node"

func get_input_map()->Array:
	if not InputMap.has_action(input_action):
		return []
	return InputMap.get_action_list(input_action)
func get_input_string()->String:
	var input_maps = get_input_map()
	if input_maps == []:
		return "Unbound"
	var ret_val : String = ""
	for event in input_maps:
		ret_val += event.as_text() + " "
	return ret_val

func set_input_action(n_action):
	input_action = n_action
	multi_input_actions[multi_input_actions.keys()[0]] = input_action
	
func set_multi_input_actions(n_actions):
	multi_input_actions = n_actions
	input_action = multi_input_actions.values()[0]

#returns the player, which serves as a data hub
func get_player()->Player:
	if player_node is Player:
		return player_node
	if player_node_path.is_empty():
		#if we want to ensure this is a player ad code here
		return (get_parent().get_parent() as Player)
	return (get_node(player_node_path) as Player)


#syntactic sugar functions for getting stuffz
func get_cam()->Camera:
	return get_player().get_cam()
func get_transform()->Transform:
	return get_player().transform
func get_position()->Vector3:
	return get_player().transform.origin
func set_position(pos : Vector3)->void:
	get_player().transform.origin = pos
func apply_cam_transform(vec : Vector3) -> Vector3:
	return get_cam().global_transform*vec-get_cam().global_transform.origin

#if another movement node (or node class) is incompatable with this one
#the class and the name of the node should be listed here
var _class_comp : Array = []
var _node_comp : Array = []

#returns true if the two rays have a non null intersection
func array_intersects(arr1 : Array, arr2 : Array)->bool:
	for n in arr1:
		if arr2.has(n):
			return true
	return false
	
var mov_name : String setget set_mov_name,get_mov_name
func set_mov_name(val : String)->void:
	print("[WARNING] node tried to write to movement_name")
	pass
func get_mov_name()->String:
	return mov_name



#this function is run in the main ready but inteanded to be overloaded
#in child classes
func overload_ready()->void:
	pass
#called when the player collides with an object
func on_player_collided(collision):
	pass


#subscribes us to all input actions in the array and removes any other node that is 
#also subscribed to those actions
func demand_inputs(inputs : Array)->void:
	for action in inputs:
		for subscribed_nodes in player_node.get_action_subscribed_nodes(action):
			pass

#called when the node is added to the tree to subscribe
#to inputs required by the movement node
#this is inteanded to be overloaded by children
func subscribe_to_inputs()->void:
	pass

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("MovementNode")
	player_node.connect("collided",self,"on_player_collided")
	subscribe_to_inputs()
	var movUtils = MovementNodeUtils.new()
	_movement_id = movUtils.get_movement_node_paths().find(get_script().get_path())
	print(name.capitalize() + " ID:" + str(_movement_id))
	overload_ready()
	print(name.capitalize())
func overload_process(delta) -> void:
	pass
func _process(delta):
	overload_process(delta)
#returns true if we are compatable with the given node

func _player_input(event : InputEvent):
	pass

func check_incomp(mov_node)->bool:
	#godot makes checking if same type sad :(
	if mov_node.is_in_group("MovementNode"):
		return array_intersects(_class_comp,(mov_node as Node).get_groups()) or _node_comp.has((mov_node).get_movement_type)
	return false
func check_comp(mov_node)->bool:
	return not check_incomp(mov_node)
		
#convinence function that removes the node from the tree if the given node is incompatable
func remove_if_comp(mov_node)->void:
	if check_incomp(mov_node):
		remove_movement()

#removes the node from the tree and performs cleaning opeerations
func remove_movement():
	queue_free()
#to be overriden
func player_collided(col):
	pass
#called when the player script detects an input event we registered
#for
func on_player_input(event):
	pass

#syntactic sugar function to get an action from our action code
func code_to_action(code : int)->String:
	if player_node.input_map.has(self) and (code in player_node.input_map[self]):
		return player_node.input_map[self][code]
	return ""



#generic function inteanded to be overloaded that 
#generates any misclanious state that the nodes care about
func gen_state()->PoolByteArray:
	var ret_val : PoolByteArray
	return ret_val
#this is a gneric function inteanded to set the state
#of a node from a network packet
#we should be able to general case it here,
#but well see in the future
func set_state(net_state : PoolByteArray)->void:
	pass
