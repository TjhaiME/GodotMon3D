extends Control


#we need a new game title
#GodotMon is taken but as a 2d pokemon game
#godot used to be called Larvita and Legacy
#so LegacyMon could work
#
#openMon taken by web versions

#GodotMon 3D


var p1MonsterName := ""
var p2MonsterName := ""

var p1MonsterStats := {}
var p2MonsterStats := {}

var monsterSpeciesList := [
	"Alien", "Birb", "BlueDemon", "Bunny",
	"Cactoro", "Demon", "Dino", "Fish", "Frog",
	"Monkroose", "MushroomKing", "Ninja", "Orc",
	"Tribal", "Yeti"
]


var monsterDex = {
	#species as key : defaultDic
}
var defaultMonsterDic = {
	"species" : "Yeti",
	
	#ElementTypes
	"element1" : "Ice",
	"element2" : "",
	
	"maxHP" : 150,
	"physAtk" : 75,
	"physDef" : 75,
	"spclAtk" : 75,
	"spclDef" : 75,
	"speed" : 75, 
	"evasion" : 75,
	"climb" : 45.0, 
	"maxStamina" : 100,
	"stamRegen" : 50,


	
	"colRadius" : 0.3,
	"colHeight" : 1.5,
	
	
}

var defaultMonsterDicTypes = {
	"species" : TYPE_STRING,
	
	#ElementTypes
	"element1" : TYPE_STRING,
	"element2" : TYPE_STRING,
	
	"maxHP" : TYPE_INT,
	"physAtk" : TYPE_INT,
	"physDef" : TYPE_INT,
	"spclAtk" : TYPE_INT,
	"spclDef" : TYPE_INT,
	"speed" : TYPE_INT, 
	"evasion" : TYPE_INT,
	"climb" : TYPE_FLOAT, 
	"maxStamina" : TYPE_INT,
	"stamRegen" : TYPE_INT,


	
	"colRadius" : TYPE_FLOAT,
	"colHeight" : TYPE_FLOAT,
	
	
}

var defaultMoves = {
	"A" : "Beam",
	"B" : "Charge Punch",
	"X" : "Slam",
	"Y" : "Breath",
}


func load_monster_table(path: String) -> Dictionary:
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Could not open monsterDex CSV file: %s" % path)
		return {}
	print("file = ", file)

	#var lines = file.get_as_text().strip_edges().split("\r\n")
	var text := file.get_as_text()

	# Normalize all possible line endings:
	# Windows: \r\n
	# Mac (old): \r
	# Linux/most: \n
	text = text.replace("\r\n", "\n").replace("\r", "\n")
	#then split it
	var lines := text.strip_edges().split("\n")


	
	print("lines = ", lines)
	var headers = lines[0].split(",")
	
	
	
	
	
	
	var monsters: Array = []

	for i in range(1, lines.size()):
		
		var values = lines[i].split(",")
		print("values = ", values)
		var entry: Dictionary = {}
		for j in range(headers.size()):
			#we have strings, ints and floats
			var key = headers[j]
			var keyType = defaultMonsterDicTypes[key]
			if key in ["element1", "element2"]:
				#we format the element value string
				var elementUnformatted = values[j]
				var elementFormatted = elementUnformatted
				if elementUnformatted != "":
					elementFormatted = str(elementUnformatted[0].to_upper(),elementUnformatted.substr(1).to_lower())
				entry[key] = elementFormatted
			elif keyType == TYPE_INT:
				entry[key] = int(values[j])
			elif keyType == TYPE_FLOAT:
				entry[key] = float(values[j])
			else:#assume string
				entry[key] = values[j]
			
		monsters.append(entry)

	var newMonsterDex = {}
	for monsterData in monsters:
		print("monsterData = ", monsterData)
		var newKey = monsterData["species"]
		newMonsterDex[newKey] = monsterData
		
		newMonsterDex[newKey]["moves"] = defaultMoves.duplicate()
		newMonsterDex[newKey]["colRadius"] = 0.3
		newMonsterDex[newKey]["colHeight"] = 1.5
	print("monsterDex = ",monsterDex)
	return newMonsterDex




func _ready():
	monsterDex = load_monster_table("res://data/monsterDex.csv")
	print("monsterDex = ", monsterDex)
	populate_monster_list()
	_on_p1_monster_selected(0)
	_on_p2_monster_selected(1)
	#update_current_selected_monster()
	$VBoxTitle/Options/VBoxContainer/QuickBattle.pressed.connect(_on_quick_battle_pressed)
	$VBoxTitle/Options/VBoxContainer/SplitBattle.pressed.connect(_on_splitscreen_battle_pressed)
	$VBoxTitle/Options/VBoxContainer/BrawlBattle.pressed.connect(_on_brawl_battle_pressed)
	#$VBoxTitle/Options/VBoxContainer/Birdseye2PBattle.pressed.connect(_on_birdseye_2p_battle_pressed)

func _start_quick_battle(p1IsHuman = true, p2IsHuman = false):
	
	p1MonsterStats = monsterDex[p1MonsterName]
	p2MonsterStats = monsterDex[p2MonsterName]
	
	var newMonsterData = {0:p1MonsterStats,1:p2MonsterStats}
	
	var preReadyVars = {
		"use_split_screen" : false,
		"playerIsHuman" : [p1IsHuman, p2IsHuman],
		#"p1MonsterName" : p1MonsterName,
		#"p2MonsterName" : p2MonsterName,
		"monsterData" : newMonsterData,
	}
	
	_start_battle(preReadyVars)

func _on_quick_battle_pressed():
	_start_quick_battle(true, false)

