extends CanvasLayer

export(NodePath) var output_textbox_path
export(NodePath) var input_textbox_path
onready var output_textbox : TextEdit = get_node_or_null(output_textbox_path)
onready var input_textbox : TextEdit = get_node_or_null(input_textbox_path)
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var function_dictionary = {
	"clear":"clear_output_text",
	"exit" : "exit_game",
	"tree" : "print_scene_tree",
	"reload" : "reload_current_scene",
	"pause" : "pause_scene_tree",
	"unpause" : "unpause_scene_tree",
	"debug" : "scene_debug",
	"help" : "print_help"
}
# Called when the node enters the scene tree for the first time.

func _input(event):
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func clear_output_text(args):
	output_textbox.text = ""

func exit_game(args):
	output_line("EXITING...")
	output_line("Thank you for your participation and intellectual property rights to your person and mind.")
	output_line("Excelerant Corporation © 2532.")
	for i in range(10):
		yield(get_tree(),"idle_frame")
	get_tree().quit()

func print_scene_tree(args):
	output_line("no")

func print_help(args):
	output_line("Why Howdy Partner! I been 'round these parts of town since my sweet Becky was notin' but a calf")
	output_line("Word on this ranch is that the valid commands are as follows:")
	for key in function_dictionary:
		output_line(key)
	output_line("I hope i have helped a fine fellow out plenty!")

func reload_current_scene(args):
	output_line("Reloading Current Scene...")
	yield(get_tree(),"idle_frame")
	get_tree().reload_current_scene()

func pause_scene_tree(args):
	output_line("Pausing Scene Tree...")
	get_tree().paused = true

func unpause_scene_tree(args):
	output_line("Unpausing Scene Tree...")
	get_tree().paused = false

func scene_debug(args):
	var debug_func_dict = {
		"show" : "debug_show",
		"hide" : "debug_hide",
		"help" : "debug_help"
	}
	if args[0] in debug_func_dict:
		var function = debug_func_dict[args[0]]
		args.remove(0)
		call(function, args)
	else:
		output_line("Debug what? \"%s\" are you serious? Like what kind of AI do you take me for, a TI-87??\nConsider typing a valid command once in your life.\nUse \"debug help\" or something idc."%args[0])
	pass

func debug_show(args):
	var debug_show_dict = {
		"framerate" : "recieve_show_frame_rate",
		"memory" : "recieve_show_memory",
		"velocity" : "recieve_show_velocity",
		"collision_time" : "recieve_show_collision_time",
		":)" : "recieve_show_happy_face"
	}
	if args[0] in debug_show_dict:
		var function = debug_show_dict[args[0]]
		get_tree().call_group("Debug UI", function)
	else:
		output_line("uh hey, i don't mean to bother you but i can't seem to find \"%s\" anywhere, maybe it's not a valid function?\ni'm sorry if that upsets you, i'm trying by best!~"%args[0])
	pass

func debug_hide(args):
	var debug_hide_dict = {
		"framerate" : "recieve_hide_frame_rate",
		"memory" : "recieve_hide_memory",
		"velocity" : "recieve_hide_velocity",
		"collision_time" : "recieve_hide_collision_time",
		":)" : "recieve_hide_happy_face"
	}
	if args[0] in debug_hide_dict:
		var function = debug_hide_dict[args[0]]
		get_tree().call_group("Debug UI", function)
	else:
		output_line("ay yo dog not even playn rn but \"%s\" aint in y'bois database\nu kno what u typin?"%args[0])
	pass

func debug_help(args):
	output_line("Excelerant Corporation is at no legal obligation to assist participants.")

func output_line(line : String):
	output_textbox.text += "\n"+line
	output_textbox.scroll_vertical = 100000

func output_text(text : String):
	output_textbox.text += text
	output_textbox.scroll_vertical = 100000
	pass

func parse_console_text(text : String):
	output_text("\n>>> "+text)
	var args = text.split(" ")
	if args[0] in function_dictionary:
		var function = function_dictionary[args[0]]
		args.remove(0)
		call(function, args)
	else:
		output_line("*Teleports behind you* \"%s\" is not a valid function kiddo..."%args[0])
	pass

func _on_Input_gui_input(event : InputEvent):
	if event is InputEventKey:
		if event.scancode == KEY_ENTER and event.pressed:
			var text = input_textbox.text.strip_edges()
			parse_console_text(text)
			input_textbox.text = ""
#	print(event)
	pass # Replace with function body.


















































func _ready():
	function_dictionary["cow"] = "print_cow"
	pass # Replace with function body.




func print_cow(args):
	output_line(cow)

var cow = """
 _______________________ 
< moo i am a cow and i am sad because i am bound to this simulation>
 ----------------------- 
		\\   ^__^
		 \\  (oo)\\_______
			(__)\\       )\\/\\
				||----w |
				||     ||
"""
