extends Node3D


#make a version that newbies can easily follow

var ui_scene = preload("res://UI/monsterUI.tscn")

#to show how the project is structured
var monsterData = {
	0 : {
		"name" : "",#nickname
		"species" : "Birb",
		
		"element1" : "Wind",
		"element2" : "Fire",
		
		#STATUS EFFECTS:
		"ailment" : 0,##0 is none, see above
		"ailCount" : 0.0,#a float to record or healing process
		"ailTimer" : 0.0,#a float for recording the periodic timer for status effects, (we can increase it by random intervals each frame)
		
		"HP" : 150,
		"maxHP" : 150,
		"stamina" : 100,
		"maxStamina" : 100,
		"stamRegen" : 75,
		"physAtk" : 75,
		"physDef" : 75,
		"spclAtk" : 75,
		"spclDef" : 75,
		"speed" : 75, #increases evade distance too
		"evasion" : 75,
		#stranger stats
		"climb" : 45.0, #allows us to walk up steeper hills
		
		"moves" : {
			"A" : "Beam",
			"B" : "Breath",
			"X" : "Charge Punch",
			"Y" : "Slam"
		},
		"base" : { #allows us to modify stats midbattle temporarily (seems redundant I know)
			"maxHP" : 150,
			"maxStamina" : 100,
			"stamRegen" : 75,
			"physAtk" : 75,
			"physDef" : 75,
			"spclAtk" : 75,
			"spclDef" : 75,
			"speed" : 75, #increases evade distance too
			"evasion" : 75,
			"climb" : 45.0, #allows us to walk up steeper hills
		}
	},
	1 : {
		"name" : "",#nickname
		"species" : "Yeti",
		
		"element1" : "Ice",
		"element2" : "",
		
		#STATUS EFFECTS:
		"ailment" : 0,##0 is none, see above
		"ailCount" : 0.0,#a float to record or healing process
		"ailTimer" : 0.0,#a float for recording the periodic timer for status effects, (we can increase it by random intervals each frame)
		
		"HP" : 150,
		"maxHP" : 150,
		"stamina" : 100,
		"maxStamina" : 100,
		"stamRegen" : 75,
		"physAtk" : 75,
		"physDef" : 85,
		"spclAtk" : 75,
		"spclDef" : 85,
		"speed" : 50, #increases evade distance too
		"evasion" : 75,
		#stranger stats
		"climb" : 45.0, #allows us to walk up steeper hills
		
		"moves" : {
			"A" : "Beam",
			"B" : "Breath",
			"X" : "Charge Punch",
			"Y" : "Slam"
		},
		"base" : {
			"maxHP" : 150,
			"maxStamina" : 100,
			"stamRegen" : 75,
			"physAtk" : 75,
			"physDef" : 75,
			"spclAtk" : 75,
			"spclDef" : 75,
			"speed" : 75, #increases evade distance too
			"evasion" : 75,
			"climb" : 45.0, #allows us to walk up steeper hills
		}
	},
}


var players = []

###########################################################
# CONTROL SWITCHING
###########################################################
func set_control(new_controller, player_index: int = 0):
	if player_index < 0 or player_index >= players.size():
		push_warning("Invalid player index: %d" % player_index)
		return

	var player = players[player_index]
	var current_controller = player["current_controller"]

	if current_controller:
		current_controller.is_controlled = false
		player["previous_controller"] = current_controller

	player["current_controller"] = new_controller
	new_controller.is_controlled = true
	new_controller.playerID = player_index

	if new_controller.has_method("on_set_control"):
		new_controller.on_set_control()



