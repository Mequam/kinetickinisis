extends KinematicBody

#this is the player class that the player controls
#TODO: impliment this

class_name Player

export(NodePath) var camera
export(NodePath) var movement_node_manager_node

func get_cam()->Camera:
	return (get_node(camera) as Camera)

#func rotate_cam(Vector2)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func get_movement_velocities() -> Vector3:
	var ret_val : Vector3 = Vector3(0,0,0)
	for node in get_node(movement_node_manager_node).get_children():
		if node.is_in_group("VelocityMoveNode"):
			ret_val += node.velocity
	
	return ret_val
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	move_and_collide(get_movement_velocities()*delta)
