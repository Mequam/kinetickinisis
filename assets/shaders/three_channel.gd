extends TextureRect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _input(event):
	if event is InputEventKey:
		if event.scancode >= KEY_KP_0 and event.scancode <= KEY_KP_9 and event.pressed:
			var col1 = Color(randf(), randf(), randf())
			var col2 = Color(randf(), randf(), randf())
			var col3 = Color(randf(), randf(), randf())
			material.set_shader_param("color_prim_0", col1)
			material.set_shader_param("color_sec_0", col2)
			material.set_shader_param("color_shadow_0", col3)
			material.set_shader_param("pixels", int(randf()*256+1080))#*0+1080))
			material.set_shader_param("color_steps", int(randf()*10))

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
