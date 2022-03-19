extends Node
#this node represents the logic utilities for our network protocol
class_name NetworkUtils

enum PacketType {
	ACTION_PRESS=0,
	CAMERA,
	STATE_START,
	STATE_POSITION, #server updates client position
	STATE_NODE, #server updates client node
	SUPER_STATE_NODE, #server tells the client that it has (or does not have) NODE
	SUPER_STATE_NODE_DELIMITER,
	STATE_END,
	TIME_SYNC, #syncs time between the client and the server using delta time
	ACTION_RELEASE = 255
}


func gen_super_state_node(node_id : int, node_equiped : bool)->PoolByteArray:
	var ret_val : PoolByteArray
	ret_val.append(PacketType.SUPER_STATE_NODE) #we are telling you about a node
	ret_val.append(node_id) #this is the node
	ret_val.append_array(encode_bool(node_equiped)) #is it equipd or not?
	return ret_val
#generates a super state node packet
#indicates to the client that it is about to recive node state
func gen_super_node_state_start(start : bool)->PoolByteArray:
	var ret_val : PoolByteArray
	ret_val.append(PacketType.SUPER_STATE_NODE_DELIMITER)
	ret_val.append_array(encode_bool(start))
	return ret_val
func gen_time_sync()->PoolByteArray:
	var ret_val : PoolByteArray
	ret_val.append(PacketType.TIME_SYNC)
	ret_val.append_array(encode_int_64(OS.get_ticks_usec()))
	return ret_val
func get_time_sync(packet : PoolByteArray)->int:
	return decode_int_64(packet.subarray(1,-1))
func get_state_time_start_or_end(pack : PoolByteArray)->int:
	return decode_int_64(pack.subarray(1,-1))
func gen_start_state_packet(offset_time : int = 0)->PoolByteArray:
	var ret_val : PoolByteArray
	ret_val.append(PacketType.STATE_START)
	ret_val.append_array(encode_int_64(OS.get_ticks_usec()+offset_time))
	return ret_val
func gen_end_state_packet(offset_time : int = 0)->PoolByteArray:
	var ret_val : PoolByteArray
	ret_val.append(PacketType.STATE_END)
	ret_val.append_array(encode_int_64(OS.get_ticks_usec()+offset_time))
	return ret_val
#generates a node state packet from a node_state_dictionary
func gen_node_state_packet_from_dict(node_state_dict : Dictionary)->PoolByteArray:
	if node_state_dict.has_all(["attr","node_id","data"]):
		return gen_node_state_packet(node_state_dict["node_id"],
								node_state_dict["attr"],
								node_state_dict["data"])
	var ret_val : PoolByteArray
	return ret_val
func get_node_state_dict(pack : PoolByteArray)->Dictionary:
	var ret_val = {}
	ret_val["node_id"] = get_node_state_node_id(pack)
	ret_val["attr"] = get_node_state_attr(pack)
	ret_val["data"] = get_node_state_data(pack)
	return ret_val
#generates a packet to update the node state
func gen_node_state_packet(node_id : int, attr : String, data)->PoolByteArray:
	var ret_val : PoolByteArray
	ret_val.append(PacketType.STATE_NODE)
	ret_val.append(node_id)
	ret_val.append(attr.length())
	ret_val.append_array(gen_data_packet(attr))
	ret_val.append_array(gen_data_packet(data))
	return ret_val
#returns the node id that a node state packet is destined for
func get_node_state_node_id(pack : PoolByteArray)->int:
	return pack[1]
func get_node_state_attr(pack : PoolByteArray)->String:
	if pack[2] < pack.size():
		return pack.subarray(3,4+pack[2]).get_string_from_ascii()
	return ""
func get_node_state_data(pack : PoolByteArray):
	if pack[2] < pack.size():
		return decode_data_packet(pack.subarray(pack[2]+5,-1))
	return null
#returns the data from a data packet
func decode_data_packet(pack : PoolByteArray):
	match pack[0]:
		TYPE_INT:
			return decode_int_64(pack.subarray(1,8))
		TYPE_STRING:
			var str_len : int = pack[1]
			if pack.size() - 2 <= str_len*4:
				return pack.subarray(2,-1).get_string_from_ascii()
			return ""
		TYPE_BOOL:
			return decode_bool(pack.subarray(1,1))
		TYPE_VECTOR3:
			return decode_vec3(pack.subarray(1,-1))
#generates a packet containing variable data
func gen_data_packet(data)->PoolByteArray:
	var ret_val : PoolByteArray
	ret_val.append(typeof(data))
	match typeof(data):
		TYPE_INT:
			ret_val.append_array(encode_int_64(data))
		TYPE_STRING:
			#append the length of the string for deconding
			ret_val.append((data as String).length())
			#append the string data for decoding
			ret_val.append_array((data as String).to_ascii())
		TYPE_BOOL:
			#use 255 for network safty
			ret_val.append(255 if data else 0)
		TYPE_VECTOR3:
			ret_val.append_array(encode_vec3(data))
	return ret_val
	
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
	var sb : StreamPeerBuffer = StreamPeerBuffer.new()
	sb.put_64(data)
	ret_val.append_array(sb.data_array)
	return ret_val

#decodes a 64 bit integer (8 byte integer)
func decode_int_64(pack : PoolByteArray)->int:
	var sb : StreamPeerBuffer = StreamPeerBuffer.new()
	sb.data_array = pack
	return sb.get_64()

func encode_bool(val : bool)->PoolByteArray:
	var ret_val : PoolByteArray
	ret_val.append(255 if val else 0)
	return ret_val
func decode_bool(pack : PoolByteArray)->bool:
	return pack[0] == 255
