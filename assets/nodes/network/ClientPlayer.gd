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
	.overload_ready()

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
					print("UPDATING POSITION")
					var new_pos : Vector3 = netUtils.get_packet_POSITION_STATE_position(packet)
					if transform.origin.distance_squared_to(new_pos) > 0:
						transform.origin = new_pos
func _ready():
	print("test")

#buffered so we can tell if we want to send a network packet
var last_cam_gimbal : Vector3 = Vector3(0,0,0)
func send_cam_packet(gimbal : Vector3)->void:
	last_cam_gimbal = gimbal
	send_server_packet(netUtils.gen_packet_camera(gimbal))
	
func _on_NetworkClock_timeout():
	var gimb : Vector3 = get_cam().gimbal_rotation_degrees
	if last_cam_gimbal != gimb:
		send_cam_packet(gimb)
