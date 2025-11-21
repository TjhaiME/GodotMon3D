extends Node

#var p1MonsterName: String = ""
#var p2MonsterName: String = ""

var capsuleRadius = 0.3#for all of them
var capsuleHeight = 1.5#for all of them
#but they still need to be set for other (non-quaternius) monsters
#var monsterModelHeights = {
	#"Alien" : "?",
	#"Birb" : 1.5,
	#"BlueDemon" : 1.5,
	#"Bunny" : 1.5,
	#"Cactoro" : "res://assets/monsters/quaternius/glTF/Alien.gltf",
	#"Demon" : 1.5,
	#"Dino" : 1.5,
	#"Fish" : 1.5,
	#"Frog" : 1.5,
	#"Monkroose" : 1.5,
	#"MushroomKing" : "res://assets/monsters/quaternius/glTF/Alien.gltf",
	#"Ninja" : 1.5,
	#"Orc" : 1.5,
	#"Orc_Skull" : 1.5,
	#"Tribal" : "res://assets/monsters/quaternius/glTF/Alien.gltf",
	#"Yeti" : 1.5,
#}

#var monsterSpeciesList := [
	#"Alien", "Birb", "BlueDemon", "Bunny",
	#"Cactoro", "Demon", "Dino", "Fish", "Frog",
	#"Monkroose", "MushroomKing", "Ninja", "Orc",
	#"Tribal", "Yeti"
#]



# Optional: scene switching helper
func change_scene(target_path: String, preReadyVars = {}):
	var tree = get_tree()
	if tree.current_scene:
		tree.current_scene.queue_free()
	var new_scene = load(target_path).instantiate()
	
	#if we have preReadyVars we need to set before adding child
	for key in preReadyVars.keys():
		#if new_scene.get(key, null) != null:
		if key in new_scene:
			new_scene.set(key, preReadyVars[key])
	
	
	tree.root.add_child(new_scene)
	tree.current_scene = new_scene


#
var height_scale: float = 5.0
var heightmap_image: Image
var heightmap_texture: Texture2D


var size_x = 0.0#central.size_x
var size_z = 0.0#central.size_z
var cell_size = 0.0#central.cell_size

var terrain_global_pos = Vector3(0.0,0.0,0.0)#central.terrain_global_pos


var controllableMoveStates = {
	"direct" : 0, #only move where we tell you to move (allows rotation)
	"forward" : 1, #move forward automatically, use control stick for other basis vectors in 3d
	#"these with and without rotation as well" : 2,
	"limit" : 2, #like a flamethrower attack, moves forward to a range then "stops" (visual looks like it keeps going, use control stick to change angle
	"ignore" : 3,#dont stop the thing just because we are in control mode
	"none" : 4,
}

var rotationMoveStates = {
	"allow" : 0,
	"none" : 1,
	"limitBoth" : 2,#both control stick axes change the angle of the attack xz, xy
}

var releaseMoveStates = {
	"default" : 0,#use the last_velocity we had
	"override" : 1,#use a specific dir or function to get the dir
	"z" : 2, #use your z dir
}



#var monsterModelPaths = {
	#"Alien" : "res://assets/monsters/quaternius/glTF/Alien.gltf",
	#"Birb" : "res://assets/monsters/quaternius/glTF/Birb.gltf",
	#"BlueDemon" : "res://assets/monsters/quaternius/glTF/Alien.gltf",
	#"Bunny" : "res://assets/monsters/quaternius/glTF/Alien.gltf",
	#"Cactoro" : "res://assets/monsters/quaternius/glTF/Alien.gltf",
	#"Demon" : "res://assets/monsters/quaternius/glTF/Alien.gltf",
	#"Dino" : "res://assets/monsters/quaternius/glTF/Alien.gltf",
	#"Fish" : "res://assets/monsters/quaternius/glTF/Alien.gltf",
	#"Frog" : "res://assets/monsters/quaternius/glTF/Birb.gltf",
	#"Monkroose" : "res://assets/monsters/quaternius/glTF/Alien.gltf",
	#"MushroomKing" : "res://assets/monsters/quaternius/glTF/Alien.gltf",
	#"Ninja" : "res://assets/monsters/quaternius/glTF/Alien.gltf",
	#"Demon" : "res://assets/monsters/quaternius/glTF/Alien.gltf",
	#"Dino" : "res://assets/monsters/quaternius/glTF/Alien.gltf",
	#"Alien" : "res://assets/monsters/quaternius/glTF/Alien.gltf",
	#"Birb" : "res://assets/monsters/quaternius/glTF/Birb.gltf",
	#"BlueDemon" : "res://assets/monsters/quaternius/glTF/Alien.gltf",
	#"Bunny" : "res://assets/monsters/quaternius/glTF/Alien.gltf",
	#"Cactoro" : "res://assets/monsters/quaternius/glTF/Alien.gltf",
	#"Demon" : "res://assets/monsters/quaternius/glTF/Alien.gltf",
	#"Dino" : "res://assets/monsters/quaternius/glTF/Alien.gltf",
#}




