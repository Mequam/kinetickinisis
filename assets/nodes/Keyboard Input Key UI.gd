extends Control


export(String) var text setget set_text
export(int) var scancode
func set_text(n_text):
	text = n_text
	if not is_inside_tree(): yield(self,"ready")
	$Button.text = text
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
