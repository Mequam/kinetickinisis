extends CanvasLayer


export(Vector3) var velocity setget set_velocity
export(int) var collision_time setget set_collision_time
export(int) var frame_rate setget set_frame_rate
export(int) var memory_use setget set_memory_use


export(NodePath) var velocity_label
export(NodePath) var colliion_label
export(NodePath) var framerate_label
export(NodePath) var memoryuse_label
export(NodePath) var happyface_label

func set_velocity(n_vel):
	velocity = n_vel
	update_velocity_text()

func set_collision_time(n_time):
	collision_time = n_time
	update_collision_text()

func set_frame_rate(fps):
	frame_rate = fps
	update_framerate_text()
	pass

func set_memory_use(bits):
	memory_use = bits
	update_memoryuse_text()
	pass

func update_collision_text():
	var label = get_node_or_null(colliion_label)
	if label:
		label.text = "Collision Time: %s us (%3.5f s)"%[collision_time, float(collision_time)/1e+6]

func update_velocity_text():
	var label = get_node_or_null(velocity_label)
	if label:
		label.text = "Player Velocity: \nX: %3.4f \nY: %3.4f \nZ: %3.4f"%[velocity.x,velocity.y,velocity.z]

func update_framerate_text():
	var label = get_node_or_null(framerate_label)
	if label:
		label.text = "Framerate: %s FPS"%frame_rate

func update_memoryuse_text():
	var label = get_node_or_null(memoryuse_label)
	if label:
		label.text = "Memory Use: %4.3f MB"%(float(memory_use)/1048576.0)
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func recieve_player_velocity(p_vel):
	self.velocity = p_vel

func recieve_collision_time(n_time):
	self.collision_time = n_time

func recieve_show_velocity():
	var node = get_node_or_null(velocity_label)
	if node:
		node.visible = true

func recieve_hide_velocity():
	var node = get_node_or_null(velocity_label)
	if node:
		node.visible = false

func recieve_show_frame_rate():
	var node = get_node_or_null(framerate_label)
	if node:
		node.visible = true

func recieve_hide_frame_rate():
	var node = get_node_or_null(framerate_label)
	if node:
		node.visible = false

func recieve_show_memory():
	var node = get_node_or_null(memoryuse_label)
	if node:
		node.visible = true

func recieve_hide_memory():
	var node = get_node_or_null(memoryuse_label)
	if node:
		node.visible = false

func recieve_show_collision_time():
	var node = get_node_or_null(colliion_label)
	if node:
		node.visible = true

func recieve_hide_collision_time():
	var node = get_node_or_null(colliion_label)
	if node:
		node.visible = false

func recieve_show_happy_face():
	var node = get_node_or_null(happyface_label)
	if node:
		node.visible = true

func recieve_hide_happy_face():
	var node = get_node_or_null(happyface_label)
	if node:
		node.visible = false



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	self.frame_rate = Performance.get_monitor(Performance.TIME_FPS)
	self.memory_use = Performance.get_monitor(Performance.MEMORY_STATIC)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	
#	pass
