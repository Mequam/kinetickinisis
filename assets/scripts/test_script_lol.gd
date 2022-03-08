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

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
