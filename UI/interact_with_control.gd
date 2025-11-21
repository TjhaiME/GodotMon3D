class_name InteractControl
extends Control

#base code for an interface we can interact with using the in game controls
#we can add more node types, like transaction buttons etc.
#adjust inventory/buy things
#change moves
#change party/monster
#choose a battle to start
#choose a rogue mode to start
#we can set which nodes are interactable

#we should turn into a custom class so we can extend it with other scripts.
###################################
#SIMPLE INVENTORY SYSTEM:
##############


func transact(itemName, cost, itemMaxLimit, playerID):
	#if it returns false the transaction failed
	#if it returns true the transaction succeeds
	var player = masterRefNode.players[playerID]
	var hasSpace = false
	#var cost = 10#example
	#var itemName = ""
	#var itemMaxLimit = 10#example
	if player["inventory"].keys().size() < player["inventory_size"]:
		#our inventory is not full
		hasSpace = true
	else:
		if itemName in player["inventory"].keys():
			if player["inventory"][itemName] < itemMaxLimit:
				hasSpace = true
			else:
				print("we can't carry any more of this item")
				return false

	if hasSpace:
		if player["money"] >= cost:
			#we can afford it
			player["money"] -= cost
			if itemName in player["inventory"].keys():
				#we already have it
				player["inventory"][itemName] += 1#add one
			else:
				player["inventory"][itemName] = 1#create dictionary entry then set to 1
		else:
			print("we cannot afford this item")
			return false
	else:
		print("we don't have space in our inventory")
		return false
	
	
	refresh_ui()#this isnt updating the number we have in our inventory
	return true
###########################################################

#################################################
##CHANGING MOVES:
################################
##this is a lot harder as it is saved on the monster when it spawns
##if we assume it is the monster who is interacting we can do it, or we go from masterRefNode

#if it IS the monster who is interacting then it is player["previous_controller"]

###################################
## launch battle npc
##########################
##talk to an npc and have it select a monster to fight and how many and then spawn and start the battle


#we just need a way of setting what is at the shop and costs
#and a way of looking through our inventory (hold interact and press other buttons, monster hunter style)



### --- Required controller interface (matches your system) --- ###
var is_controlled = false
var playerID = 0
var highlightedNode : Control = null

var oldUI = null
var attachedMesh = null
var attachedViewport = null
var masterRefNode = null 
#we could have players inventory on masterRefNode
#then from here we can make transactions


### --- Navigation state --- ###
enum {
	UI_NAV_NORMAL,
	UI_NAV_SCROLL,
}
var control_state = UI_NAV_NORMAL


### --- CUSTOM NAV OVERRIDE --- ###
# If this list has elements, all navigation uses this list ONLY.
var custom_nav_list : Array[Control] = []
var custom_nav_index := 0

#func _ready() -> void:
	##here we can, optionally, set the nodes that we want to be able to highlight
	#we should do this in scripts that extend this script
	#set_custom_nav([
		#$VBoxContainer/Label2,
		#$VBoxContainer/Label,
		#$VBoxContainer/Button
	#])


# Helper to sanitize the list (remove nulls, invalid nodes)
func sanitize_custom_nav_list():
	custom_nav_list = custom_nav_list.filter(func(n): return (n and n is Control and n.is_inside_tree()))

	if custom_nav_list.is_empty():
		return

	if custom_nav_index >= custom_nav_list.size():
		custom_nav_index = 0


func use_custom_navigation() -> bool:
	return custom_nav_list.size() > 0


func set_custom_nav(nodes: Array[Control]):
	custom_nav_list = nodes.duplicate()
	sanitize_custom_nav_list()
	if not custom_nav_list.is_empty():
		custom_nav_index = 0
		highlight_node(custom_nav_list[0])


func clear_custom_nav():
	custom_nav_list.clear()
	custom_nav_index = 0


func refresh_ui():
	var mat = attachedMesh.get_active_material(0)
	mat.albedo_texture = attachedViewport.get_texture()



func on_set_control():
	print("UI controller active.")

	# If custom nav is empty → fallback to tree-based initial focus
	if use_custom_navigation():
		sanitize_custom_nav_list()
		if not custom_nav_list.is_empty():
			highlightedNode = custom_nav_list[custom_nav_index]
			visually_highlight_node(highlightedNode)
			return

	if highlightedNode == null:
		highlightedNode = find_first_focusable_node(self)
		if highlightedNode:
			visually_highlight_node(highlightedNode)



### -----------------------------
###  CONTROL RETURN
### -----------------------------
#func give_control_back_to_parent():
	#var previous_controller = masterRefNode.get_player_var(playerID,"previous_controller")
	#if previous_controller:
		#masterRefNode.set_control(previous_controller, playerID)
	#
	#if attachedMesh and attachedViewport:
		#var mat = attachedMesh.get_active_material(0)
		#mat.albedo_texture = attachedViewport.get_texture()
#
	#queue_free()


func give_control_back_to_parent():
	var previous_controller = masterRefNode.get_player_var(playerID,"previous_controller")
	if previous_controller:
		masterRefNode.set_control(previous_controller, playerID)
	
	if attachedMesh and attachedViewport:
		oldUI.visible = true
		refresh_ui()

	queue_free()

### -----------------------------
###  HIGHLIGHT LOGIC
### -----------------------------

### --- Highlight colors --- ###
var highlight_color = Color(1.0, 1.0, 0.2)
var normal_color = Color(1,1,1,1)

