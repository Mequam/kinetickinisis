extends Spatial

func _ready():
	print("READY!")
func _on_ServerNode_connection_available():
	print("[*] recived connection!")
	$remote.con_time = OS.get_ticks_usec()
	$remote.peer = $ServerNode.server.take_connection()
