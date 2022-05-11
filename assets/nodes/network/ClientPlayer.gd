extends Player
#this is a player class that sends it's inputs to a given server
#in addition to predicting its location on the client side of the connection

class_name ClientPlayer

export(String) var server_ip : String = "127.0.0.1"
export(int) var port : int = 2644
export(int) var client_id : int = 0

var udp := PacketPeerUDP.new()
var connected = false
var netUtils : NetworkUtils = NetworkUtils.new()

#circular buffer we store our state in
var circle_buff : CircularBuffer = CircularBuffer.new(20)
var rewind_thread : Thread
func overload_ready():
	udp.set_dest_address(server_ip,port)
	udp.connect_to_host(server_ip,port)
	send_server_packet(netUtils.gen_time_sync())
	send_server_packet(netUtils.gen_time_sync())
	send_server_packet(netUtils.gen_time_sync())
	last_cam_gimbal = get_cam().gimbal_rotation_degrees
	(get_cam() as PlayerCamera).connect("rotated_cam",self,"_on_camera_update")
	rewind_thread = Thread.new()
	rewind_thread.start(self,"_thread_rewind",[circle_buff,error])
	.overload_ready()

#updates the circular buffer WITHOUT re-winding behavior
#basically just append our position and velocity to the buffer
var id : int = 0
func update_circular_buffer(vel : Vector3)->void:
	circle_buff.push([OS.get_ticks_usec(),transform.origin,vel,id])
	id += 1

var error : Dictionary = {}
func call_rewind(position : Vector3,time : int):
	error["position"] = position
	error["time"] = time
	emit_signal("start_rewind")
func clear_circle_buff(circle : CircularBuffer,time :int)->void:
	for i in range(0,circle.length()):
		if circle.read(i) != null and circle.read(i)[0] < time:
			circle.clear(i)
func rewind_start_idx(circle : CircularBuffer,time : int)->int:
	var circle_len = circle_buff.length()
	#this is not the most efficient way to do this but it works for debugging
	var i : int = 1
	var min_idx : int = 0
	var min_time : int = abs(circle_buff.read(0)[0]-time) if circle_buff.read(0) != null else 0
	while i < circle_len:
		if circle_buff.read(i) != null:
			var delta : int = abs(circle_buff.read(i)[0] - time)
			if min_time == 0 or delta < min_time:
				min_idx = i
				min_time = delta
		i+=1
	return min_idx
#	for j in range(0,circle_len):
#		#if the time of our data point is less than error time, we found our error
#		if circle_buff.read(i-j)!=null and circle_buff.read(i-j)[0] < time:
#			return i-j
#	print("returning 0")
	return 0
var rewind_error = {"time":0,"position":Vector3(0,0,0)}
var error_delta : Vector3
var set_error_delta : bool = false

signal start_rewind

func _thread_rewind(data_arr):
	var circle : CircularBuffer = data_arr[0]
	var error : Dictionary = data_arr[1]
	while true:
		yield(self,"start_rewind")
		var idx : int = rewind_start_idx(circle,error["time"])
		var circle_error = circle.read(idx)

		if circle_error != null:
			if circle.read(idx-1) != null and circle.read(idx+1) != null:
				pass
				#print(str(circle_buff._buffer_pointer) + " " + str(idx) + " "+ str(circle.read(idx-1)[0])+ " " + str(circle_error[0]) + " "+ str(circle.read(idx + 1)[0]) + " : " + str(error["time"]))
			var delta_time : float = float(abs(error["time"]-circle_error[0]))/1e+6
			
			#print("Was: " + str(circle_error[1]) + " Should: " + str(error["position"]) + " delta " + str(error["position"]-circle_error[1]))
#			print("Was @: " + str(circle_error[0]) + " Correct @:" + str(error["time"]))
#			print("time delta: " + str(delta_time))
#			print("currently: " + str(OS.get_ticks_usec()))
#			print(float(circle_error[0]-OS.get_ticks_usec())/100000)
			#print("velocity: " + str(circle_error[2]))
			
			
			error_delta = (error["position"]-(circle_error[1]))
			set_error_delta = true
			clear_circle_buff(circle_buff,error["time"])
#sends a packet of information to the server
func send_server_packet(data : PoolByteArray)->void:
	udp.put_packet(data)

func overload_input(event):
	if self.get_do_player_input():
		for act in InputMap.get_actions():
			if InputMap.action_has_event(act,event) and (Input.is_action_just_pressed(act) or Input.is_action_just_released(act)):
				send_server_packet(netUtils.gen_packet_action(get_cam().gimbal_rotation_degrees,act,event.is_pressed()))
	.overload_input(event)
#if this is true we are building a state packet from the server
var appending_state : bool = false

#reference to the state_dictionary that we are appending to
var state_dict : Dictionary
#creates a new state dictionary
func empty_state_dict()->void:
	state_dict = {"node_states":[]}
#checks the state with our circular buffer and starts the 
#re-wind thread
func pop_circular_buffer()->void:
	#sync the node state
	sync_state(state_dict)
	#start the re-wind thread
	call_rewind(state_dict["position"],state_dict["time"])
	empty_state_dict()

var interpolation_point : Vector3
export(float) var interpolation_speed : float = 10
func do_interpolate()->bool:
	return transform.origin.distance_squared_to(interpolation_point) > 2