func _on_birdseye_2p_battle_pressed():
	_start_quick_battle(true, true)

func _on_splitscreen_battle_pressed():
	
	p1MonsterStats = monsterDex[p1MonsterName]
	p2MonsterStats = monsterDex[p2MonsterName]
	
	var newMonsterData = {0:p1MonsterStats,1:p2MonsterStats}
	
	var preReadyVars = {
		"use_split_screen" : true,
		"playerIsHuman" : [true, true],
		#"p1MonsterName" : p1MonsterName,
		#"p2MonsterName" : p2MonsterName,
		"monsterData" : newMonsterData,
	}
	
	_start_battle(preReadyVars)

func _on_brawl_battle_pressed():
	
	p1MonsterStats = monsterDex[p1MonsterName]
	p2MonsterStats = monsterDex[p2MonsterName]
	
	var newMonsterData = {0:p1MonsterStats.duplicate(true),1:p2MonsterStats.duplicate(true)}
	
	_on_p1_monster_selected(0)
	_on_p2_monster_selected(1)
	newMonsterData[2] = p1MonsterStats
	newMonsterData[3] = p2MonsterStats
	
	var preReadyVars = {
		"use_split_screen" : false,
		"playerIsHuman" : [true, false, false, false],
		#"p1MonsterName" : p1MonsterName,
		#"p2MonsterName" : p2MonsterName,
		"monsterData" : newMonsterData,
	}
	
	_start_battle(preReadyVars)

func _start_battle(preReadyVars):
	# Store selections globally
	#central.p1MonsterName = p1MonsterName
	#central.p2MonsterName = p2MonsterName
	
	# Switch to the main game scene
	
	
	central.change_scene("res://master_node_Flat.tscn", preReadyVars)

func populate_monster_list():
	var p1Menu = $VBoxTitle/MonsterSelect/ChangeP1Monster.get_popup()
	var p2Menu = $VBoxTitle/MonsterSelect/ChangeP2Monster.get_popup()
	
	# Clear old items (if this runs multiple times)
	p1Menu.clear()
	p2Menu.clear()

	# Populate both menus
	for monster in monsterSpeciesList:
		p1Menu.add_item(monster)
		p2Menu.add_item(monster)

	# Connect signals once (prevents duplicates)
	if not p1Menu.is_connected("id_pressed", Callable(self, "_on_p1_monster_selected")):
		p1Menu.connect("id_pressed", Callable(self, "_on_p1_monster_selected"))
	if not p2Menu.is_connected("id_pressed", Callable(self, "_on_p2_monster_selected")):
		p2Menu.connect("id_pressed", Callable(self, "_on_p2_monster_selected"))


func _on_p1_monster_selected(id: int):
	p1MonsterName = monsterSpeciesList[id]
	p1MonsterStats = monsterDex[p1MonsterName]
	update_current_selected_monster()


func _on_p2_monster_selected(id: int):
	p2MonsterName = monsterSpeciesList[id]
	p2MonsterStats = monsterDex[p2MonsterName]
	update_current_selected_monster()


func update_current_selected_monster():
	
	var p1Menu = $VBoxTitle/MonsterSelect/ChangeP1Monster
	var p2Menu = $VBoxTitle/MonsterSelect/ChangeP2Monster
	
	var iconPathAlpha = "res://assets/monsterIcons/"#MonsterName.PNG"
	var iconPath1 = str(iconPathAlpha,p1MonsterName, ".PNG")
	
	var textStart1 = "Change P1 Monster\nCurrent: %s" % p1MonsterName
	var stats = p1MonsterStats
	var textEnd = str(", Type(s):",stats["element1"], "/ ", stats["element2"],"\npAtk: ",stats["physAtk"], " sAtk: ",stats["spclAtk"], 
						"\n pDef: ", stats["physDef"], " sDef: ", stats["spclDef"], " speed: ", stats["speed"])
	
	p1Menu.text = textStart1 + textEnd
	p1Menu.icon = load(iconPath1)
	
	
	stats = p2MonsterStats
	if stats == {}:
		return
	
	var iconPath2 = str(iconPathAlpha,p2MonsterName, ".PNG")
	
	var textStart2 = "Change P1 Monster\nCurrent: %s" % p2MonsterName
	#stats = p2MonsterStats
	textEnd = str(", Types:",stats["element1"], "/ ", stats["element2"],"\npAtk: ",stats["physAtk"], " sAtk: ",stats["spclAtk"], 
					"\n pDef: ", stats["physDef"], " sDef: ", stats["spclDef"], " speed: ", stats["speed"])
	
	p2Menu.text = textStart2 + textEnd
	p2Menu.icon = load(iconPath2)

















#extends Control
#
#
#
#
#
#
#
#
#var p1MonsterName = ""
#var p2MonsterName = ""
#
#
#func update_current_selected_monster():
	#var p1Str = "Change P1 Monster
	#current: "
	#var p2Str = "Change P1 Monster
	#current: "
	#$VBoxTitle/Options/VBoxContainer/ChangeP1Monster.text = str(p1Str, p1MonsterName)
	#$VBoxTitle/Options/VBoxContainer/ChangeP2Monster.text = str(p2Str, p2MonsterName)
#
#var monsterSpeciesList = [
	#"Alien", "Birb", "BlueDemon", "Bunny",
	#"Cactoro", "Demon", "Dino", "Fish", "Frog",
	#"Monkroose", "MushroomKing", "Ninja", "Orc",
	#"Tribal", "Yeti"
#]
#func populate_monster_list():
	##I have a menu button node (changeMonster) and I want to dynamically populate it's items using this array, so that when clicked it updtes the selected monster runs the above function
