extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	var t : RayCastTeleportMove = RayCastTeleportMove.new()
	var c : CameraFPSMoveNode = CameraFPSMoveNode.new()
	$Player.node_inventory.append(t)
	$Player.node_inventory.append(c)
