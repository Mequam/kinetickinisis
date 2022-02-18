extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var encoder = NetworkUtils.new()
	print(encoder.decode_float(encoder.encode_float(1.5)))
	print(encoder.decode_vec3(encoder.encode_vec3(Vector3(100,2,3))))
	print(encoder.get_packet_action(encoder.gen_packet_action("jump no u",true)))
	print(encoder.get_packet_action_pressed(encoder.gen_packet_action("jump no u",true)))
	print(encoder.get_packet_actionEvent(encoder.gen_packet_action("jump no u",true)))
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
