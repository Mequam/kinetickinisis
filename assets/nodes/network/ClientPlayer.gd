extends Player
#this is a player class that sends it's inputs to a given server
#in addition to predicting its location on the client side of the connection

export(String) var server_ip : String = "127.0.0.1"
export(int) var port : int = 2644
export(int) var client_id : int = 0

var udp := PacketPeerUDP.new()
var connected = false
var netUtils : NetworkUtils = NetworkUtils.new()

func overload_ready():
	udp.set_dest_address(server_ip,port)
	udp.connect_to_host(server_ip,port)
	print("setting packet addr to " + server_ip +":"+str(port))
	(get_cam() as PlayerCamera).connect("rotated_cam",self,"_on_camera_update")
	
	.overload_ready()
func overload_input(event):
	if self.get_do_player_input():
		for act in InputMap.get_actions():
			if InputMap.action_has_event(act,event) and (Input.is_action_just_pressed(act) or Input.is_action_just_released(act)):
				print("sending action " + act + " " + str(event.is_pressed()))
				udp.put_packet(netUtils.gen_packet_action(act,event.is_pressed()))
	.overload_input(event)

func send_state()->void:
	pass

func overload_physics_process(delta):
	.overload_physics_process(delta)
	#update the position of the object
	
	#if udp.get_available_packet_count() > 0:
	#	#pkt.get_string_from_utf8()
	#	print("Connected: %s" % udp.get_packet().get_string_from_utf8())
	#	connected = true
	send_state()
func _ready():
	print("test")
#called when the player camera updates where it looks
func _on_camera_update()->void:
	print("sending camera packet")
	#alert the server that we have a new camera rotation
	udp.put_packet(netUtils.gen_packet_camera(get_cam().gimbal_rotation_degrees))
