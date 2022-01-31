extends Control


export(Array, NodePath) var key_parent_nodes
var scancode_node_array : Array
var key_node_array : Array

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	fill_key_node_array()
	pass # Replace with function body.

func add_key_to_scancode_array(key_node):
	if scancode_node_array.size() < key_node.scancode+1:
		scancode_node_array.resize(key_node.scancode+1)
	scancode_node_array[key_node.scancode] = key_node

func get_key_node_children(parent_node):
	var node_array = []
	for node in parent_node.get_children():
		if node is KeyboardInputKeyUI:
			node_array.append(node)
			pass
		else:
			node_array.append_array(get_key_node_children(node))
	return node_array

func fill_key_node_array():
	key_node_array.append_array(get_key_node_children(self))
	for node in key_node_array:
		add_key_to_scancode_array(node)

func clear_keys():
	for key in key_node_array:
		key.key_pressed = false

func press_scancode(scancode):
	if scancode < scancode_node_array.size() and scancode_node_array[scancode] is KeyboardInputKeyUI:
		scancode_node_array[scancode].key_pressed = true
		pass

func press_scancodes(scancodes):
	for scancode in scancodes:
		press_scancode(scancode)

func _input(event):
	if event is InputEventKey:
		if event.scancode < scancode_node_array.size():
#			print(event.scancode)
#			print(OS.get_scancode_string(event.scancode))
			var key_node = scancode_node_array[event.scancode]
			key_node.key_pressed = event.pressed

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
