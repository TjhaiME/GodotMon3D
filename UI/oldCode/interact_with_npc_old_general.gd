extends Control

### --- Required controller interface (matches your system) --- ###
var is_controlled = false
var playerID = 0
var highlightedNode : Control = null

var oldUI = null
var attachedMesh = null
var attachedViewport = null
var masterRefNode = null


### --- Navigation state --- ###
enum {
	UI_NAV_NORMAL,
	UI_NAV_SCROLL,
}
var control_state = UI_NAV_NORMAL


### --- Highlight colors --- ###
var highlight_color = Color(1.0, 1.0, 0.2) # yellow
var normal_color = Color(1,1,1,1)


func on_set_control():
	print("UI controller active.")
	# Find some initial focus if none set
	if highlightedNode == null:
		highlightedNode = find_first_focusable_node(self)
		if highlightedNode:
			visually_highlight_node(highlightedNode)


### -----------------------------
###  CONTROL RETURN
### -----------------------------
func give_control_back_to_parent():
	var previous_controller = masterRefNode.get_player_var(playerID,"previous_controller")
	if previous_controller:
		masterRefNode.set_control(previous_controller, playerID)
	
	if attachedMesh and attachedViewport:
		oldUI.visible = true
		var mat = attachedMesh.get_active_material(0)
		mat.albedo_texture = attachedViewport.get_texture()

	queue_free()


### -----------------------------
###  HIGHLIGHT LOGIC
### -----------------------------
func visually_highlight_node(node: Control):
	if not node: return
	node.add_theme_color_override("font_color", highlight_color)
	# You can add more visual highlight effects here.


func visually_unhighlight_node(node: Control):
	if not node: return
	node.add_theme_color_override("font_color", normal_color)


func highlight_node(node: Control):
	if node == null: return
	if highlightedNode and highlightedNode != node:
		visually_unhighlight_node(highlightedNode)

	highlightedNode = node
	visually_highlight_node(node)


### -----------------------------
###  UI TYPE DETECTION
### -----------------------------
func get_ui_type(node: Control) -> String:
	if node.has_meta("ui_type"):
		return node.get_meta("ui_type")

	if node is Button:
		return "button"
	if node is ScrollContainer:
		return "scroll"
	if node is Label:
		return "text"

	return "container"


### -----------------------------
###  FIND INITIAL FOCUSABLE NODE
### -----------------------------
func find_first_focusable_node(root: Control) -> Control:
	for child in root.get_children():
		if child is Control:
			return child
	return root


### -----------------------------
###  NAVIGATION HELPERS
### -----------------------------
func nav_up():
	var parent = highlightedNode.get_parent()
	if parent is Control:
		highlight_node(parent)


func nav_down():
	for child in highlightedNode.get_children():
		if child is Control:
			highlight_node(child)
			return


func nav_left():
	var parent = highlightedNode.get_parent()
	if not parent: return
	var siblings = parent.get_children()

	var idx = siblings.find(highlightedNode)
	for i in range(idx - 1, -1, -1):
		if siblings[i] is Control:
			highlight_node(siblings[i])
			return


func nav_right():
	var parent = highlightedNode.get_parent()
	if not parent: return
	var siblings = parent.get_children()

	var idx = siblings.find(highlightedNode)
	for i in range(idx + 1, siblings.size()):
		var node = siblings[i]
		if node is Control:
			highlight_node(node)
			return


### -----------------------------
###  INPUT HANDLING
### -----------------------------
func handle_input(delta: float, input_data: Dictionary) -> void:
	if not is_controlled:
		return

	if highlightedNode == null:
		highlightedNode = find_first_focusable_node(self)
		highlight_node(highlightedNode)

	# B button → go back / collapse
	if input_data["attack_B_pressed"]:
		if highlightedNode == self:
			give_control_back_to_parent()
		else:
			nav_up()
		return

	# A button → activate
	if input_data["attack_A_pressed"]:
		handle_activation()
		return

	# Directional navigation
	var mv: Vector2 = input_data["move"]

	if control_state == UI_NAV_NORMAL:
		if mv.y < -0.5:
			nav_up()
		elif mv.y > 0.5:
			nav_down()

		if mv.x < -0.5:
			nav_left()
		elif mv.x > 0.5:
			nav_right()

	elif control_state == UI_NAV_SCROLL:
		handle_scroll_input(mv, input_data)


### -----------------------------
###  BUTTON / NODE ACTIVATION
### -----------------------------
func handle_activation():
	var ntype = get_ui_type(highlightedNode)

	match ntype:
		"button":
			highlightedNode.emit_signal("pressed")

		"scroll":
			control_state = UI_NAV_SCROLL

		"container":
			nav_down()

		"text":
			# A does nothing by default for Label
			pass


### -----------------------------
###  SCROLL MODE
### -----------------------------
func handle_scroll_input(mv: Vector2, input_data: Dictionary):
	if not (highlightedNode is ScrollContainer): 
		control_state = UI_NAV_NORMAL
		return

	# Scroll vertically with stick
	highlightedNode.scroll_vertical += mv.y * 50

	# Exit scroll mode with B
	if input_data["attack_B_pressed"]:
		control_state = UI_NAV_NORMAL


func _on_button_focus_entered() -> void:
	print("on button focus entered")
	pass # Replace with function body.


func _on_button_pressed() -> void:
	print("on button pressed")
	pass # Replace with function body.
