extends Spatial
#this node is a server conenction node
#it is inteanded to add players to the game
#and manage incoming connections in the scene
#its position is the spawn point

class_name ServerConnectionNode

# server.gd
export(String) var bind_addr : String = "*"
export(int) var port : int = 2644
var server := UDPServer.new()
var peers = [] #reference of our connections
var PLAYER_MAX : int = -1
var netUtils = NetworkUtils.new()


signal connection_available

#default add connection that we run when we recive an available connection
func _on_connection_available():
	print("[*] RECIVED CONNECTION")
	
	var peer : PacketPeerUDP = server.take_connection()
	
	#record con time ASAP
	var con_time : float = OS.get_ticks_usec()
	
	for p in peers:
		var to_send = netUtils.gen_spawn_entity(netUtils.EntityType.PLAYER,Global.read_entity_id() + 1,transform.origin)
		p.put_packet(to_send)
	
	for e in get_tree().get_nodes_in_group("Entity"):
		var to_send = netUtils.gen_spawn_entity(e.get_entity_type(),e.get_entity_id(),e.transform.origin)
		peer.put_packet(to_send)
		
	# Keep a reference for broadcast so we can keep contacting the remote peer.
	peers.append(peer)
	
	#load and instance a new player
	var server_player_reference : ServerRemotePlayer = (load("res://assets/nodes/network/ServerRemotePlayer.tscn") as PackedScene).instance()
	
	server_player_reference.con_time = con_time
	server_player_reference.transform.origin = transform.origin
	server_player_reference.peer = peer
	
	get_parent().add_child(server_player_reference)

func _ready():
	print("[*] starting server")
	connect("connection_available",self,"_on_connection_available")
	server.listen(port,bind_addr)
	
	#WE ARE THE SERVER
	Global.network_mode = Global.NETWORK_MODE.SERVER
	
#the behavior we perform for all peers
func iterate_peers_behavior(peer)->void:
	pass

#iterates our desired behavior for known peers
func iterate_peers()->void:
	for peer in peers:
		iterate_peers_behavior(peer)

func _process(delta):
	#im pretty sure that this has to be called
	#for all of the peers to get data too
	#worth testing
	server.poll() # Important!
	#only accept connections if we have that many slots available
	if server.is_connection_available() and (PLAYER_MAX == -1 or len(peers) < PLAYER_MAX):
		emit_signal("connection_available")

func send_entity_data():
	var entities = get_tree().get_nodes_in_group("Entity")
	for p in peers:
		for e in entities:
			#TODO: get entity velocity to send, this works for the time bieng as a hail marry make it work solution
			p.put_packet(
				netUtils.gen_entity_state(
					e.get_entity_id(),
					e.transform.origin,
					Vector3(0,0,0)
					)
				)
	
func _on_SendEntityData_timeout():
	send_entity_data()
