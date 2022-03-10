extends Player
#this is a player class that sends it's inputs to a given server
#in addition to predicting its location on the client side of the connection

export(String) var server_ip : String = "127.0.0.1"
export(int) var port : int = 2644
export(int) var client_id : int = 0

var udp := PacketPeerUDP.new()
var connected = false
var netUtils : NetworkUtils = NetworkUtils.new()

#stores the position for a given time
var pos_list : Array = []

func overload_ready():
	udp.set_dest_address(server_ip,port)
	udp.connect_to_host(server_ip,port)
	last_cam_gimbal = get_cam().gimbal_rotation_degrees
	print("setting packet addr to " + server_ip +":"+str(port))
	(get_cam() as PlayerCamera).connect("rotated_cam",self,"_on_camera_update")
	
	circular_buffer.resize(60)
	
	.overload_ready()

#updates the circular buffer
func update_circular_buffer()->void:
	pass
#sends a packet of information to the server
func send_server_packet(data : PoolByteArray)->void:
	udp.put_packet(data)

func overload_input(event):
	if self.get_do_player_input():
		for act in InputMap.get_actions():
			if InputMap.action_has_event(act,event) and (Input.is_action_just_pressed(act) or Input.is_action_just_released(act)):
				print("sending action " + act + " " + str(event.is_pressed()))
				send_server_packet(netUtils.gen_packet_action(get_cam().gimbal_rotation_degrees,act,event.is_pressed()))
	.overload_input(event)
#if this is true we are building a state packet from the server
var appending_state : bool = false

#reference to the state_dictionary that we are appending to
var state_dict : Dictionary
#creates a new state dictionary
func empty_state_dict()->void:
	state_dict = {"node_states":[]}
#stores the state into our circular buffer
func pop_circular_buffer()->void:
	empty_state_dict()
func overload_physics_process(delta):
	.overload_physics_process(delta)
	#this should only happen once in theory, but just in case
	#two or more packets get buffered
	while udp.get_available_packet_count() > 0:
		var packet = udp.get_packet()
		if udp.get_packet_error() == OK:
			var pack_type : int = netUtils.get_packet_type(packet)
			print("recived " + str(pack_type) + " from the server")
			match pack_type:
				netUtils.PacketType.STATE_POSITION:
					state_dict["position"] = netUtils.get_packet_POSITION_STATE_position(packet)
				netUtils.PacketType.STATE_START:
					if not appending_state:
						empty_state_dict()
					appending_state = true
				netUtils.PacketType.STATE_END:
					if appending_state:
						sync_state(state_dict)
						pop_circular_buffer()
					appending_state = false
				netUtils.PacketType.STATE_NODE:
					state_dict["node_states"].append(netUtils.get_node_state_dict(packet))
func _ready():
	print("test")
#test function for a checkpoint
#this will be multithreaded in the future
func sync_state(state_dict):
	for state in state_dict["node_states"]:
		for node in get_movement_nodes():
			#theres an if statement in this function
			#that prevents it from running if the state is not
			#for that node
			node.sync_state(state)
	transform.origin = state_dict["position"]

#buffered so we can tell if we want to send a network packet
var last_cam_gimbal : Vector3 = Vector3(0,0,0)
func send_cam_packet(gimbal : Vector3)->void:
	last_cam_gimbal = gimbal
	send_server_packet(netUtils.gen_packet_camera(gimbal))
	
func _on_NetworkClock_timeout():
	var gimb : Vector3 = get_cam().gimbal_rotation_degrees
	if last_cam_gimbal != gimb:
		send_cam_packet(gimb)
