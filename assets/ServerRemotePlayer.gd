extends Player
#this class represents the servers view of the player
#it recives input networed from networked nodes and
#uses that input to generate events for the given nodes

class_name ServerRemotePlayer

#represents a connection back to the player that controls us
var peer : PacketPeerUDP
#a list of input actions that the remote player has down
var down_input_actions : Dictionary = {}

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

#WE DO NOT do UI
func display_circleUI(arg):
	pass

func overload_process(delta):
	.overload_process(delta)
	#if we recive a remote input turn it into a local input we can use
	if peer and peer.get_available_packet_count() > 0:
		var packet = peer.get_packet()
		if peer.get_packet_error() == OK:
			var pk_type : int = netUtils.get_packet_type(packet)
			if pk_type == netUtils.PacketType.ACTION_PRESS or pk_type == netUtils.PacketType.ACTION_RELEASE:
				var actionEvent = netUtils.get_packet_actionEvent(packet)
				print("recived " + actionEvent.action)
				print("presed " + str(actionEvent.is_pressed()))
				if not actionEvent.pressed and down_input_actions.has(actionEvent.action):
					down_input_actions.erase(actionEvent.action)
				else:
					down_input_actions[actionEvent.action] = true
				.overload_input(actionEvent)
			elif pk_type == netUtils.PacketType.CAMERA:
				(get_cam() as PlayerCamera).gimbal_rotation_degrees = netUtils.get_packet_camera(packet)
