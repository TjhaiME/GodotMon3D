extends InteractControl


#we need various states for this menu
#inventory
#moves (active monster)
#party
#we need buttons that can always switch between states


#when we click edit move we should see all the moves we can switch it to
#for now do the entire move list
#but it should be moves that monster has learned in its life
#so we can say learn move but then we have to apply it

#some items should ask to confim

#add switch active monster on moves screen

var bagSlotState = 0
var bagSlotStates = {
	"inventory" : 0,
	"moves" : 1
}

var tempNodes = []#to remember which ones to delete
var interactableNodes : Array[Control] = []
func set_up_ui():
	
	for node in tempNodes:
		node.queue_free()
	tempNodes = []
	interactableNodes = []#need to empty after clearing
	set_up_bagSlot_buttons()
	
	var inventory = masterRefNode.players[playerID]["inventory"]
	var inventoryFilled = inventory.keys().size()
	$VBoxContainer/Label.text = str("Player ", playerID,"'s inventory - ", inventoryFilled, " / ", masterRefNode.players[playerID]["inventory_size"])
	
	for itemName in inventory.keys():
		var newItemButton = $VBoxContainer/Inventory/ButtonExample.duplicate()
		newItemButton.visible = true
		newItemButton.get_node("HBoxContainer/itemName").text = itemName
		#newItemButton.get_node("HBoxContainer/cost").text = str("Cost : ",itemData[shopItemName]["cost"])
		var haveAlready = 0
		if masterRefNode.players[playerID]["inventory"].has(itemName):
			haveAlready = masterRefNode.players[playerID]["inventory"][itemName]
		
		newItemButton.get_node("HBoxContainer/inInventory").text = str("Have : ",haveAlready," / ", central.itemData[itemName]["maxLimit"])
		newItemButton.get_node("HBoxContainer/description").text = central.itemData[itemName]["description"]
		$VBoxContainer/Inventory.add_child(newItemButton)
		
		interactableNodes.append(newItemButton)
		tempNodes.append(newItemButton)
		##NEED TO CONNECT THE SIGNALS TOO
		newItemButton.connect("pressed",
		Callable(self, "use_item").bind(itemName))
	$VBoxContainer/Inventory/ButtonExample.visible = false
	set_custom_nav(interactableNodes)
	
	###########This is how we do it for a general thing,
	########## we want to generate the shop first, then make every button using code
	##here we can, optionally, set the nodes that we want to be able to highlight
	#we should do this in scripts that extend this script
	#set_custom_nav([
		#$VBoxContainer/Label2,
		#$VBoxContainer/Label,
		#$VBoxContainer/Button
	#])


func _ready() -> void:
	set_up_general()
	pass



func use_item(itemName):
	var charNode = masterRefNode.players[playerID]["active_char"]
	var didItWork = central.use_item(itemName, charNode, masterRefNode.players[playerID]["active_char_type"])
	if didItWork == false:
		print("couldn't use item")
	#else:
	#do this in the use_item function
		##item was used we must remove 1 from inventory
		#masterRefNode.players[playerID]["inventory"][itemName] -= 1
		#if masterRefNode.players[playerID]["inventory"][itemName] <= 0:
			#masterRefNode.players[playerID]["inventory"].erase(itemName)
	set_up_ui()#refresh so we can see the updates
	pass



############################################
##moves
####################################
func set_up_moves_ui(monsterNode):
	for node in tempNodes:
		node.queue_free()
	tempNodes = []
	interactableNodes = []
	set_up_bagSlot_buttons()
	$VBoxContainer/Moves.visible = true
	for buttonChar in ["A","B","X","Y"]:
		var attackName = monsterNode.stats["moves"][buttonChar]
		var atkData = masterRefNode.get_node("AttacksData").moveData[attackName]
		get_node(str("VBoxContainer/Moves/",buttonChar,"/HBoxContainer/Element/ElementName")).text = atkData["element"]
		get_node(str("VBoxContainer/Moves/",buttonChar,"/HBoxContainer/Element/Name")).text = attackName
		var isSpecial = atkData["special"]
		var physOrSpclTxt = "Physical"
		if isSpecial:
			physOrSpclTxt = "Special"
		get_node(str("VBoxContainer/Moves/",buttonChar,"/HBoxContainer/MainStats/PhysOrSpcl")).text = physOrSpclTxt
		
		get_node(str("VBoxContainer/Moves/",buttonChar,"/HBoxContainer/MainStats/Power")).text = str("pwr: ", atkData["power"])
		get_node(str("VBoxContainer/Moves/",buttonChar,"/HBoxContainer/OtherStats/Range")).text = str("rnge: ",atkData["range"])
		get_node(str("VBoxContainer/Moves/",buttonChar,"/HBoxContainer/OtherStats/Life")).text = str("life: ",atkData["lifetime"])
		get_node(str("VBoxContainer/Moves/",buttonChar,"/HBoxContainer/OtherStats/Speed")).text = str("spd: ",atkData["controllableSpeed"])
		#for various things like "impact", "ignoreFloor", "crater_radius" etc we should show
		#we do this by adding labels to VBoxContainer/Moves/A/HBoxContainer/ExtraFuncs
		#"ignoreFloor"
		var extraLabelsParent = get_node(str("VBoxContainer/Moves/",buttonChar,"/HBoxContainer/ExtraFuncs"))
		var extraLabels = []
		if atkData.has("impact"):
			extraLabels.append(str("impact : ", atkData["impact"]))
		if atkData.has("ignoreFloor"):
			extraLabels.append(str("ignoreFloor : ", atkData["ignoreFloor"]))
		if atkData.has("melee"):
			extraLabels.append(str("is melee atk"))
		for extraLabel in extraLabels:
			var newLabel = Label.new()
			extraLabelsParent.add_child(newLabel)
			tempNodes.append(newLabel)
			newLabel.text = extraLabel
			
		
		#also connect signal to edit button
		#$VBoxContainer/Moves/A/HBoxContainer/Button
		
	#set_up_ui()#

func set_up_bagSlot_buttons():
	if ! $VBoxContainer/BagSlots/OpenInventory in interactableNodes:
		interactableNodes.append($VBoxContainer/BagSlots/OpenInventory)
	if ! $VBoxContainer/BagSlots/OpenMoves in interactableNodes:
		interactableNodes.append($VBoxContainer/BagSlots/OpenMoves)
	
func set_up_general():
	if bagSlotState == bagSlotStates["inventory"]:
		set_up_ui()
		$VBoxContainer/Moves.visible = false
		$VBoxContainer/Inventory.visible = true
	elif bagSlotState == bagSlotStates["moves"]:
		var charNode = masterRefNode.players[playerID]["active_char"]
		set_up_moves_ui(charNode)
		$VBoxContainer/Inventory.visible = false
		$VBoxContainer/Moves.visible = true

#we need a button that is always accessible that shows and hides moves ui

func extra_handle_input(delta: float, input_data: Dictionary) -> void:
	pass
	#this is so we have something to overwrite and put handle_input code on the parent


func _on_open_moves_pressed() -> void:
	bagSlotState = bagSlotStates["moves"]
	set_up_general()
	pass # Replace with function body.


func _on_open_inventory_pressed() -> void:
	bagSlotState = bagSlotStates["inventory"]
	set_up_general()
	pass # Replace with function body.
