extends Control

#this node is the generic class for the circle select control

class_name CircleSelectControl

export(NodePath) var circle_path : NodePath = NodePath("CircleContainer/Circle")
export(NodePath) var circle_container_path : NodePath = NodePath("CircleContainer")
export(NodePath) var center_text : NodePath = NodePath("CircleContainer/Circle/CenterText")

#the angle that the options start at
export(float) var start_angle : float = -PI/2

#initilize the variables
onready var circleContainer : Control= get_node(circle_container_path)
onready var circle : ColorRect = get_node(circle_path)
onready var circleMaterial : ShaderMaterial  = circle.get_material()
onready var centerText : Label = get_node(center_text)

#CHANGE ME I DARE YOU
var options : Array = []

signal selected_option 


#the focus angle that the shader uses and we use for selection
var focus_angle : float setget set_focus_angle, get_focus_angle
func set_focus_angle(val : float)->void:
	circleMaterial.set_shader_param("focus_angle",val)
func get_focus_angle()->float:
	return circleMaterial.get_shader_param("focus_angle")
# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	display_options()
func clear_labels():
	for lbl in circle.get_children():
		if lbl != centerText:
			lbl.queue_free()
func angle2vec(angle : float,radius : float)->Vector2:
	return Vector2(cos(angle),sin(angle))*radius

#adds a label delta pixels away from the circle
func add_label_angle_delta(angle : float, dist : float,text : String)->void:
	var radius = 2*circleMaterial.get_shader_param("radius_percentage")*circle.rect_size.x + dist
	add_label_position(angle2vec(angle,radius),text)
func add_label_angle(angle : float,radius : float,text : String)->void:
	add_label_position(angle2vec(angle,radius),text)
func add_label_position(pos : Vector2, text : String):
	var lbl = Label.new()
	lbl.text = text

	#translate from the outside chords to local UV chords
	pos.x = (pos.x)/(circle.rect_size.x*2)+0.5
	pos.y = -pos.y/(circle.rect_size.y*2) + 0.5
	
	lbl.anchor_bottom = pos.y
	lbl.anchor_top = pos.y
	
	lbl.anchor_left = pos.x
	lbl.anchor_right = pos.x
	
	lbl.margin_top -= 7
	lbl.margin_right = 0
	lbl.margin_left = 0
	lbl.margin_bottom = 0
	
	lbl.grow_horizontal = Control.GROW_DIRECTION_BOTH
	
	circle.add_child(lbl)

func display_options():
	#clear the existing options
	clear_labels()
	
	var o_len = len(options)
	if o_len != 0:
		var delta_angle = 2*PI/len(options)
		for i in range(0,len(options)):
			add_label_angle_delta(start_angle+delta_angle*i,200,options[i])

func vec2Angl(vec : Vector2)->float:
	return -atan2(vec.y,vec.x)

func _input(event):
	if event is InputEventMouseMotion:
		self.focus_angle = vec2Angl(event.relative/(100*event.relative.length_squared()))
	if event.is_action_pressed("ui_accept"):
		emit_signal("selected_option",get_selection())

func get_selection()->int:
	var modulus = len(options)
	if modulus == 0:
		return -1
	var delta = 2*PI/(2*modulus)
	
	var angle = self.focus_angle - start_angle
	var code = int(floor((angle + PI/modulus) * modulus / (2*PI)))
	if code < 0:
		return modulus + code
	return code