var highlight_overlays := {}  # node → overlay
var highlight_thickness := 2
#var highlight_color := Color(1, 0.8, 0.2, 1)

func create_outline_for(node: Control) -> Control:
	var overlay := ColorRect.new()
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.color = Color.TRANSPARENT
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	# Draw border using a StyleBox
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color.TRANSPARENT
	sb.border_color = highlight_color
	sb.border_width_left = highlight_thickness
	sb.border_width_right = highlight_thickness
	sb.border_width_top = highlight_thickness
	sb.border_width_bottom = highlight_thickness
	overlay.add_theme_stylebox_override("panel", sb)

	# Wrap it in a Panel to apply the StyleBox
	var panel := Panel.new()
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel.add_child(overlay)

	node.add_child(panel)
	node.move_child(panel, node.get_child_count() - 1) # ensure on top

	return panel

#
#func visually_highlight_node(node: Control):
	#if not node: return
	#node.add_theme_color_override("font_color", highlight_color)
#
#func visually_unhighlight_node(node: Control):
	#if not node: return
	#node.add_theme_color_override("font_color", normal_color)
func visually_highlight_node(node: Control):
	if not node:
		return
	# Already has overlay?
	if node in highlight_overlays:
		highlight_overlays[node].visible = true
	else:
		var overlay = create_outline_for(node)
		highlight_overlays[node] = overlay
func visually_unhighlight_node(node: Control):
	if not node:
		return
	if node in highlight_overlays:
		highlight_overlays[node].visible = false

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
###  FIND FIRST FOCUSABLE NODE
### -----------------------------
func find_first_focusable_node(root: Control) -> Control:
	for child in root.get_children():
		if child is Control:
			return child
	return root



### -----------------------------
###  NAVIGATION METHODS
### -----------------------------
### --- If custom nav list is active, override everything --- ###
func custom_nav_left():
	sanitize_custom_nav_list()
	if custom_nav_list.is_empty(): return

	custom_nav_index -= 1
	if custom_nav_index < 0:
		custom_nav_index = custom_nav_list.size() - 1

	highlight_node(custom_nav_list[custom_nav_index])
	coolDownTimer = buttonCoolDown


func custom_nav_right():
	sanitize_custom_nav_list()
	if custom_nav_list.is_empty(): return

	custom_nav_index += 1
	if custom_nav_index >= custom_nav_list.size():
		custom_nav_index = 0

	highlight_node(custom_nav_list[custom_nav_index])
	coolDownTimer = buttonCoolDown



### --- DEFAULT NAVIGATION (fallback) --- ###
func nav_up():
	var parent = highlightedNode.get_parent()
	if parent is Control:
		highlight_node(parent)
		coolDownTimer = buttonCoolDown

func nav_down():
	for child in highlightedNode.get_children():
		if child is Control:
			highlight_node(child)
			coolDownTimer = buttonCoolDown
			return

func nav_left():
	var parent = highlightedNode.get_parent()
	if not parent: return
	var siblings = parent.get_children()

	var idx = siblings.find(highlightedNode)
	for i in range(idx - 1, -1, -1):
		if siblings[i] is Control:
			highlight_node(siblings[i])
			coolDownTimer = buttonCoolDown
			return

func nav_right():
	var parent = highlightedNode.get_parent()
	if not parent: return
	var siblings = parent.get_children()

	var idx = siblings.find(highlightedNode)
	for i in range(idx + 1, siblings.size()):
		if siblings[i] is Control:
			highlight_node(siblings[i])
			coolDownTimer = buttonCoolDown
			return



### -----------------------------
###  INPUT HANDLING
### -----------------------------
var coolDownTimer = 0.0
var buttonCoolDown = 0.2

func handle_input(delta: float, input_data: Dictionary) -> void:
	if not is_controlled:
		return
	
	if coolDownTimer > 0.0:
		coolDownTimer -= delta
		if coolDownTimer <= 0.0:
			coolDownTimer = 0.0
		return
	
	if highlightedNode == null:
		highlightedNode = find_first_focusable_node(self)
		highlight_node(highlightedNode)

	# B → exit or move upward
	if input_data["attack_B_pressed"]:
		if highlightedNode == self:
			give_control_back_to_parent()
			
		else:
			nav_up()
		return


	var mv: Vector2 = input_data["move"]

	# A → activate
	if input_data["attack_A_pressed"]:
		handle_activation()
		return


	### --- CUSTOM NAVIGATION OVERRIDE --- ###
	if use_custom_navigation():
		if mv.x < -0.5:
			custom_nav_left()
		elif mv.x > 0.5:
			custom_nav_right()
		# Y-axis ignored for custom list
		return



	### --- DEFAULT NAVIGATION --- ###
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
			coolDownTimer = buttonCoolDown
		"scroll":
			control_state = UI_NAV_SCROLL
		"container":
			nav_down()
		"text":
			pass
		


### -----------------------------
###  SCROLL INPUT
### -----------------------------
func handle_scroll_input(mv: Vector2, input_data: Dictionary):
	if not (highlightedNode is ScrollContainer):
		control_state = UI_NAV_NORMAL
		return

	highlightedNode.scroll_vertical += mv.y * 50

	if input_data["attack_B_pressed"]:
		control_state = UI_NAV_NORMAL


func _on_button_focus_entered() -> void:
	print("_on_button_focus_entered()")
	#this doesnt run
	pass # Replace with function body.


func _on_button_pressed() -> void:
	print("_on_button_pressed()")
	#this does run
	pass # Replace with function body.