var itemData = {
	"potion" : {
		"cost" : 10,
		"maxLimit" : 10,
		"description" : "heals 20 HP",
		"affects" : ["monster"],
		"heal" : 10,
	},
	"poison" : {
		"cost" : 5,
		"maxLimit" : 20,
		"description" : "if thrown deals 20 Damage to target hit",
		"affects" : ["monster"],
		"heal" : -20,
	},
	"maxPotion" : {
		"cost" : 50,
		"maxLimit" : 3,
		"description" : "heals 9999 HP",
		"affects" : ["monster"],
		"heal" : 9999,
	},
	"poop" : {
		"cost" : 0,
		"maxLimit" : 99,
		"description" : "a stupid item just for testing",
		"affects" : ["monster"]
	},
	"stamina leaf" : {
		"cost" : 1,
		"maxLimit" : 99,
		"description" : "restores % 25 stamina",
		"affects" : ["monster"],
		"stamRegen" : 25
	},
	"stamina fruit" : {
		"cost" : 20,
		"maxLimit" : 10,
		"description" : "restores % 100 stamina",
		"affects" : ["monster"],
		"stamRegen" : 100
	},
	"stamina poison" : {
		"cost" : 3,
		"maxLimit" : 99,
		"description" : "removes % 50 stamina",
		"affects" : ["monster"],
		"stamRegen" : -50
	},
	"toxic grenade" : {
		"cost" : 30,
		"maxLimit" : 10,
		"description" : "throw to induce a poison status effect on a target",
		"affects" : ["monster"],
		"statusAilment" : 1
	},
	"paralysis grenade" : {
		"cost" : 30,
		"maxLimit" : 10,
		"description" : "throw to induce a paralysis status effect on a target",
		"affects" : ["monster"],
		"statusAilment" : 2
	},
	"burn grenade" : {
		"cost" : 30,
		"maxLimit" : 10,
		"description" : "throw to induce a burn status effect on a target",
		"affects" : ["monster"],
		"statusAilment" : 3
	},#"stamina fruit", "stamina poison", "toxic grenade", "paralysis grenade", "burn grenade"
	"freeze grenade" : {
		"cost" : 30,
		"maxLimit" : 10,
		"description" : "throw to induce a freeze status effect on a target",
		"affects" : ["monster"],
		"statusAilment" : 4
	},
	"sleep grenade" : {
		"cost" : 30,
		"maxLimit" : 10,
		"description" : "throw to induce a sleep status effect on a target",
		"affects" : ["monster"],
		"statusAilment" : 5
	},
	"confuse grenade" : {
		"cost" : 30,
		"maxLimit" : 10,
		"description" : "throw to induce a confuse status effect on a target",
		"affects" : ["monster"],
		"statusAilment" : 6
	},
	"heal status potion" : {
		"cost" : 30,
		"maxLimit" : 10,
		"description" : "throw/use to remove status ailment effects on a target",
		"affects" : ["monster"],
		"statusAilment" : 0
	},
	"item10" : {
		"cost" : 4,
		"maxLimit" : 99,
		"description" : "a stupid item just for testing 10",
		"affects" : ["monster"]
	},
	"item11" : {
		"cost" : 5,
		"maxLimit" : 99,
		"description" : "a stupid item just for testing 11",
		"affects" : ["monster"]
	},
}

#items, like moves, and monsterDex entries should be able to be changed with just a dataset

func use_item(itemName, charNode, charType = "monster"):
	if ! itemData[itemName]["affects"].has(charType):
		print("cannot use item on this character type")
		return false
	
	#"hitStats" : {
		#"stat" : "HP",
		#"amount" : 9999
	#}
	if itemData[itemName].has("heal"):
		#we want to heal hp
		var amount = itemData[itemName]["heal"]
		charNode.stats["HP"] += amount
		if charNode.stats["HP"] > charNode.stats["maxHP"]:
			charNode.stats["HP"] = charNode.stats["maxHP"]
		elif charNode.stats["HP"] < 0.0:
			charNode.stats["HP"] = 0.0
			#do I need to kill the monster here...
			charNode.check_if_died()
	#"stamRegen" : 25
	if itemData[itemName].has("stamRegen"):
		#we want to heal hp
		var amount = itemData[itemName]["stamRegen"]
		charNode.stats["stamina"] += (float(amount)/100.0)*charNode.stats["maxStamina"]
		if charNode.stats["stamina"] > charNode.stats["maxStamina"]:
			charNode.stats["stamina"] = charNode.stats["maxStamina"]
		elif charNode.stats["stamina"] < 0.0:
			charNode.stats["stamina"] = 0.0
	
	#"statusAilment"
	if itemData[itemName].has("statusAilment"):
		#charNode.stats["ailment"] = itemData[itemName]["statusAilment"]
		#charNode.stats["ailCount"] = 10.0#seconds of the effect
		#charNode.randAilmentThreshold = 0.1
		charNode.switch_status_ailment_state(itemData[itemName]["statusAilment"], 10.0)
	
	
	
	
	#item was used we must remove 1 from inventory
	charNode.masterNodeRef.players[charNode.playerID]["inventory"][itemName] -= 1
	if charNode.masterNodeRef.players[charNode.playerID]["inventory"][itemName] <= 0:
		charNode.masterNodeRef.players[charNode.playerID]["inventory"].erase(itemName)
	return true
