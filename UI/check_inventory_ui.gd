extends InteractControl




var interactableNodes : Array[Control] = []
func set_up_ui():
	
	for node in interactableNodes:
		node.queue_free()
	interactableNodes = []#need to empty after clearing
	
	var inventory = masterRefNode.players[playerID]["inventory"]
	var inventoryFilled = inventory.keys().size()
	$VBoxContainer/Label.text = str("Player ", playerID,"'s inventory - ", inventoryFilled, " / ", masterRefNode.players[playerID]["inventory_size"])
	
	for itemName in inventory.keys():
		var newItemButton = $VBoxContainer/ButtonExample.duplicate()
		newItemButton.visible = true
		newItemButton.get_node("HBoxContainer/itemName").text = itemName
		#newItemButton.get_node("HBoxContainer/cost").text = str("Cost : ",itemData[shopItemName]["cost"])
		var haveAlready = 0
		if masterRefNode.players[playerID]["inventory"].has(itemName):
			haveAlready = masterRefNode.players[playerID]["inventory"][itemName]
		
		newItemButton.get_node("HBoxContainer/inInventory").text = str("Have : ",haveAlready," / ", central.itemData[itemName]["maxLimit"])
		newItemButton.get_node("HBoxContainer/description").text = central.itemData[itemName]["description"]
		$VBoxContainer.add_child(newItemButton)
		
		interactableNodes.append(newItemButton)
		##NEED TO CONNECT THE SIGNALS TOO
		newItemButton.connect("pressed",
		Callable(self, "use_item").bind(itemName))
	$VBoxContainer/ButtonExample.visible = false
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
	set_up_ui()
	pass



func use_item(itemName):
	var charNode = masterRefNode.players[playerID]["previous_controller"]
	var didItWork = central.use_item(itemName, charNode, "monster")
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
