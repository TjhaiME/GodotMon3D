extends Control
#so for something to be a controller it needs
#### For control ####
var is_controlled = false
var playerID = 0
################
var highlightedNode = self

####     SET BEFORE SPAWN        ####
var oldUI = null#we replace the ui with a new control node, so we record the old one
var attachedMesh = null
var attachedViewport = null
var masterRefNode = null
#####################################

func on_set_control():
	print("switched control to the npc interact ui")
	return

#var states = {
	#"reading" : 0,#up and down is scroll, b escape, a confirm, move scroll all the way to bottom to switch to button mode
	#"buttons" : 1,#left and right cycle through all the buttons 
#}


func give_control_back_to_parent():
	var previous_controller = masterRefNode.get_player_var(playerID,"previous_controller")
	if previous_controller:
		masterRefNode.set_control(previous_controller, playerID)
		var mat = attachedMesh.get_active_material(0)
		mat.albedo_texture = attachedViewport.get_texture()
		#queue_free() #would only work if we are the mesh itself, we need to queue_Free ourselves but first re set the old ui
		


func visually_highlight_node(hNode):
	pass
	#we need a way of visually indicating which node we have selected

func change_highlighted_node(newNode):
	highlightedNode = newNode

func handle_input(delta: float, input_data: Dictionary) -> void:
	if not is_controlled:
		return
	
	#okay so we want to basically have a state machine that handles different types of input
	#we need a fake cursor, and depending on what it is selecting we do different things,
	#so we need both a cursor and a node highlighter
	#e.g. if we are viewing a text box then up and down should be scroll
	#
	if input_data["attack_B_pressed"]:
		if highlightedNode == self:
			give_control_back_to_parent()
		else:
			change_highlighted_node(highlightedNode.get_parent())#move up one level
			#else we move the highlighted node up one level
	
	
	#depending on what type of node it is we want to have different rules
	if input_data["attack_A_pressed"]:
		pass
	elif input_data["attack_X_pressed"]:
		pass
	elif input_data["attack_Y_pressed"]:
		pass
	elif input_data["dodge_pressed"]:
		pass
	elif input_data["jump_pressed"]:
		pass
	var move_input = input_data["move"]#vector2
	var look_input = input_data["look"]#vector2
	
	#we also need a secondary cursor that we can move around like a mouse to simulate mouse input, or to be able to move the imaginary cursor to the appropriate spots, like clicking TAB
