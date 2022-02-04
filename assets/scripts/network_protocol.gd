extends Node
#this node represents the logic utilities for our network protocol
class_name NetworkUtils

enum PacketType {
	ACTION_PRESS,
	CAMERA,
	STATE,
	ACTION_RELEASE = 256
}
#REGION: Packet Syntax Functions
#any function that gets a property of the packets themselfs
func get_packet_type(pack : PoolByteArray)->int:
	return pack[0]
func get_packet_action(pack : PoolByteArray)->String:
	return decode_action(get_packet_data(pack).subarray(1,-1))
func get_packet_action_pressed(pack : PoolByteArray)->bool:
	return get_packet_data(pack)[1] == 1
func get_packet_actionEvent(packet : PoolByteArray)->InputEventAction:
	var actionEvent : InputEventAction = InputEventAction.new()
	actionEvent.action = get_packet_action(packet)
	actionEvent.pressed = get_packet_action_pressed(packet)
	return actionEvent
func gen_packet_action(action : String,pressed : bool)->PoolByteArray:
	var ret_val : PoolByteArray
	ret_val.append(PacketType.ACTION_PRESS if pressed else PacketType.ACTION_RELEASE)
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
