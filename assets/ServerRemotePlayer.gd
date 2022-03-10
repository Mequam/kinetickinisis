extends Player
#this class represents the servers view of the player
#it recives input networed from networked nodes and
#uses that input to generate events for the given nodes

class_name ServerRemotePlayer

#represents a connection back to the player that controls us
var peer : PacketPeerUDP
#a list of input actions that the remote player has down
var down_input_actions : Dictionary = {}
var con_time : int
var netUtils : NetworkUtils = NetworkUtils.new()

func get_vector(a : String,b : String,c: String,d:String,default_return : Vector2 = Vector2(0,0))->Vector2:
	if not self.do_player_input:
		return default_return
	return Vector2(numeric_action_in_arr(b)-numeric_action_in_arr(a),numeric_action_in_arr(d)-numeric_action_in_arr(c))

func numeric_action_in_arr(act : String)->float:
	if act in down_input_actions:
		return 1.0
	return 0.0

#theres no need to check UI to lock up input because we
#have no UI
func get_do_player_input()->bool:
	return do_player_input

#we take NO input from the player
func overload_input(event):
	pass
#instead all of our inputs come from the network node through
#this function in custom generated action events
func recive_networked_input(event):
	.overload_input(event)

var state_timer : Timer
func overload_ready()->void:
	state_timer = Timer.new()
	state_timer.connect("timeout",self,"_send_state")
	state_timer.autostart = true
	#this is set to 1 second for the time bieng
	state_timer.wait_time = 0.05
	
	add_child(state_timer)
	
	.overload_ready()

#generates the state of this client to send to the player
#TODO: generic state stuffz with nodes is not accounted for
func _get_state_packets():
	var ret_val = []
	#append the position packet to send
	for i in range(0,4):
		ret_val.append(netUtils.gen_start_state_packet(time_delta-con_time))
	
	ret_val.append(netUtils.gen_packet_state_position(transform.origin))
	
	#for each node that we have append the state of the node to a dictionary to send out
	for node in get_movement_nodes():
		for dict in node.get_state_dictionary_array():
			ret_val.append_array(netUtils.gen_node_state_packet_from_dict(dict))
	
	#append the terminating state packet 
	for i in range(0,5):
		ret_val.append(netUtils.gen_end_state_packet(time_delta-con_time))
	
	return ret_val

#sends the state of the server over to the client
func _send_state():
	print("sending state packet to the clinet!")
	if peer:
		for state in _get_state_packets():
			peer.put_packet(state)

#WE DO NOT do UI
func display_circleUI(arg):
	pass
var time_delta : int = 0
func overload_physics_process(delta):
	#if we recive a remote input turn it into a local input we can use
	if peer and peer.get_available_packet_count() > 0:
		var packet = peer.get_packet()
		if peer.get_packet_error() == OK:
			var pk_type : int = netUtils.get_packet_type(packet)
			if pk_type == netUtils.PacketType.ACTION_PRESS or pk_type == netUtils.PacketType.ACTION_RELEASE:
				(get_cam() as PlayerCamera).gimbal_rotation_degrees = netUtils.get_packet_camera(packet)
				var actionEvent = netUtils.get_packet_actionEvent(packet)
				if not actionEvent.pressed and down_input_actions.has(actionEvent.action):
					down_input_actions.erase(actionEvent.action)
				else:
					down_input_actions[actionEvent.action] = true
				.overload_input(actionEvent)
			elif pk_type == netUtils.PacketType.CAMERA:
				(get_cam() as PlayerCamera).gimbal_rotation_degrees = netUtils.get_packet_camera(packet)
			elif pk_type == netUtils.PacketType.TIME_SYNC:
				#this is the connection delta not the time delta between games
				time_delta = abs(con_time + netUtils.get_time_sync(packet) - OS.get_ticks_usec()+60000)
	.overload_physics_process(delta)
