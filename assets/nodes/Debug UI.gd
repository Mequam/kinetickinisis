extends CanvasLayer


export(Vector3) var velocity setget set_velocity
export(int) var collision_time setget set_collision_time
export(NodePath) var velocity_label
export(NodePath) var colliion_label

func set_velocity(n_vel):
	velocity = n_vel
	update_velocity_text()

func set_collision_time(n_time):
	collision_time = n_time
	update_collision_text()

func update_collision_text():
	var label = get_node_or_null(colliion_label)
	if label:
		label.text = "Collision Time: %s us (%3.5f s)"%[collision_time, float(collision_time)/1e+6]

func update_velocity_text():
	var label = get_node_or_null(velocity_label)
	if label:
		label.text = "Player Velocity: \nX: %3.4f \nY: %3.4f \nZ: %3.4f"%[velocity.x,velocity.y,velocity.z]
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func recieve_player_velocity(p_vel):
	self.velocity = p_vel

func recieve_collision_time(n_time):
	self.collision_time = n_time
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
