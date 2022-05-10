extends Spatial


#this function returns a movment node to add to the player
#if we want random node generation we should do it here
func gen_movement_node(args=[])->MovementNode:
	var ret_val = RayCastTeleportMove.new()
	ret_val._movement_id = 5
	return ret_val
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Area_body_entered(body):
	var node : MovementNode = gen_movement_node()
	print("giving player " + node.get_display_name() + " "  + str(node.get_movement_id()))
	if body is Player:
		body.move_node_into_inventory(node)
		queue_free()
	pass # Replace with function body.