func _ready():
	var player_count = 2
	
	#print("ControllerManager ready — players:", player_count, " splitScreen:", use_split_screen)

	# Preload input providers
	var input_p1_scene = preload("res://controllers/p1InputProvider.tscn")
	var input_p2_scene = preload("res://controllers/p2InputProvider.tscn")

	# Create per-player data
	for i in range(player_count):
		var provider
		if i == 0:
			provider = input_p1_scene.instantiate()
		elif i == 1:
			provider = input_p2_scene.instantiate()
		else:
			# fallback, in case more players later
			
			provider = input_p1_scene.instantiate()
			#provider = input_provider_scene.instantiate()

		add_child(provider)

		var player_data = {
			"index": i,
			"input_provider": provider,
			"current_controller": null,
			"previous_controller": null,
			"camera": null,
			"viewport": null,#the viewport for seeing the screen
			"container": null,
			
			"uiViewport": null, #the viewport for seeing the GUI
			"uiMesh": null,#the mesh for displaying the GUI
			
			#these parts need to be saved
			"inventory" : {
				#e.g. "gravelrock" : 20,
			},
			"inventory_size" : 10,#this can change for each player as we upgrade
			"money" : 100,#TODO set to zero, start with 100 for testing use to buy items
			#we might also need a box of monsters we have
			#a box of items we store, not in our active inventory
			
		}
		players.append(player_data)


	var p1monster = $Player
	var p2monster = $Player2
	set_up_monster(p1monster, 0)
	set_up_monster(p2monster, 1)
	print("monsters p1 ", p1monster, ", p2 ", p2monster)

	
	set_control(p1monster, 0)
	
	
	var ui1 = ui_scene.instantiate()
	$SubViewport.add_child(ui1)
	ui1.name = "UIControl"
	## Apply SubViewport texture to mesh if used
	var mat = $FreeCam/MeshInstance3D.get_active_material(0)
	mat.albedo_texture = $SubViewport.get_texture()
	players[0]["camera"] = $FreeCam
	players[0]["uiMesh"] = $FreeCam/MeshInstance3D
	players[0]["uiViewport"] = $SubViewport


	#updating attack icons
	update_attack_icons(p1monster, 0)
	
	
	var AINodePreload = load("res://entities/monster_ai.tscn")
	#for index in range(playerIsHuman.size()):
		#var val = playerIsHuman[index]
		#print("player ", index, "is human? ", val)
		#if val == false:
			#var monsterAIPath = "res://entities/monster_ai.tscn"
	var monsterNode = p2monster
	print("monsterNode = ", monsterNode)
	var AINode = AINodePreload.instantiate()
	monsterNode.add_child(AINode)
	monsterNode.cpuAiNode = AINode
	#print("player ", index, "is human? ", val)
	
	
	
	
	
	
	
	#p2monster.queue_free()##TESTING
	p2monster.cpuAiNode.switch_states("peaceful")#so it doesn't attack you unless you attack it



	$InteractArea.masterRefNode = self
	$InteractArea2.masterRefNode = self






#########################################
#   PRocess and helper functions
#######################################

###########################################################
# MAIN LOOP
###########################################################
func _physics_process(delta):
	for player_data in players:
		var controller = player_data["current_controller"]
		var provider = player_data["input_provider"]
		if not controller or not provider:
			continue
		var input_data = provider.get_input_data()
		controller.handle_input(delta, input_data)


################################################################
## UI UPDATES (Shared)
################################################################

func get_player_var(player_index: int, variable_name: String):
	if player_index < 0 or player_index >= players.size():
		if player_index != -1:#ai has player index of -1
			push_warning("Invalid player index: %d" % player_index)
		return null
	return players[player_index].get(variable_name, null)

func get_player_camera(player_index: int):
	#return players[player_index]["camera"]
	return get_player_var(player_index, "camera")
#











func set_up_monster(monster, index):
	
	#var monsterPath = "res://entities/controllableMonster.tscn"
	#var monster = load(monsterPath).instantiate()
	monster.masterNodeRef = self
	#$Entities.add_child(monster)
	monster.global_transform.origin += Vector3(index, 3.0, index)
	
	monster.stats = monsterData[index]
	#if p1MonsterName != "":
		#$Entities/Player.stats["species"] = p1MonsterName
	monster._stats_were_set()

	
	monster.teamID = index
	monster.name = str("Player",index)
	if index == 0:
		monster.name = "Player"
	print("player1 = ", monster)
	print("player1 team = ",monster.teamID)
	
	#loadedMonsters.append(monster)






























##########
####################
##############################
########################################
##################################################
############################################################
######################################################################
#           UI
######################################################################
############################################################
##################################################
########################################
##############################
####################
##########


##AFTER UI UPDATE:
func refresh_player_ui(playerID: int = 0):
	#maybe this should be a tag that gets updated so it only happens once per frame
	var mat = players[playerID]["uiMesh"].get_active_material(0)
	var subViewport = players[playerID]["uiViewport"]
	mat.albedo_texture = subViewport.get_texture()

func update_attack_icons(monsterNode, playerID: int = 0):
	var myMoveDic = monsterNode.stats["moves"]
	var subViewport = players[playerID]["uiViewport"]
	if subViewport == null:
		return
	for buttChar in ["A", "B", "X", "Y"]:
		var pathAlpha = "UIControl/HBoxUI/Moves/GridContainer/"
		var pathOmega = "/Icon"
		var textureRectNode = subViewport.get_node(str(pathAlpha, buttChar, pathOmega))
		var moveName = myMoveDic[buttChar]
		var iconPath = $AttacksData.moveData[moveName]["icon"]
		textureRectNode.texture = load(iconPath)#will this work?
	
	refresh_player_ui(playerID)

