extends Node
#this node represents the logic utilities for our network protocol
class_name NetworkUtils

enum PacketType {
	ACTION_PRESS=0,
	CAMERA,
	STATE_POSITION, #server updates client position
	STATE_NODE, #server updates client node
	STATE_MISC #server updates client THING
	ACTION_RELEASE = 255
}
#generates a position packet from the server
func gen_packet_state_position(pos : Vector3)->PoolByteArray:
	var ret_val : PoolByteArray
	ret_val.append(PacketType.STATE_POSITION)
	ret_val.append_array(encode_int_64(OS.get_unix_time()))
	ret_val.append_array(encode_vec3(pos))
	return ret_val
#gets the time sent from a position packet from the server
func get_packet_POSITION_STATE_time(pack : PoolByteArray)->int:
	return decode_int_64(pack.subarray(1,8))
func get_packet_POSITION_STATE_position(pack : PoolByteArray)->Vector3:
	return decode_vec3(pack.subarray(9,-1))
func get_packet_type(pack : PoolByteArray)->int:
	return pack[0]
func get_packet_action(pack : PoolByteArray)->String:
	var data = get_packet_data(pack)
	var s : StreamPeerBuffer = StreamPeerBuffer.new()
	s.data_array = data
	s.get_float()
	s.get_float()
	s.get_float()
	return decode_action(s.data_array.subarray(s.get_position(),-1))

#syntactic sugar to return the camera position from a packet action
func get_packet_action_camera(pack : PoolByteArray)->Vector3:
	return get_packet_camera(pack)

func get_packet_action_pressed(pack : PoolByteArray)->bool:
	return get_packet_type(pack) == PacketType.ACTION_PRESS

func get_packet_actionEvent(packet : PoolByteArray)->InputEventAction:
	var actionEvent : InputEventAction = InputEventAction.new()
	actionEvent.pressed = get_packet_action_pressed(packet)
	actionEvent.action = get_packet_action(packet)
	return actionEvent
func gen_packet_action(gimbal : Vector3,action : String,pressed : bool)->PoolByteArray:
	var ret_val : PoolByteArray
	if pressed:
		ret_val.append(PacketType.ACTION_PRESS) 
	else:
		ret_val.append(PacketType.ACTION_RELEASE)
	
	ret_val.append_array(encode_vec3(gimbal))
	ret_val.append_array(encode_action(action))
	return ret_val
func gen_packet_camera(gimbal : Vector3)->PoolByteArray:
	var ret_val : PoolByteArray
	ret_val.append(PacketType.CAMERA)
	ret_val.append_array(encode_vec3(gimbal))
	return ret_val
func get_packet_camera(pack : PoolByteArray)->Vector3:
	return decode_vec3(get_packet_data(pack))
func get_packet_data(packet : PoolByteArray)->PoolByteArray:
	return packet.subarray(1,-1)
#REGION: Encoding functions
#any functon that is used to convert local data to network data
#and vice versa
func encode_action(act : String)->PoolByteArray:
	return act.to_utf8()
func decode_action(bytes : PoolByteArray)->String:
	return bytes.get_string_from_utf8()
func encode_float(f : float)->PoolByteArray:
	var s : StreamPeerBuffer = StreamPeerBuffer.new()
	s.put_float(f)
	return s.data_array

func decode_float(data : PoolByteArray)->float:
	var s : StreamPeerBuffer = StreamPeerBuffer.new()
	s.data_array = data
	return s.get_float()
func encode_vec3(vec : Vector3)->PoolByteArray:
	var ret_val : PoolByteArray
	ret_val.append_array(encode_float(vec.x))
	ret_val.append_array(encode_float(vec.y))
	ret_val.append_array(encode_float(vec.z))
	return ret_val
func decode_vec3(data : PoolByteArray):
	var s : StreamPeerBuffer = StreamPeerBuffer.new()
	var ret_val : Vector3 = Vector3(0,0,0)
	s.data_array = data
	ret_val.x = s.get_float()
	ret_val.y = s.get_float()
	ret_val.z = s.get_float()
	return ret_val
#encodes a 64 bit integer (8 byte integer)
func encode_int_64(data : int)->PoolByteArray:
	var ret_val : PoolByteArray
	for i in range(0,8):
		#get the lower bytes of the data
		var lower_bytes = data % 256
		#append them to the array
		ret_val.append(lower_bytes)
		#remove the lower bytes from the data
		data = (data - lower_bytes)/256	
	return ret_val
#decodes a 64 bit integer (8 byte integer)
func decode_int_64(pack : PoolByteArray)->int:
	var ret_val : int
	for i in range(0,8):
		#TODO: I do not like that pow converts to float and then back
		ret_val += pack[i]*pow(256,i)
	return ret_val
