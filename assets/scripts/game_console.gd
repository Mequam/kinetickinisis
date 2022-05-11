#this script contains stuff for the game debug console
#woweee
extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
#export(PackedScene) var game_console_scene
#onready var game_console = load(game_console_scene)
onready var game_console = preload("res://assets/nodes/Game Console.tscn").instance()
var previous_mouse_mode = Input.MOUSE_MODE_VISIBLE



# Called when the node enters the scene tree for the first time.
func _ready():
	pause_mode = PAUSE_MODE_PROCESS
	pass # Replace with function body.

func open_game_console():
#	var gc_canvas = find_node("Game Console Canvas", false)
#	if gc_canvas:
#		pass
#	else:
#		gc_canvas = CanvasLayer.new()
#		add_child(gc_canvas)
#	var gc_node = find_node("Game Console UI", false)
#	print(gc_node)
	if game_console in get_children():
		print("yeah got em lol")
		remove_child(game_console)
#		gc_canvas.remove_child(gc_node)
		Input.set_mouse_mode(previous_mouse_mode)
	else:
		add_child(game_console)
#		gc_canvas.add_child(game_console)
		previous_mouse_mode = Input.get_mouse_mode()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	pass

func _input(event):
	if event is InputEventKey:
		if event.scancode == KEY_ESCAPE and event.pressed:
			open_game_console()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