func update_chars_hp_bars(myCharRef):
	#better method, works for any nodes even those without hp bars
	var shouldUpdate = false
	var playerID = myCharRef.playerID
	var enemyCharRef = myCharRef.lastHitEnemy
	
	if playerID == -1:
		#I dont have a player assigned so I dont have a ui that needs rendering
		return
	
	
	
	if false == true:
		if playerID >= 0 and playerID < players.size():
			shouldUpdate = true
	else:
		if playerID == 0:
			shouldUpdate = true
	#instead of telling it the stats we should just update all of them and remember who our tergetted enemy is
	##TODO replace myStats and enemyStats with references to the nodes
	if shouldUpdate == false:
		return
		
		
	
	var myStats = myCharRef.stats
	
	
	#for playerID in range(players.size()):
		##var uiViewport = players[playerID]["uiViewport"]
		#
	var subViewport = players[playerID]["uiViewport"]
	if subViewport == null:
		return
	#we need to get the lower hps size and adjust the other one based on it, in case we have resized
	
	var maxSizeX = subViewport.get_node("UIControl/HBoxUI/Other/vBoxOther/Stats/VBoxBars/myHP/hpUnder").size.x
	var myHPratio = maxSizeX * float(myStats["HP"]) / float(myStats["maxHP"])
	subViewport.get_node("UIControl/HBoxUI/Other/vBoxOther/Stats/VBoxBars/myHP/hpAbove").size.x = myHPratio
	#subViewport.get_node("HBoxUI/Other/vBoxOther/Stats/VBoxBars/myHP/hpAbove").position.x = maxSizeX - myHPratio

	var myNameLabel = myStats["name"]
	if myStats["name"] == "":
		myNameLabel = myStats["species"]
	
	subViewport.get_node("UIControl/HBoxUI/Other/vBoxOther/Stats/VBoxBars/myHP/Label").text = str(myNameLabel, " HP: ", myStats["HP"])#str(myStats["HP"], " HP")

	#STAMINA
	#var maxSizeX = subViewport.get_node("UIControl/HBoxUI/Other/vBoxOther/Stats/VBoxBars/myStamina/staminaUnder").size,x
	var staminaBar = subViewport.get_node("UIControl/HBoxUI/Other/vBoxOther/Stats/VBoxBars/myStamina/staminaAbove")
	var myStamRatio = maxSizeX * float(myStats["stamina"]) / float(myStats["maxStamina"])
	staminaBar.size.x = myStamRatio
	subViewport.get_node("UIControl/HBoxUI/Other/vBoxOther/Stats/VBoxBars/myStamina/Label").text = str(myStats["stamina"], " Stamina")
	

	if enemyCharRef:
		if is_instance_valid(enemyCharRef):
			var enemyStats = enemyCharRef.stats
			subViewport.get_node("UIControl/HBoxUI/Other/vBoxOther/Stats/VBoxBars/enemiesHP/enemy_hpAbove").size.x = maxSizeX * float(enemyStats["HP"]) / float(enemyStats["maxHP"])
			var enemyNameLabel = enemyStats["name"]
			if enemyStats["name"] == "":
				enemyNameLabel = enemyStats["species"]
			subViewport.get_node("UIControl/HBoxUI/Other/vBoxOther/Stats/VBoxBars/enemiesHP/Label").text = str(enemyNameLabel, " HP: ", enemyStats["HP"])
	

	
	refresh_player_ui(playerID)
#
#func update_chars_stamina_bar(myCharRef):
	#refresh_player_ui(playerID)

func update_hp_bars(myStats, enemyStats, playerID: int = 0):
	
	var subViewport = players[playerID]["uiViewport"]
	if subViewport == null:
		return
	#we need to get the lower hps size and adjust the other one based on it, in case we have resized
	
	var maxSizeX = subViewport.get_node("UIControl/HBoxUI/Other/vBoxOther/Stats/VBoxBars/enemiesHP/enemy_hpUnder").size.x
	subViewport.get_node("UIControl/HBoxUI/Other/vBoxOther/Stats/VBoxBars/enemiesHP/enemy_hpAbove").size.x = maxSizeX * float(enemyStats["HP"]) / float(enemyStats["maxHP"])
	var myHPratio = maxSizeX * float(myStats["HP"]) / float(myStats["maxHP"])
	subViewport.get_node("UIControl/HBoxUI/Other/vBoxOther/Stats/VBoxBars/myHP/hpAbove").size.x = myHPratio
	#subViewport.get_node("HBoxUI/Other/vBoxOther/Stats/VBoxBars/myHP/hpAbove").position.x = maxSizeX - myHPratio
	var enemyNameLabel = enemyStats["name"]
	if enemyStats["name"] == "":
		enemyNameLabel = enemyStats["species"]
	subViewport.get_node("UIControl/HBoxUI/Other/vBoxOther/Stats/VBoxBars/enemiesHP/Label").text = str(enemyNameLabel, " HP: ", enemyStats["HP"])
	
	var myNameLabel = myStats["name"]
	if myStats["name"] == "":
		myNameLabel = myStats["species"]
	
	subViewport.get_node("UIControl/HBoxUI/Other/vBoxOther/Stats/VBoxBars/myHP/Label").text = str(myNameLabel, " HP: ", myStats["HP"])#str(myStats["HP"], " HP")
	
	refresh_player_ui(playerID)

