extends VelocityMoveNode

#this node is a generic class for implimenting acceleration movemnts

class_name AccelerationMoveNode
	
func _ready():
	add_to_group("AccelerationMoveNode")

export(Vector3) var acceleration : Vector3 = Vector3(0,0,0)
# Called when the node enters the scene tree for the first time.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	velocity += acceleration*delta

#called when the player collides
#func player_collided(col):
#	velocity = Vector3(0,0,0)
