extends Node


#we need a moves data base
#sso we can summon a move of different types using just data and we can easily add moves to the game
#we do it as a .gd with a database so we can have variables that we can tweak later
#we can export a json for the final version


#some attacks should reset life counter between charge and release states..if not that being default

var elementInts = {
	"Fire" : 0,
	"Plant" : 1,
	"Water" : 2,
	"Electric" : 3,
	"Ice" : 4,
	"Stone" : 5,
	"Wind" : 6
}

var elMods = { #saved as a dictionary so it can be modified later
	"X" : 0.25,
	"W" : 0.5,
	"N" : 1.0,
	"S" : 2.0
}

#elementTable[attacker][defender] I think
var elementTable = [
	#DEF [Fire	Plant	  Water		Electric	Ice		Stone		Wind]
	[elMods.N, elMods.S, elMods.X, elMods.N, elMods.S, elMods.W, elMods.W],#Fire
	[elMods.X, elMods.N, elMods.S, elMods.W, elMods.W, elMods.S, elMods.N],#Plant
	[elMods.S, elMods.S, elMods.N, elMods.N, elMods.X, elMods.W, elMods.W],#Water
	[elMods.W, elMods.W, elMods.S, elMods.S, elMods.N, elMods.X, elMods.N],#Electric
	[elMods.W, elMods.N, elMods.W, elMods.X, elMods.N, elMods.S, elMods.S],#Ice
	[elMods.N, elMods.W, elMods.W, elMods.S, elMods.S, elMods.N, elMods.X],#Stone
	[elMods.S, elMods.X, elMods.N, elMods.W, elMods.W, elMods.N, elMods.S]#Wind
]#																		# ATK ^

func get_damage_type_multiplier(atkType, defenderType1, defenderType2 = ""):
	var dmgMult = 1.0
	
	
	var atkTypeInt = elementInts[atkType]
	var defTypeInt1 = elementInts[defenderType1]
	dmgMult = elementTable[atkTypeInt][defTypeInt1]
	
	if elementInts.has(defenderType2):
		var defTypeInt2 = elementInts[defenderType2]
		var dmgMult2 = elementTable[atkTypeInt][defTypeInt1]
		dmgMult *= dmgMult2
	
	
	return dmgMult


func _ready() -> void:
	print("dmgMult1 = ", get_damage_type_multiplier("Fire", "Plant", ""))
	print("dmgMult2 = ", get_damage_type_multiplier("Fire", "Plant",  "Ice"))


#add a flags variable and a flagsType variable
#flagType can be type addition, type subtraction, override, blacklist
#e.g. punch type attacks already have flags, addition mode adds more, like chargePower, override would use ONLY the flags
#type subtraction removes the flags from the ones used in the type, #blacklist turns on ALL flags and removes only those mentioned

#we already have flags like "craterRadius" : 10.0,#adds a crater hen it hits the floor,
#and "ignore_floor" that do this.

#if element is Innate it should use the monsters first type
#if element is Innate2 it should use the monsters first type
#if element is InnateRandom it should use the monsters types randomly

#we need a way to override the default movement states for each thingo
#after it is set in the code
#apply it top caharge punch so it doesnt move when charging like beam
#DONE HERE IN attack.gd
#func _after_parent_ready() -> void:
	#if atkData.has("controlState"):
		#controllableMoveState = atkData["controlState"]
	#
	#if atkData.has("rotationState"):
		#controllableMoveState = atkData["rotationState"]
	#
	#if atkData.has("releaseState"):
		#controllableMoveState = atkData["releaseState"]

#disable moves, moves that taRGET COOLDOWNS

#some moves could cost more than 100 cooldown giving you extra time you need for it to recharge. No move should fail when you are on 100.0 or above

var basePower = 50#make a number between [0,100]

##TODO:
#make a general moves dictionary that adds to moveData a version of the move with each element
#e.g. for beam we should have all elemental versions
#then we also have charge beam and breath etc that all have elemental and innate versions
#beam, breath, punch all need to be modified to be general moves that get added