func update_cooldown_labels(buttonChar: String, value, playerID: int = 0):
	var subViewport = players[playerID]["uiViewport"]
	if subViewport == null:
		return
	var labelPath = str("UIControl/HBoxUI/Moves/GridContainer/",buttonChar.to_upper(),"/MP")
	var formattedVal = str(value).substr(0,4)
	subViewport.get_node(labelPath).text = str(formattedVal, "%")
	
	refresh_player_ui(playerID)



func update_generalCooldown_lock_visual(ifVisible: bool, playerID: int = 0):
	var subViewport = players[playerID]["uiViewport"]
	if subViewport == null:
		return
	subViewport.get_node("UIControl/HBoxUI/Moves/GridContainer/TL/lockVisual").visible = ifVisible
	
	refresh_player_ui(playerID)

func update_generalCooldown_lock_visual_SAFE(ifVisible: bool, playerID: int = 0):
	var subViewport = players[playerID]["uiViewport"]
	if subViewport == null:
		return
	var current = subViewport.get_node("UIControl/HBoxUI/Moves/GridContainer/TL/lockVisual").visible
	if current != ifVisible:
		subViewport.get_node("UIControl/HBoxUI/Moves/GridContainer/TL/lockVisual").visible = ifVisible
	
	refresh_player_ui(playerID)

func update_status_ui(condition, timerString, playerID: int = 0):
	var subViewport = players[playerID]["uiViewport"]
	if subViewport == null:
		return
	subViewport.get_node("UIControl/HBoxUI/Other/vBoxOther/Info/Status/Label").text = condition
	subViewport.get_node("UIControl/HBoxUI/Other/vBoxOther/Info/Status/Timer").text = timerString
	refresh_player_ui(playerID)

func update_inventory_ui(invIndex, playerID: int = 0):
	var subViewport = players[playerID]["uiViewport"]
	if subViewport == null:
		return
	
	var invKeys = players[playerID]["inventory"].keys()
	if invKeys.size() <= 0:
		subViewport.get_node("UIControl/HBoxUI/Other/vBoxOther/Info/Items/SelectedItem/Label").text = "No Items"
		subViewport.get_node("UIControl/HBoxUI/Other/vBoxOther/Info/Items/RightItem/Label").text = ""
		subViewport.get_node("UIControl/HBoxUI/Other/vBoxOther/Info/Items/LeftItem/Label").text = ""
		return
	#if invIndex >= invKeys.size() or invIndex < 0:
		#print("inventory index is out of bounds")
	invIndex = invIndex % invKeys.size()
	#CURRENT SELECTED
	var itemName = invKeys[invIndex]
	var amount = players[playerID]["inventory"][itemName]
	subViewport.get_node("UIControl/HBoxUI/Other/vBoxOther/Info/Items/SelectedItem/Label").text = itemName
	subViewport.get_node("UIControl/HBoxUI/Other/vBoxOther/Info/Items/SelectedItem/Amount").text = str(amount)
	#LEFT
	itemName = invKeys[(invIndex-1)%invKeys.size()]
	amount = players[playerID]["inventory"][itemName]
	subViewport.get_node("UIControl/HBoxUI/Other/vBoxOther/Info/Items/LeftItem/Label").text = itemName
	subViewport.get_node("UIControl/HBoxUI/Other/vBoxOther/Info/Items/LeftItem/Amount").text = str(amount)
	#RIGHT
	itemName = invKeys[(invIndex+1)%invKeys.size()]
	amount = players[playerID]["inventory"][itemName]
	subViewport.get_node("UIControl/HBoxUI/Other/vBoxOther/Info/Items/RightItem/Label").text = itemName
	subViewport.get_node("UIControl/HBoxUI/Other/vBoxOther/Info/Items/RightItem/Amount").text = str(amount)
	refresh_player_ui(playerID)