func add_child_at(node : Node,idx : int):
	add_child(node)
	move_child(node,idx)

##we do NOT interact with nodes ourselfs,
#instead we ask the server to do that for us
#ask for an equip
func move_node_into_movements(node):
	udp.put_packet(
		netUtils.gen_client_equip_node(
			node.get_movement_id()
			)
		)
#ask for a dequip
func move_node_into_inventory(node):
	udp.put_packet(
		netUtils.gen_client_dequip_node(
			node.get_movement_id()
			)
	)
	
#spawns a given entity at a given position
func spawn_entity(type_id : int,entity_id : int,pos : Vector3):
	print("spawning entity at " + str(pos))
	var entity
	match type_id:
		netUtils.EntityType.PLAYER:
			#add a network entity to the game
			entity = load("res://assets/nodes/PlayerPlaceHolder.tscn").instance()
			entity.transform.origin = pos
			get_parent().add_child(entity)
	print("setting entity id to " + str(entity_id))
	entity.entity_id = entity_id

func overload_physics_process(delta):
	if set_error_delta:
		interpolation_point = transform.origin + error_delta
		set_error_delta = false
	if do_interpolate():
		transform.origin = transform.origin.linear_interpolate(interpolation_point,delta*interpolation_speed)
	var data : Dictionary = .overload_physics_process(delta)
	update_circular_buffer(data["vel"])
	#this should only happen once in theory, but just in case
	#two or more packets get buffered
	while udp.get_available_packet_count() > 0:
		var packet = udp.get_packet()
		if udp.get_packet_error() == OK:
			var pack_type : int = netUtils.get_packet_type(packet)
			match pack_type:
				netUtils.PacketType.ENTITY_UPDATE:
					print("recived entity update!")
					#tell all of our net entities there is an update
					get_tree().call_group("NetworkEntity","update_entity_position_state",
						netUtils.get_entity_state_id(packet),
						netUtils.get_entity_state_position(packet),
						netUtils.get_entity_state_velocity(packet)
						)
				netUtils.PacketType.SPAWN_ENTITY:
					print("[client.gd] recived entity id " + str(netUtils.get_spawn_entity_id(packet)))
					spawn_entity(netUtils.get_spawn_entity_type(packet),
								netUtils.get_spawn_entity_id(packet),
								netUtils.get_spawn_entity_position(packet))
				netUtils.PacketType.STATE_POSITION:
					state_dict["position"] = netUtils.get_packet_POSITION_STATE_position(packet)
				netUtils.PacketType.STATE_START:
					if not appending_state:
						empty_state_dict()
					state_dict["time"] = netUtils.get_state_time_start_or_end(packet)
					appending_state = true
				netUtils.PacketType.STATE_END:
					if appending_state:
						pop_circular_buffer()
					appending_state = false
				netUtils.PacketType.STATE_NODE:
					state_dict["node_states"].append(netUtils.get_node_state_dict(packet))
				netUtils.PacketType.SUPER_STATE_NODE:
					
					#TODO: clean this :)
					
					var movement_node_id : int = netUtils.get_super_state_node_id(packet)
					var equip_state  = node_inventory_state(movement_node_id)
					
					#true indicates we go into active inventory
					#false is inactive
					var node_destination = netUtils.get_super_state_equiped(packet)
					
					if equip_state is Node: #its in the inventory, equip it
						if node_destination:
							.move_node_into_movements(equip_state)
							get_node(movement_node_manager_node).move_child(equip_state,netUtils.get_super_state_idx(packet))
						#else:
							#if we need to move the node into inactive and it is ALREADy incactive we do nothing in this case
					elif equip_state >= 0: #it is active
						if node_destination: #we want it active at a specific spot
							.move_node_into_movements_at(
								get_node(movement_node_manager_node).get_child(equip_state),
								netUtils.get_super_state_idx(packet)
								)
						else: #we want it in the inventory
							.move_node_into_inventory(
								get_node(movement_node_manager_node).get_child(equip_state)
								)
					else: #the node is non existent
						#a new node instance to add to the child
						var to_add : Node = MovementNodeUtils.get_movment_node_instance(movement_node_id)
						if node_destination: #we are active
							.move_node_into_movements_at(to_add,netUtils.get_super_state_idx(packet))
						else: #we are inactive
							.move_node_into_inventory(to_add)
							
	return data
func _ready():
	for node in get_node(movement_node_manager_node).get_children():
		print(node.get_display_name() + " " + str(node.get_movement_id()))
#test function for a checkpoint
#this will be multithreaded in the future
func sync_state(state_dict):
	for state in state_dict["node_states"]:
		for node in get_movement_nodes():
			#theres an if statement in this function
			#that prevents it from running if the state is not
			#for that node
			node.sync_state(state)
	#snaps the player to the error position
	#transform.origin = state_dict["position"]

#buffered so we can tell if we want to send a network packet
var last_cam_gimbal : Vector3 = Vector3(0,0,0)
func send_cam_packet(gimbal : Vector3)->void:
	last_cam_gimbal = gimbal
	send_server_packet(netUtils.gen_packet_camera(gimbal))
	
func _on_NetworkClock_timeout():
	var gimb : Vector3 = get_cam().gimbal_rotation_degrees
	if last_cam_gimbal != gimb:
		send_cam_packet(gimb)
