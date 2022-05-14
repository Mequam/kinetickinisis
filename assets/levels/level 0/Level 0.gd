extends Spatial

func _ready():
	print("READY!")

#func _input(event):
#	if event is InputEventKey:
#		if event.scancode >= KEY_KP_0 and event.scancode <= KEY_KP_9 and event.pressed:
#			var col1 = Color(randf(), randf(), randf())
#			var col2 = Color(randf(), randf(), randf())
#			var col3 = Color(randf(), randf(), randf())
#			$TextureRect.material.set_shader_param("color_prim_0", col1)
#			$TextureRect.material.set_shader_param("color_sec_0", col2)
#			$TextureRect.material.set_shader_param("color_shadow_0", col3)
##			uniform vec4 color_prim_0 : hint_color;
##			uniform vec4 color_sec_0 : hint_color;
##			uniform vec4 color_shadow_0 : hint_color;