var moveData = {
	"Dodge" : {
		"icon" : "res://assets/icons/attacks/dodge.png",
		"scene" : null, #summon a base scene with a visual effect
		"visual" : null, #visual effect
		"radius" : 0.4, #width of attack
		"power" : 1.5*basePower, #75 as a multiple of basePower so we can tweak later
		"element" : "Plant", #element type of attack
		"atkType" : "slam", #some monsters could have abilities to power up certain types of moves, can also use to determine how to do the attack
		"special" : false, #physical or special attack
		"range" : -1.0, #how far before attack disappears, set as negative for infinite
		"lifetime" : 0.25, #how long does it last
		"controllableSpeed" : 1.0,
		"releaseSpeed" : 15.0,
		"rotationSpeed" : 10.0,
		"cost": 5.0,#for testing #was 60.0,#how much "cooldown" does it cost to use this move, 60 means we can use once then wait a little bit and use again in succession but then we have to recharge heapse
		#"extraCooldownFunc" : "", #no function to generate extra cost to the atack while we are controlling the attack
		#"primaryAtkFunc" : "",#a function to help provide variable damage, e.g. speed influences power, or charge for more power (but some of this can also be done with atkType)
		#"secondaryAtkFunc" : ""#another function for other variable things, like status effects
	},
	"Fire Punch" : {
		"icon" : "res://assets/icons/attacks/punch.png",
		"scene" : "res://attacks/base/punch.tscn", #summon a base scene with a mesh visual effect
		"visual" : "res://effects/electric.tscn", #visual effect to represent the element
		"radius" : 0.4, #width of attack
		"power" : 1.5*basePower, #75 as a multiple of basePower so we can tweak later
		"element" : "Fire", #element type of attack
		"atkType" : "punch", #some monsters could have abilities to power up certain types of moves, can also use to determine how to do the attack
		"special" : false, #physical or special attack
		"range" : 3.0, #how far before attack disappears, set as negative for infinite
		"lifetime" : 1.5, #how long does it last
		"controllableSpeed" : 5.0,
		"releaseSpeed" : 10.0,
		"rotationSpeed" : 10.0,
		"cost": 5.0,#for testing #was 60.0,#how much "cooldown" does it cost to use this move, 60 means we can use once then wait a little bit and use again in succession but then we have to recharge heapse
		#"extraCooldownFunc" : "", #no function to generate extra cost to the atack while we are controlling the attack
		#"primaryAtkFunc" : "",#a function to help provide variable damage, e.g. speed influences power, or charge for more power
		#"secondaryAtkFunc" : "",#another function for other variable things, like status effects
		"craterRadius" : 10.0,#adds a crater when it hits the floor,
	},
	
	"Ice Punch" : {
		"icon" : "res://assets/icons/attacks/punch.png",
		"scene" : "res://attacks/base/punch.tscn", #summon a base scene with a visual effect
		"visual" : "res://effects/ice.tscn", #visual effect
		"radius" : 0.4, #width of attack
		"power" : 1.5*basePower, #75 as a multiple of basePower so we can tweak later
		"element" : "Ice", #element type of attack
		"atkType" : "punch", #some monsters could have abilities to power up certain types of moves, can also use to determine how to do the attack
		"special" : false, #physical or special attack
		"range" : 3.0, #how far before attack disappears, set as negative for infinite
		"lifetime" : 1.5, #how long does it last
		"controllableSpeed" : 5.0,
		"releaseSpeed" : 10.0,
		"rotationSpeed" : 10.0,
		"cost": 5.0,#for testing #was 60.0,#how much "cooldown" does it cost to use this move, 60 means we can use once then wait a little bit and use again in succession but then we have to recharge heapse
		#"extraCooldownFunc" : "", #no function to generate extra cost to the atack while we are controlling the attack
		#"primaryAtkFunc" : "",#a function to help provide variable damage, e.g. speed influences power, or charge for more power
		#"secondaryAtkFunc" : "",#another function for other variable things, like status effects
		"craterRadius" : 10.0,#adds a crater hen it hits the floor,
	},
	
	"Drain Punch" : {
		"icon" : "res://assets/icons/attacks/chargepunch.png",
		"scene" : "res://attacks/base/punch.tscn", #summon a base scene with a visual effect
		"visual" : "res://effects/dark.tscn", #visual effect
		"radius" : 0.4, #width of attack
		"power" : 1.5*basePower, #75 as a multiple of basePower so we can tweak later
		"element" : "Innate", #element type of attack
		"atkType" : "punch", #some monsters could have abilities to power up certain types of moves, can also use to determine how to do the attack
		"special" : false, #physical or special attack
		"range" : 3.0, #how far before attack disappears, set as negative for infinite
		"lifetime" : 1.5, #how long does it last
		"controllableSpeed" : 5.0,
		"releaseSpeed" : 10.0,
		"rotationSpeed" : 10.0,
		"cost": 5.0,#for testing #was 60.0,#how much "cooldown" does it cost to use this move, 60 means we can use once then wait a little bit and use again in succession but then we have to recharge heapse
		"drain" : 0.1, #the proportion of health drained
		#"extraCooldownFunc" : "", #no function to generate extra cost to the atack while we are controlling the attack
		#"primaryAtkFunc" : "",#a function to help provide variable damage, e.g. speed influences power, or charge for more power (but some of this can also be done with atkType)
		#"secondaryAtkFunc" : ""#another function for other variable things, like status effects
	},
	
		"Charge Punch" : {
		"icon" : "res://assets/icons/attacks/chargepunch.png",
		"scene" : "res://attacks/base/charge_punch.tscn", #summon a base scene with a visual effect
		"visual" : "res://effects/dark.tscn", #FIX
		"radius" : 0.4, #width of attack
		"power" : 1.0*basePower, #75 as a multiple of basePower so we can tweak later
		"element" : "Innate", #element type of attack
		"atkType" : "punch", #some monsters could have abilities to power up certain types of moves, can also use to determine how to do the attack
		"special" : false, #physical or special attack
		"range" : 3.0, #how far before attack disappears, set as negative for infinite
		"lifetime" : 1.5, #how long does it last
		"controllableSpeed" : 0.0,
		"releaseSpeed" : 10.0,
		"rotationSpeed" : 10.0,
		"cost": 5.0,#for testing #was 60.0,#how much "cooldown" does it cost to use this move, 60 means we can use once then wait a little bit and use again in succession but then we have to recharge heapse
		"chargeState" : "size",#"power",
		"chargeVar" : 2.5,#for power it is max power multiplier
		"controlState" : central.controllableMoveStates["forward"],
		"rotationState" : central.rotationMoveStates["allow"],
		"releaseState" : central.releaseMoveStates["z"],
		#"extraCooldownFunc" : "", #no function to generate extra cost to the atack while we are controlling the attack
		#"primaryAtkFunc" : "",#a function to help provide variable damage, e.g. speed influences power, or charge for more power (but some of this can also be done with atkType)
		#"secondaryAtkFunc" : ""#another function for other variable things, like status effects
		"craterRadius" : 1.0,#adds a crater hen it hits the floor,
	},
	
		"Beam" : {#res://attacks/effects/beamBreath.tscn
		"icon" : "res://assets/icons/attacks/beam.png",
		"scene" : "res://attacks/beams/beamAttack.tscn",#"res://attacks/base/NodeAttack_Beam.tscn",#"res://attacks/base/AreaAttack_Beam.tscn", #summon a base scene with a visual effect
		"visual" : "res://effects/electric.tscn", #visual effect
		"radius" : 0.4, #width of attack
		"power" : 1.5*basePower, #75 as a multiple of basePower so we can tweak later
		"element" : "Electric", #element type of attack
		"atkType" : "beam", #some monsters could have abilities to power up certain types of moves, can also use to determine how to do the attack
		"special" : true, #physical or special attack
		"range" : -1.0, #how far before attack disappears, set as negative for infinite
		"lifetime" : 3.5, #how long does it last
		"controllableSpeed" : 0.0,
		"releaseSpeed" : 5.0,
		"rotationSpeed" : 10.0,
		"cost": 5.0,#for testing #was 60.0,#how much "cooldown" does it cost to use this move, 60 means we can use once then wait a little bit and use again in succession but then we have to recharge heapse
		#"extraCooldownFunc" : "", #no function to generate extra cost to the atack while we are controlling the attack
		#"primaryAtkFunc" : "",#a function to help provide variable damage, e.g. speed influences power, or charge for more power (but some of this can also be done with atkType)
		#"secondaryAtkFunc" : "",#another function for other variable things, like status effects
		"ignoreFloor" : true
	},

		"Breath" : {#res://attacks/effects/beamBreath.tscn
		"icon" : "res://assets/icons/attacks/breath.png",
		"scene" : "res://attacks/beams/breathAttack.tscn",#"res://attacks/base/NodeAttack_Beam.tscn",#"res://attacks/base/AreaAttack_Beam.tscn", #summon a base scene with a visual effect
		"visual" : "res://effects/electric.tscn", #visual effect
		"radius" : 0.4, #width of attack
		"power" : 1.5*basePower, #75 as a multiple of basePower so we can tweak later
		"element" : "Fire", #element type of attack
		"atkType" : "beam", #some monsters could have abilities to power up certain types of moves, can also use to determine how to do the attack
		"special" : true, #physical or special attack
		"range" : 5.0, #how far before attack disappears, set as negative for infinite
		"lifetime" : 3.5, #how long does it last
		"controllableSpeed" : 0.0,
		"releaseSpeed" : 5.0,
		"rotationSpeed" : 10.0,
		"cost": 5.0,#for testing #was 60.0,#how much "cooldown" does it cost to use this move, 60 means we can use once then wait a little bit and use again in succession but then we have to recharge heapse
		#"extraCooldownFunc" : "", #no function to generate extra cost to the atack while we are controlling the attack
		#"primaryAtkFunc" : "",#a function to help provide variable damage, e.g. speed influences power, or charge for more power (but some of this can also be done with atkType)
		#"secondaryAtkFunc" : "",#another function for other variable things, like status effects
		"ignoreFloor" : true
	},

		"Slam" : {
		"icon" : "res://assets/icons/attacks/slam.png",
		"scene" : "res://attacks/base/newSlam.tscn",#"res://attacks/base/otherAttack_Slam.tscn", #summon a base scene with a visual effect
		"visual" : "res://effects/electric.tscn", #visual effect
		"radius" : 0.4, #width of attack
		"power" : 1.5*basePower, #75 as a multiple of basePower so we can tweak later
		"element" : "Plant", #element type of attack
		"atkType" : "slam", #some monsters could have abilities to power up certain types of moves, can also use to determine how to do the attack
		"special" : false, #physical or special attack
		"range" : -1.0, #how far before attack disappears, set as negative for infinite
		"lifetime" : 0.25, #how long does it last
		"controllableSpeed" : 1.0,
		"releaseSpeed" : 15.0,
		"rotationSpeed" : 10.0,
		"cost": 5.0,#for testing #was 60.0,#how much "cooldown" does it cost to use this move, 60 means we can use once then wait a little bit and use again in succession but then we have to recharge heapse
		"impact" : Vector2(1.0,2.0),#horiztonal,vertical knockback
		"melee" : true
		#"extraCooldownFunc" : "", #no function to generate extra cost to the atack while we are controlling the attack
		#"primaryAtkFunc" : "",#a function to help provide variable damage, e.g. speed influences power, or charge for more power (but some of this can also be done with atkType)
		#"secondaryAtkFunc" : ""#another function for other variable things, like status effects
	},
	"Raise Spikes" : {
		"icon" : "res://assets/icons/attacks/spikes.png",
		"scene" : "res://attacks/base/spikes.tscn", #summon a base scene with a visual effect
		"visual" : "res://effects/dark.tscn", #visual effect
		"radius" : 0.4, #width of attack
		"power" : 1.5*basePower, #75 as a multiple of basePower so we can tweak later
		"element" : "Stone", #element type of attack
		"atkType" : "spike", #some monsters could have abilities to power up certain types of moves, can also use to determine how to do the attack
		"special" : false, #physical or special attack
		"range" : 3.0, #how far before attack disappears, set as negative for infinite
		"lifetime" : 1.5, #how long does it last
		"controllableSpeed" : 5.0,
		"releaseSpeed" : 10.0,
		"rotationSpeed" : 0.0,
		"cost": 5.0,#for testing #was 60.0,#how much "cooldown" does it cost to use this move, 60 means we can use once then wait a little bit and use again in succession but then we have to recharge heapse
		#"extraCooldownFunc" : "", #no function to generate extra cost to the atack while we are controlling the attack
		#"primaryAtkFunc" : "",#a function to help provide variable damage, e.g. speed influences power, or charge for more power (but some of this can also be done with atkType)
		#"secondaryAtkFunc" : ""#another function for other variable things, like status effects
	},
}
