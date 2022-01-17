extends MovementNode

class_name CameraMoveNode

func rotate_cam(vec : Vector2) -> void:
	get_cam().rotate_hv(vec)

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("CameraMoveNode")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
