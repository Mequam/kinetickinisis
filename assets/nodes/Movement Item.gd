extends Spatial


#export()
var node = RayCastTeleportMove.new()
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
	if body is Player:
		node.name = "Raycast Teleport"
		node.input_action = "action_1"
		body.move_node_into_inventory(node)
		queue_free()
	pass # Replace with function body.
