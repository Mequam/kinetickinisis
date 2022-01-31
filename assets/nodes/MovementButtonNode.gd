extends Button


export(int, "Movement", "Inventory") var button_type
var movement_node : Node
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

signal selected(node)
# Called when the node enters the scene tree for the first time.
func _ready():
	connect("pressed", self, "select")
	pass # Replace with function body.

func select():
	emit_signal("selected", self)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
