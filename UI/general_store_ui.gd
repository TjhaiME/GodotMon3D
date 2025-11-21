extends InteractControl

#say ye olde shoppe somewhere

#var shopItems = ["potion", "poison", "maxPotion", "poop", "stamina leaf", "item1", "item2", "item3", "item4", "item5", "item6", "item7", "item8", "item9", "item10", "item11"]

#var itemData in globalSingleton

var interactableNodes : Array[Control] = []
func set_up_ui():
	
	for node in interactableNodes:
		node.queue_free()
	interactableNodes = []#need to empty after clearing
	
	var shopItems = central.itemData.keys()
	
	for shopItemName in shopItems:
		var newItemButton = $VBoxContainer/ButtonExample.duplicate()
		newItemButton.visible = true
		newItemButton.get_node("HBoxContainer/itemName").text = shopItemName
		newItemButton.get_node("HBoxContainer/cost").text = str("Cost : ",central.itemData[shopItemName]["cost"])
		var haveAlready = 0
		if masterRefNode.players[playerID]["inventory"].has(shopItemName):
			haveAlready = masterRefNode.players[playerID]["inventory"][shopItemName]
		
		newItemButton.get_node("HBoxContainer/inInventory").text = str("Have : ",haveAlready," / ", central.itemData[shopItemName]["maxLimit"])
		newItemButton.get_node("HBoxContainer/description").text = central.itemData[shopItemName]["description"]
		$VBoxContainer.add_child(newItemButton)
		
		interactableNodes.append(newItemButton)
		##NEED TO CONNECT THE SIGNALS TOO
		newItemButton.connect("pressed", 
		Callable(self, "on_shop_button_pressed").bind(shopItemName))
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



func on_shop_button_pressed(shopItemName):
	transact(shopItemName, central.itemData[shopItemName]["cost"], central.itemData[shopItemName]["maxLimit"], playerID)
	set_up_ui()#refresh so we can see the updates
	pass
