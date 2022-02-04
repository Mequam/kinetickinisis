extends Node
#this is the generic server node not 
#inteanded to be used with any game in particular
#and taken prety much straight from the gd wiki

# server.gd
export(String) var bind_addr : String = "*"
export(int) var port : int = 2644
var server := UDPServer.new()
var peers = []

signal connection_available

#default add connection that we run when we recive an available connection
func _on_connection_available():
	var peer : PacketPeerUDP = server.take_connection()
	var pkt = peer.get_packet()
	print("Accepted peer: %s:%s" % [peer.get_packet_ip(), peer.get_packet_port()])
	print("Received data: %s" % [pkt.get_string_from_utf8()])
	# Reply so it knows we received the message.
	peer.put_packet(pkt)
	# Keep a reference so we can keep contacting the remote peer.
	peers.append(peer)

func _ready():
	print("[*] starting server")
	server.listen(port,bind_addr)

#the behavior we perform for all peers
func iterate_peers_behavior(peer)->void:
	pass
#iterates our desired behavior for known peers
func iterate_peers()->void:
	for peer in peers:
		iterate_peers_behavior(peer)
func _process(delta):
	server.poll() # Important!
	if server.is_connection_available():
		emit_signal("connection_available")
