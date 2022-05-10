extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var encoder = NetworkUtils.new()
	var def : Vector3 = Vector3(0.05,0.1,PI)
	print(encoder.decode_float(encoder.encode_float(1.5)))
	print(encoder.decode_vec3(encoder.encode_vec3(Vector3(100,2,3))))
	
	print(encoder.get_packet_action(encoder.gen_packet_action(def,"jump no u",true)))
	
	print(encoder.get_packet_action_pressed(encoder.gen_packet_action(def,"jump no u",true)))
	print(encoder.get_packet_actionEvent(encoder.gen_packet_action(def,"jump no u",true)))
	print(encoder.get_packet_action_camera(encoder.gen_packet_action(def,"jump no u",true)))


	print("\n\nnext test!")
	
	
	print(encoder.decode_int_64(encoder.encode_int_64(9999)))
	print(OS.get_unix_time())
	var pack = encoder.gen_packet_state_position(Vector3(0,1,2))
	print(encoder.get_packet_POSITION_STATE_time(pack))
	print(encoder.get_packet_POSITION_STATE_position(pack))
	 
	var test2 = MovementNodeUtils.new()
	print(test2.get_movement_node_paths())


	print(encoder.decode_data_packet(encoder.gen_data_packet(false)))
	
	
	print("BEGIN STATE PACKET TEST")
	var state_packet = encoder.gen_node_state_packet(0,"test",Vector3(0,0,-400))
	print(encoder.get_node_state_node_id(state_packet))
	print(encoder.get_node_state_attr(state_packet))
	print(encoder.get_node_state_data(state_packet))
	print(encoder.get_node_state_dict(encoder.gen_node_state_packet_from_dict({"node_id":1,"attr":"test","data":10000})))
	print("END STATE PACKET TEST")
	
	
	print("BEGIN SUPER STATE PAKCET TEST....ITS SUPER")
	state_packet = encoder.gen_super_state_node(0,true,10)
	print(encoder.get_super_state_node_id(state_packet))
	print(encoder.get_super_state_equiped(state_packet))
	print(encoder.get_super_state_idx(state_packet))
	print("END SUPER STATE PACKET TEST")
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
