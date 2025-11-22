#extends "res://scripts/controllable.gd"
extends CharacterBody3D

#if we dodge onto a wall or we land on a wall we should enter climbing state DONE
#we need a jump button as well that we can direct with input DONE
#okay we have a jump now we need to make it move DONE
#we meed the jump to be bigger and have more oomph in it when given directional input
#could take advantage of jump_pressed and released signals, so we can charge up jumps
#or we could have guard+jump be a special crouch jump thingo
#we still have two more buttons, ones for item stuffs.

#while it is noe easier to enter climb state, it is much harder to get out of

#okay we can climb now (needs tweaking)
#would be better if we jump into the climb
#now we need to add dodge by using code similar to slam DONE
#then we need to turn slam into a hitbox based attack like the others DONE
#then we have the complete modular system (other than AI)

func shortcutFunctionForEasyDevelopment():
	
	#This is not used, it is just here so I can easily clink and jump to sections in the code
	#where similar functions lie
	
	shortcutFunctionForEasyDevelopment()#variable section at top, just scroll down
	on_set_control()#controllable section
	_stats_were_set()#initialisation section
	isRunning()#helper functions section
	end_attack(null)#attacking section
	_set_all_collision_to_zero()#collision section
	on_animation_finished("")#animation section
	check_activate_dodge({})#dodging section
	adjust_camera(0.001, Vector3(1,0,0))#camera section
	start_climb(Vector3(1,0,0))#climbing section
	cooldown_process(0.001)#cooldown section
	update_stamina(0.1) #stamina section
	_process(0.001)# = process section
	enter_terrain_effect(null)#terrain section

#quaternius monsters have animations
# e.g. $BlueDemon2/AnimationPlayer is the animation player
#BlueDemon2/CharacterArmature/Skeleton3D/BlueDemon is the meshInst

##############
############################
##########################################
########################################################
#                   VARIABLES
########################################################
##########################################
############################
##############




var knockedBack = false

var meshMasterNode = null
var lastHitEnemy = null


var is_controlled: bool = false
var playerID: int = -1#-1 means no player has been assigned

# Common stats or references
@export var move_speed := 5.0 #depreciated for attacks?
var old_move_speed = 0.0
@export var rotation_speed := 10.0

var hitboxDelta = 0.0

##TODO move elsewhere
var ailmentIDs = {
	"none" : 0,
	"poisoned" : 1,#take periodic damage over time
	"paralysed" : 2,#flinch periodically over time
	"burned" : 3,#random chance of flinch or damage (unreliable)
	"frozen" : 4,#immobile, wakes more with special attacks (warming the ice?)
	"sleeping" : 5,#immobile wakes more faster with physical attacks (slapped in the face)
	"confused" : 6,#affects movement (move opposite to stick, or add swagger/random dir mods to walks/attacks)
	
}


var stats = {} #stats for this monster (some can be moved to the database, or retrieved from there)
	#MOVED TO masterNode
	#"name" : "",
	#"species" : "Birb",
	#
	#
	##ElementTypes#TODO replace above with "monster_species_name" and get it from the dictionary
	#"element1" : "Wind",
	#"element2" : "Fire",
	#
	##STATUS EFFECTS:
	#"ailment" : 0,##0 is none, see above
	#"ailCount" : 0.0,#a float to record or healing process, we should set this when we get the effect, so we can have stronger moves with effects that last longer
	#"ailTimer" : 0.0,#a float for recording the periodic timer for status effects, (we can increase it by random intervals each frame)
	#
	#"HP" : 150,
	#"maxHP" : 150,
	#"stamina
	#"maxStamina
	#"stamRegen
	#"physAtk" : 75,
	#"physDef" : 75,
	#"spclAtk" : 75,
	#"spclDef" : 75,
	#"speed" : 75, #increases evade distance too
	#"evasion" : 75,
	##stranger stats
	#"climb" : 45.0, #allows us to walk up steeper hills
	#
	#"moves" : {
		#"A" : "Beam",
		#"B" : "Charge Punch",
		#"X" : "Slam",
		#"Y" : "Breath",#not being used as it summons terrain effect for now
	#}
#}



#@export var move_speed := 5.0
#@export var rotation_speed := 10.0

var masterNodeRef = null

#var team0 = true
var teamID = 0

var punchAttackPreload = null

var cooldownMod = {} #for adding new cooldowns from other thingd

var cooldowns = { #what are our current cooldowns
	"A" : 100.0,
	"B" : 100.0,
	"X" : 100.0,
	"Y" : 100.0,
	"dodge" : 100.0,
}

#TODO: implement cooldown tat works for everything
var generalCooldown = 0.0
var generalCooldownTime = 0.1

var attackPosOffset = Vector3(0,1,0)

#
#var busyAttacking = false
#var busyReleasing = false
var busyDodging = false
#var busyAtkName = ""
#var busyAtkBtn = ""
var atkLife = 0.0
var last_velocity = Vector3(0,0,0)


#for punch charge up we want to end at 0.25 and hold it there (or blend with idle)
var customAnims = {
	"punchCharge" : {
		"name" : "Punch",
		"start" : 0.0,
		"end" : 0.25,
	},
	"punchEnd" : {
		"name" : "Punch",
		"start" : 0.25,
		"end" : 1.0,#default -1, but can be set > anim time to set to max val
	},
	"swingCharge" : {
		"name" : "Weapon",
		"start" : 0.0,
		"end" : 0.25,
	},
	"swingEnd" : {
		"name" : "Weapon",
		"start" : 0.25,
		"end" : 1.0,#default -1, but can be set > anim time to set to max val
	},
	"DuckStart" : {
		"name" : "Duck",
		"start" : 0.0,
		"end" : 1.0, #it's only 1,6ish long
	},
	"DuckEnd" : {
		"name" : "Duck",
		"start" : 1.0,
		"end" : 2.0, #it's only 1,6ish long
	}
}

var loopedAnims = ["Idle", "Walk", "Run", "Jump_Idle"]
var stuckAnims = ["Duck","Death"]#,"Punch","Weapon"]#things that shouldnt switch back to idle

var lastSpecialAnimPlayed = ""



##TODO: process check if we are still in the same movement state
var movement_states = {
	"jumping" : -1,#on ground now, but trying to lift off
	"grounded" : 0,#on ground
	"climbing" : 1,#above ground on wall
	"falling" : 2,#above/on ground, not on/on wall, gravity # or pure physics state
	"flying" : 3,#above ground, not on wall, "no" gravity
	"digging" : 4, #under ground, (since hiehgtmap based, this is slternate state)
	"knocked" : 5#knocked by an attack with an impact velocity
	
}
var movement_state = movement_states["grounded"]

var dodge_pressed = false

var standingStill = false #so we know if we should be restoring stamina

var doubleTapTimer = 0.0
var upTapped = 0#0 is not tapped, 1 is tapped once, 2 is tapped once then put back, 3 is tapped up one more time which activates running state
#var isRunning = false



var isGuarding = false

#upTapped starts as false, if we press up it goes to true for a short time
#if it is tapped again and we are on the ground we enter the running state until the movevec goes to zero (larger range so we can turn)

var cpuAiNode = null

var lastFinishedAnim = ""
var climb_normal: Vector3 = Vector3.ZERO
var climb_speed: float = 5.0



var interactNode = null#for nodes we interact with, like an npc we talk to
func setInteractNode(interactNodeRef):
	interactNode = interactNodeRef
func removeInteractNode(interactNodeRef):
	if interactNode == interactNodeRef:
		interactNode = null


func _on_body_exited(body: Node3D) -> void:
	print("body exited interact zone 1")
	if body.has_method("removeInteractNode"):
		if body.removeInteractNode() == self:
			body.interactNode = null
##############
############################
##########################################
########################################################
#                   Controllable
########################################################
##########################################
############################
##############

func on_set_control():
	
	#add extra cooldown from attacks and stuff
	for key in cooldownMod.keys():
		cooldowns[key] += cooldownMod[key]
	cooldownMod = {}
	
	masterNodeRef.update_inventory_ui(selectedInventoryIndex, playerID)

	masterNodeRef.players[playerID]["active_char"] = self
	masterNodeRef.players[playerID]["active_char_type"] = "monster"


var randAilmentThreshold = 0.1
var selectedInventoryIndex = 0

func switch_status_ailment_state(newStateNumber, newTimer = 10.0):
	#when setting a negative status ailment we need to set a timer too
	stats["ailCount"] = newTimer
	stats["ailment"] = newStateNumber
	randAilmentThreshold = 0.1
	if newStateNumber == ailmentIDs["none"]:
		stats["ailTimer"] = 0.0
	else:
		stats["ailTimer"] = newTimer
	var condition = ailmentIDs.keys()[stats["ailment"]]
	var timerString = str(stats["ailCount"])
	masterNodeRef.update_status_ui(condition, timerString, playerID)

func handle_input(delta: float, input_data: Dictionary) -> void:
	standingStill = false
	if not is_controlled:
		return

	if generalCooldown > 0.0:
		generalCooldown -= delta
		#we have a slight cooldown between everything
		#we need to adjust UI
		masterNodeRef.update_generalCooldown_lock_visual_SAFE(true, playerID)
		if generalCooldown <= 0.0:
			pass
			#fix ui
			masterNodeRef.update_generalCooldown_lock_visual(false, playerID)
		return

#############################################
## start staus ailment process
###########
#we need to implement ailment thingos
	#var ailmentIDs = {
	#"none" : 0,
	#"poisoned" : 1,#take periodic damage over time
	#"paralysed" : 2,#flinch periodically over time
	#"burned" : 3,#random chance of flinch or damage (unreliable)
	#"frozen" : 4,#immobile, wakes more with special attacks (warming the ice?)
	#"sleeping" : 5,#immobile wakes more faster with physical attacks (slapped in the face)
	#"confused" : 6,#affects movement (move opposite to stick, or add swagger/random dir mods to walks/attacks)
	#### bleeding = take damage based on movement
#}
#has to be here so that paralysis can stop us having input
#the count has to be in process so it changes even if we arent using input...or does it
	var movementMod = 1.0
	if stats["ailment"] != 0:
		stats["ailCount"] -= delta
		var condition = ailmentIDs.keys()[stats["ailment"]]
		var timerString = str(stats["ailCount"])
		masterNodeRef.update_status_ui(condition, timerString, playerID)
		if stats["ailCount"] <= 0.0:
			switch_status_ailment_state(ailmentIDs["none"])
		stats["ailTimer"] += delta
		#var resetAilTimer = false
		if stats["ailment"] == ailmentIDs["poisoned"]:
			if stats["ailTimer"] > randAilmentThreshold:
				stats["ailTimer"] = 0.0
				randAilmentThreshold = 0.2 + 0.8*randf()
				stats["HP"] -= (1.0/25.0)*stats["maxHP"]#lose 1/25 of health evcery time
		elif stats["ailment"] == ailmentIDs["paralysed"]:
			var sign = sign(randAilmentThreshold)
			if stats["ailTimer"] > abs(randAilmentThreshold):
				stats["ailTimer"] = 0.0
				if sign == -1:
					randAilmentThreshold = (0.2 + 0.3*randf())
				else:
					randAilmentThreshold = -0.15#paralysis time (minus just tells us which state)
					#this is the part that plays once
					if movement_state == movement_states["grounded"]:
						velocity = Vector3.ZERO
						switch_animation("Idle")
					##TODO: we also need to start emitting on the particle effect here
			if sign == -1:
				#print("paralysed cant move")
				#print("randAilmentThreshold = ", randAilmentThreshold, ", stats['ailTimer'] = ", stats["ailTimer"])
				return#skip input #single frame skip not enough
			#else:
				#print("NOT PARALYSED")
				#print("randAilmentThreshold = ", randAilmentThreshold, ", stats['ailTimer'] = ", stats["ailTimer"])
		elif stats["ailment"] == ailmentIDs["burned"]:
			if stats["ailTimer"] > randAilmentThreshold:
				stats["ailTimer"] = 0.0
				randAilmentThreshold = 0.2 + 0.6*randf()
				if (randi()%2) == 0:
					return
				stats["HP"] -= (1.0/20.0)*stats["maxHP"]#lose 1/20 of health evcery time
		elif stats["ailment"] == ailmentIDs["confused"]:
			
			##method 1:
			#if sign(randAilmentThreshold) == 1:
				#movementMod = 1.0
				#if stats["ailTimer"] > randAilmentThreshold:
					#stats["ailTimer"] = 0.0
					#randAilmentThreshold = -1.0*(0.2 + 0.6*randf())
			#else:
				#movementMod = -1.0
				##stats["ailTimer"] -= 2.0*delta #since we add stats["ailTimer"] += delta
				#if stats["ailTimer"] > -1.0*randAilmentThreshold:
					#stats["ailTimer"] = 0.0
					#randAilmentThreshold = 1.0*(0.2 + 0.6*randf())
			#
			##method 2:
			#movementMod = sign(randAilmentThreshold)
			#input_data["move"] *= movementMod
			#if stats["ailTimer"] > abs(randAilmentThreshold):
				#stats["ailTimer"] = 0.0
				#randAilmentThreshold = -1.0 * movementMod * (0.2 + 0.3*randf())
			
			##METHOD 3:
			var sign = sign(randAilmentThreshold)
			if stats["ailTimer"] > abs(randAilmentThreshold):
				stats["ailTimer"] = 0.0
				if sign == -1:
					randAilmentThreshold = (0.2 + 0.3*randf())
				else:
					randAilmentThreshold = -(0.2 + 0.3*randf())#confusion time (minus just tells us which state)
					##TODO: we also need to start emitting on the particle effect here
			if sign == -1:
				input_data["move"] *= -1.0
			elif stats["ailment"] == ailmentIDs["frozen"] or stats["ailment"] == ailmentIDs["sleeping"]:
				return#unable to do anything
#############################################
## end staus ailment process
###########



	if busyDodging:
		physical_dodge_process(delta, input_data)
		return

	var move_input: Vector2 = input_data["move"]# (movementMod is just for confusion)
	
	#if move_input.length() > 0.1:
		#print("move_input = ", move_input)
	#var move_dir = (transform.basis * Vector3(move_input.x, 0, move_input.y)).normalized()
	var move_dir = Vector3(0.0,0.0,0.0)
	##Move dir changes based on our movement state
	if movement_state == movement_states["grounded"]:
		
#var doubleTapTimer = 0.0
#var upTapped = false
#var isRunning = false
#
##upTapped starts as false, if we press up it goes to true for a short time then it has to go back to neutral before being pressed again
##if it is tapped again and we are on the ground we enter the running state until the movevec goes to zero (larger range so we can turn)
		
		check_toggle_run(move_input)
		
		
		#pass#test
		#commenting out the below line makes all movement stop
		#when moving backwards we jitter a lot
		
		move_dir = (-move_input.y*global_transform.basis.z -move_input.x*global_transform.basis.x).normalized()
		#if move_dir.length() > 0.1:
			#print("grounded move_dir = ", move_dir)
	elif movement_state == movement_states["climbing"]:
		print("climbing wall movement")
		var input_vec = Vector3(-move_input.x, -move_input.y, 0)
		
		# Calculate movement relative to the wall surface
		var right_dir = climb_normal.cross(Vector3.UP).normalized()
		var up_along_surface = Vector3.UP.slide(climb_normal).normalized()

		var desired_move = (right_dir * input_vec.x + up_along_surface * input_vec.y).normalized()
		move_dir = desired_move
	elif movement_state == movement_states["falling"]:
		var fallSpeedMod = 0.5
		move_dir = fallSpeedMod*(-move_input.y*global_transform.basis.z -move_input.x*global_transform.basis.x).normalized()
		

##TEST COMMENT OUT setting velocity here
		## Apply to velocity
		#velocity = move_dir * move_speed #why are we doing this twice



	#above we are choosing our direction
	#below we are actually applying the velocity
	if movement_state == movement_states["knocked"]:
		#we lose control
		var resistance = 1.0  # Tune this value to adjust how quickly velocity slows
		velocity.x = lerp(velocity.x, 0.0, resistance * delta)
		velocity.z = lerp(velocity.z, 0.0, resistance * delta)
	elif movement_state == movement_states["falling"]:
		velocity += move_dir*delta
	elif move_dir.length() > 0.0001:
		var move_speed_mod = 1.0
		#aslo make this dependent on stamina
		var minMod = 0.75 #at 0 stamina our cooldown recovers slower at 0.2*5.0 = 1.0*delta
		var staminaRatio = float(stats["stamina"])/float(stats["maxStamina"])
		move_speed_mod = (minMod + (1.0 - minMod)*staminaRatio)*move_speed_mod
		
		
		if isRunning() == true:
			var runMax = 0.75#extra speed
			var runMin = 0.25#min extra speed minMod*runMin = 0.9375 run speed at zero stamina
			move_speed_mod = ((1.0+runMin) + (runMax - runMin)*staminaRatio) * move_speed_mod
			#make it use stamina (done in process)
		velocity = move_dir * move_speed * move_speed_mod
		
		#method 1 creates jitters
		#rotation.y = lerp_angle(rotation.y, atan2(-move_dir.x, -move_dir.z), delta * rotation_speed)
		
		#method 2 directly change transform
		if movement_state == movement_states["climbing"]:
			pass
		else:
			if move_dir.dot(global_transform.basis.z) >= 0.5*move_dir.length():
				#we are moving mostly forward
				var target_rot = Basis.looking_at(-move_dir, Vector3.UP)
				transform.basis = transform.basis.slerp(target_rot, delta * rotation_speed)
				transform.basis = transform.basis.orthonormalized()
			
			if isRunning():
				switch_animation("Run")
			else:
				switch_animation("Walk")

		
	else:
		#var oldYVel = velocity.y
		velocity = Vector3(0.0, velocity.y, 0.0)
		switch_animation("Idle")
		if movement_state == movement_states["grounded"]:
			standingStill = true
			

	#move_and_slide()
	if input_data["jump_pressed"]:
		if movement_state == movement_states["grounded"]:
			start_jump(input_data)
	
	if input_data["interact_pressed"]:
		print("interact pressed")
		if interactNode != null:
			interactNode.interact(self)
	elif input_data["interact_held"]:
		##TODO
		if input_data["attack_A_pressed"]:
			#[selectedInventoryIndex]
			#use_item()
			var invKeys = masterNodeRef.players[playerID]["inventory"].keys()
			if invKeys.size() > 0:
				
				var itemName = invKeys[selectedInventoryIndex%invKeys.size()]
				central.use_item(itemName, self, "monster")
				masterNodeRef.update_inventory_ui(selectedInventoryIndex, playerID)
			pass
		elif input_data["attack_Y_pressed"]:
			##TODO
			#throw_item()
			#masterNodeRef.update_inventory_ui(invIndex, playerID)
			pass
		elif input_data["attack_X_pressed"]:
			selectedInventoryIndex -= 1
			masterNodeRef.update_inventory_ui(selectedInventoryIndex, playerID)
			pass
		elif input_data["attack_B_pressed"]:
			selectedInventoryIndex += 1
			masterNodeRef.update_inventory_ui(selectedInventoryIndex, playerID)
			pass
		

	elif input_data["dodge_pressed"]:
		
		#TODO:
		#rewrite this system so that dodge on it's own is guard
		#dodge with a direction is how to activate a dodge
		
		
		print("dodge pressed")
		#start_dodge()
		#when we press the dodge button we want to enter a state where we are able to interact with things differently
		#like being able to climb walls, we must keep it held as releasing makes us cancel
		#we must know when we are doing one of these actions so we can avoid doing a dodge when not appropriate
		dodge_pressed = true
		isGuarding = true
		switch_animation("DuckStart", true)
		#if we walk into something and dodge_pressed is true then we can climb it
		pass
	elif input_data["dodge_released"]:
		print("dodge released")
		isGuarding = false
		dodge_pressed = false
		finish_stuck_animation()
	elif input_data["attack_A_pressed"]:
		#check what attackj I have assigned to A and use it
		#print("Attack A button pressed!")
		var buttonChar = "A"
		var myMoves = stats["moves"]
		var atkName = myMoves[buttonChar]
		do_attack(buttonChar, atkName)
	elif input_data["attack_B_pressed"]:
		#check what attackj I have assigned to A and use it
		#print("Attack A button pressed!")
		var buttonChar = "B"
		var myMoves = stats["moves"]
		var atkName = myMoves[buttonChar]
		do_attack(buttonChar, atkName)
		#do_attack(buttonChar, "Charge Punch")
	elif input_data["attack_X_pressed"]:
		#check what attackj I have assigned to A and use it
		#print("Attack A button pressed!")
		var buttonChar = "X"
		var myMoves = stats["moves"]
		var atkName = myMoves[buttonChar]
		do_attack(buttonChar, atkName)
		#do_attack(buttonChar, "Slam")
	elif input_data["attack_Y_pressed"]:
		#check what attackj I have assigned to A and use it
		#print("Attack A button pressed!")
		var buttonChar = "Y"
		#do_attack(buttonChar, "Beam")
		var myMoves = stats["moves"]
		var atkName = myMoves[buttonChar]
		do_attack(buttonChar, atkName)
		
		
		###TODO MOVE TO AN ATTACK, THIS SUMMONS A TERRAIN EFFECT THAT MOVES WITH DESTRUCTABLE TERRAIN
		##DO NOT DELETE
		#var terrainEffectArea = load("res://world/terrainEffectArea.tscn").instantiate()
		#masterNodeRef.add_child(terrainEffectArea)##TODO fix add to proper parent
		#terrainEffectArea.global_transform.origin = global_transform.origin##DANGEROUS CAUSES ALIGNMENT ISSUES
		#terrainEffectArea.global_transform.origin.y = 0.0
		#terrainEffectArea.after_ready()
	
	
	#should we activate the dodge?:
	check_activate_dodge(input_data)
	
	
	var check_to_climb = false
	
	###for climbing:
	if dodge_pressed and movement_state == movement_states["grounded"]:
		#this is the old method of checking for climb
		check_to_climb = true
	
	#we want to do a new method, if we land and we are pushing up on the stick
	#if we dodge forward and hit a wall
	
	if check_to_climb:
		#we should move this to dodge process 
		check_for_start_climb()

	var look_input: Vector2 = input_data["look"]
	if look_input.length() > 0.0001 or move_input.length() > 0.0001:
		adjust_camera(delta, look_input)
	#var look_dir = Vector3(0.0,0.0,0.0)

##############
############################
##########################################
########################################################
#                   Initialisation
########################################################
##########################################
############################
##############


func _stats_were_set() -> void:
	#called in masterNode
	pass
	#once we set the stats
	#we can load the model
	var pathAlpha = "res://assets/monsters/quaternius/glTF/"##TODO make more general later if we have more folders
	var pathOmega = ".gltf"
	var pathMid = stats["species"]
	var monsterModelPath = str(pathAlpha, pathMid, pathOmega)
	var monsterModel = load(monsterModelPath).instantiate()
	add_child(monsterModel)
	monsterModel.scale = 0.5*Vector3(1.0,1.0,1.0) #set to more realistic scale for VR
	meshMasterNode = monsterModel
	##TODO set collision shape size based on monster
	
	##TODO: connect animation finished signal
	monsterModel.get_node("AnimationPlayer").connect("animation_finished", Callable(self, "on_animation_finished"))

func _ready() -> void:
	print("setting up monster ", self)
	punchAttackPreload = load("res://attacks/base/punch.tscn")
	

	
	_set_up_default_collision()

	
	old_move_speed = move_speed
	
	
	



##############
############################
##########################################
########################################################
#                   Helper Functions
########################################################
##########################################
############################
##############

func isRunning():
	if upTapped >= 3:
		return true
	return false


func check_toggle_run(move_input):
	##############################
	##  check if should toggle run
	#################
	var checkUpRunThreshold = 0.75
	var upDirPressed = -1.0*move_input.y
	
	var upPressedThisFrame = false
	var sidePressedThisFrame = false
	
	if abs(move_input.x) > 0.3:
		sidePressedThisFrame = true
	
	if upDirPressed > checkUpRunThreshold:
		upPressedThisFrame = true

	
	if upTapped == 0:
		if upPressedThisFrame == true and sidePressedThisFrame == false:
			upTapped = 1#first tap up
			doubleTapTimer = 0.4
	elif upTapped == 1:
		if upPressedThisFrame == false and sidePressedThisFrame == false:
		#if upPressedThisFrame == false:
			upTapped = 2#stick returns
			doubleTapTimer += 0.1 #give slightly more time
	elif upTapped == 2:
		if upPressedThisFrame == true and sidePressedThisFrame == false:
			upTapped = 3#second tap up
	else: #we should be running
		if upDirPressed <= 0.0:
			upTapped = 0 #stop running
			doubleTapTimer = 0.0
	#############################################################

func raycast(origin: Vector3, direction: Vector3, length: float = 1.5, mask: int = 1 << 8) -> Dictionary:# mask: int = 1 << 8
	
#Summary:
#1 = starting bit
#<< = shift that bit left
#1 << layer_number = mask for that collision layer
#
#If you want multiple layers, you OR them:
#(1 << layer0) | (1 << layer9)
	
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(origin, origin + direction.normalized() * length)
	query.collision_mask = mask
	return space_state.intersect_ray(query)



##############
############################
##########################################
########################################################
#                   Attacking
########################################################
##########################################
############################
##############

func end_attack(attackHitboxNode):
	#var atkNode = get_node_or_null("Attack")#must set name or do slam as an extension of the hitbox
	attackHitboxNode.queue_free()

func check_if_died():
	if stats["HP"] <= 0:
		enter_KO_state()

func enter_KO_state():
	print("should have died...")
	switch_animation("Death")
	pass





func hit_by_attack(attackerNodeRef):
	switch_animation("HitReact")
	if cpuAiNode == null:
		#it's a human
		return
	cpuAiNode.targetEnemy = attackerNodeRef
	cpuAiNode.switch_states("alert")

func do_attack(buttonChar, attackName):
	#if we move before attackintg we can keep moving
	velocity.x = 0.0
	velocity.z = 0.0
	#does this fix it? yep
	var atkData = masterNodeRef.get_node("AttacksData").moveData[attackName]
	
	var attackCost = atkData["cost"]#30.0 #TODO move to move database
	if cooldowns[buttonChar] < attackCost:
		print("wait for cooldown")
		return
	cooldowns[buttonChar] -= attackCost
	
	update_stamina(-0.1*attackCost)
	#lose a small amount of stamina for attacking
	
	#we can do the attack
	
	
	#var punchAttack = punchAttackPreload.instantiate()
	var punchAttack = load(atkData["scene"]).instantiate()
	#if we are moveing everything from being driven by the parent, to being driven by a child, then we need to
	#set these variables on the right node, which is punchAttack.driverNode

	
	#this part is the only difference for melee and ranged moves
	var isMeleeAttack = false
	if atkData.has("melee"):
		if atkData["melee"] == true:
			isMeleeAttack = true
	if isMeleeAttack:
		self.add_child(punchAttack)
	else:
		masterNodeRef.get_node("Attacks").add_child(punchAttack)
	punchAttack.global_transform = global_transform #always work with global_transforms of uppermost nodes
	punchAttack.global_transform.origin = punchAttack.global_transform.origin + attackPosOffset
	
	punchAttack._after_add_child_ready()
	var attackDriver = punchAttack.driverNode
	attackDriver.held_button = buttonChar
	#attackDriver.team0 = team0
	attackDriver.attackerNodeRef = self
	
	attackDriver.atkData = atkData.duplicate() #copy so we can modify it with charge attacks etc and not effect the original
	attackDriver.teamID = teamID

	attackDriver.startPos = punchAttack.global_transform.origin#saved custom variables are in the attack driver

	masterNodeRef.set_control(attackDriver, playerID)#we are setting control to the driver. I hpoe it works
	attackDriver._after_parent_ready()
	
	
	generalCooldown = generalCooldownTime
	
	
	
	
	#adding animation to attacks
	if isMeleeAttack:
		pass#skip animation
	else:
		if atkData["special"]:
			switch_animation("swingCharge", true)
		else:
			switch_animation("punchCharge", true)


##############
############################
##########################################
########################################################
#                   Collision
########################################################
##########################################
############################
##############

func _set_all_collision_to_zero():
	for i in range(1,33):
		set_collision_layer_value(i, false)
		set_collision_mask_value(i, false)

func _set_up_default_collision():
	_set_all_collision_to_zero()
	#floor collison
	var floorLayer = 9
	#layer 1 monsters, layer 2 attacks
	set_collision_layer_value(1, true) #you are a living being
	set_collision_mask_value(1, false) #you get hit by players directly? is this right
	set_collision_mask_value(2, true) #you get hit by other attacks
	set_collision_mask_value(floorLayer, true) #you get blocked by the floor


func _set_up_dodge_collision():
	_set_all_collision_to_zero()
	set_collision_mask_value(9, true) #you still get hit by the floor


##############
############################
##########################################
########################################################
#                   Animation
########################################################
##########################################
############################
##############




func on_animation_finished(anim_name):
	lastFinishedAnim = anim_name
	print("animation finished, ", anim_name)
	pass



func switch_animation(animName, specialAnim = false):
	#print("switch anim playing")
	var animPlayer = meshMasterNode.get_node("AnimationPlayer")
	if specialAnim == false:
		if animPlayer.current_animation != animName:
			#method 1: just play it immediately
			#animPlayer.play(animName)
			
			#method 2: if we are switching to "Idle" we let other animations finish first
			var isCurrentAnimLooped = false
			if animPlayer.current_animation in loopedAnims:
				isCurrentAnimLooped = true
			
			
			if animName == "Idle":
				#print("switching to idle anim")
				if isCurrentAnimLooped == false:
					if animPlayer.assigned_animation in stuckAnims:
						if animPlayer.assigned_animation == "Duck": #we are guarding
							if isGuarding == false:
								if lastSpecialAnimPlayed == "DuckStart":
									finish_stuck_animation()
						#else:
							#return
						#pass#we do not want to return to idle from these until conditions are met, idle will always keep trying
					else:
						animPlayer.queue(animName)
				#elif animPlayer.current_animation in stuckAnims:
					#pass
					
				else:#it is a looped aninmation
					animPlayer.play(animName)
				
				
				return
			
			
			#else we are not switching to the idle animation
			if lastSpecialAnimPlayed == "DuckStart":
				finish_stuck_animation()
			else:
				animPlayer.play(animName)
			
			#method 3:
			#if it is already playing a non looped animation and we want to replace it with a looped one, we should let it finish firstt
			
		
		
		
		return
	
	#else:
	#we want to play special types of animations with their own rules, like punch up to half way while we are doing the charge part
	
	
	
	
	if animName in customAnims.keys():
		var animData = customAnims[animName]
		animPlayer.play_section(animData["name"], animData["start"], animData["end"])
		lastSpecialAnimPlayed = animName
	else:
		print("ERROR: animation ",animName," not found in custom anims")


func finish_stuck_animation():
	print("finish stuck animation")
	#called from the attack as thats the thing that knows when it is released
	var nextAnims = {
		"Punch":["punchCharge","punchEnd"],
		"Weapon":["swingCharge", "swingEnd"],
		"Duck":["DuckStart","DuckEnd"],
	}
	#lastSpecialAnimPlayed
	var animPlayer = meshMasterNode.get_node("AnimationPlayer")
	var anim_name = animPlayer.assigned_animation
	print("anim_name = ", anim_name)
	
	if nextAnims.has(anim_name):
		if lastSpecialAnimPlayed == nextAnims[anim_name][0]:
			switch_animation(nextAnims[anim_name][1], true)



##############
############################
##########################################
########################################################
#                   Dodging
########################################################
##########################################
############################
##############


func check_activate_dodge(input_data):
	dodge_pressed = false
	if isGuarding:
		var move_input: Vector2 = input_data["move"]
		if move_input.length() > 0.3:
			if movement_state == movement_states["grounded"]:
				var dodgeStaminaCost = 10
				if stats["stamina"] > dodgeStaminaCost:
					start_dodge(input_data)
					isGuarding = false
					#stats["stamina"] -= dodgeStaminaCost
					update_stamina(-1.0*dodgeStaminaCost)
			elif movement_state == movement_states["climbing"]:
				
				jump_off_wall(input_data)
				isGuarding = false
			else:
				print("ERROR, not on ground, couldnt dodge, movement_state = ", movement_state)

func start_jump(input_data):
	##TODO
	#we should use input data to give it some more direction
	var jumpStrength = 1.0
	var move_dir = jumpStrength*Vector3(0.0,1.0,0.0)
	movement_state = movement_states["jumping"]
	velocity += move_speed*move_dir

func start_dodge(input_data):
	#We DO NOT want this to jump anymore, it should always go forward if there is no input_data
	
	
	
	
	
	#changed so this only runs when acturally releasing the dodge button and being in a state where we can dodge
	#busyAttacking = true
	
	
	print("start dodge release")
	#make shift using Slam as dodge
	atkLife = 0.0
	#busyAtkName = "Dodge"
	var atkData = masterNodeRef.get_node("AttacksData").moveData["Dodge"]
	move_speed = atkData["releaseSpeed"]
	#print("releaing attack :")
	#print("last vel = ", last_velocity)
	#print("local tform forward 2  = ", transform.basis.z)
	#print("global tform forward = ", global_transform.basis.z)
	
	#now to make directional
	#left, right move us left and right
	#back lets us dodge backwards forward, forwards
	#no move input lets us jump
	var move_input: Vector2 = input_data["move"]
	#var move_dir = (transform.basis * Vector3(move_input.x, 0, move_input.y)).normalized()
	var move_dir = Vector3(0.0,0.0,0.0)
	if move_input.length() < 0.01:
		#var jumpStrength = 1.0
		#move_dir = jumpStrength*Vector3(0.0,1.0,0.0)
		#movement_state = movement_states["jumping"]
		
		move_dir = -1.0*global_transform.basis.z
	else:
		move_dir = (-move_input.y*global_transform.basis.z -move_input.x*global_transform.basis.x).normalized()

	velocity = move_speed*move_dir#global_transform.basis.z
	#busyReleasing = true
	busyDodging = true
	#busyAttacking = true
	#busyReleasing = true
	#busyAtkName = attackName
	#busyAtkBtn = buttonChar
	
	#we also have to change the attack collision layers temporarily
	#_set_up_attack_collision()
	_set_up_dodge_collision()
	

func end_dodge_release():
	print("end release")
	var attackName = "Dodge"#busyAtkName
	atkLife = 0.0
	#var atkData = masterNodeRef.get_node("AttacksData").moveData[attackName]
	move_speed = old_move_speed
	#busyAttacking = false
	#busyReleasing = false
	busyDodging = false
	isGuarding = false
	
	#busyAtkName = ""
	#busyAtkBtn = ""
	_set_up_default_collision()
	pass
func physical_dodge_process(delta, input_data):
	print("release proc")
	#runs 16 times in a single dodge
	atkLife += delta
	var attackName = "Dodge"#busyAtkName
	var atkData = masterNodeRef.get_node("AttacksData").moveData[attackName]
	#how long can we hold this part of the attack before it ends and we resume control
	#end_physical_attack_release()
	#move_and_slide()
	var did_climb_start = false
	var move_input = input_data["move"]
	var upDirPressed = -1.0*move_input.y
	if upDirPressed > 0.5:
		print("up dir pressed")
		#when dodging forward we can enter a climb state
		did_climb_start = check_for_start_climb()
	
	if atkLife > atkData["lifetime"] or did_climb_start:
		end_dodge_release()
	#var attackName = busyAtkName
	pass


func jump_off_wall(input_data):
	#if no movement input we drop, if forward we jump off on the normal, if angled we jump off to the sides a bit
	pass
	#this starts a jump when we land we need to set moevement state back 
	velocity = climb_normal# plus the input_data move vector to move up down left right
	movement_state = movement_states["jumping"]


##############
############################
##########################################
########################################################
#                   Camera
########################################################
##########################################
############################
##############


#var cameraOffset = Vector2(0.0,0.0)

func adjust_camera(delta, look_input_vec):
	#move to master node, putplayerID as variable as well as targetNode
	#so attacks can easily call it too
	#print("adjusting camera, look_input_vec = ", look_input_vec)
	var cameraRef = masterNodeRef.get_player_camera(playerID)
	if cameraRef == null:
		return #we are not assigned a camera just for us as a player
	#var heightAbove = 5.0#metres
	var cam_speed = 3.0
	#we want to rotate camVertHelper in y
	#we want to have the camera at the position of camHorizHelper but looking at us + an extra angle from joystick
	var cameraPosHorizHelper = get_node("camVertHelper/camHorizHelper")
	var cameraPosVertHelper = get_node("camVertHelper")
	
	cameraPosVertHelper.rotation.y += cam_speed*look_input_vec.x*delta
	
	#var target_rot = cameraPosHorizHelper.global_transform.basis
	#target_rot = target_rot.looking_at(global_transform.origin, Vector3.UP)
	cameraRef.look_at_from_position(cameraPosHorizHelper.global_transform.origin, global_transform.origin, Vector3(0, 1, 0))
	#maybe I can make it look at the current node instead
	
	cameraPosVertHelper.global_transform.origin.y += cam_speed*delta*look_input_vec.y

#
			#var target_rot = Basis()
			#target_rot = target_rot.looking_at(-move_dir, Vector3.UP)
			#transform.basis = transform.basis.slerp(target_rot, delta * rotation_speed)


##############
############################
##########################################
########################################################
#                   Climbing
########################################################
##########################################
############################
##############

func start_climb(wall_normal: Vector3):
	print("Entering climb")
	movement_state = movement_states["climbing"]
	climb_normal = wall_normal
	velocity = Vector3.ZERO

func end_climb(fall: bool):
	print("End climb")
	if fall:
		movement_state = movement_states["falling"]
	else:
		movement_state = movement_states["grounded"]
	climb_normal = Vector3.ZERO

func check_for_start_climb():
	print("looking for wall")
	var wall_check_origin = global_transform.origin + Vector3(0, 0.5, 0) # just above floor height
	var wall_check_dir = global_transform.basis.z
	var wall_check_distance = 0.8#1.2
	var result = raycast(wall_check_origin, wall_check_dir, wall_check_distance)

	if result:
		print("raycast hit wall")
		var normal: Vector3 = result.normal
		var angle = rad_to_deg(acos(normal.dot(Vector3.UP)))
		if angle > 0.75*stats["climb"]: # too steep = climbable not walkable
			print("starting climb")
			#maybe this is still too high though
			#it should be higher than the minimum
			start_climb(normal)
			return true
	
	return false


##############
############################
##########################################
########################################################
#                   Cooldown
########################################################
##########################################
############################
##############

func cooldown_process(delta):
	var cooldown_base_recover_speed = 5.0#at full stamina we recover thi = 5.0 * delta
	var minMod = 0.2 #at 0 stamina our cooldown recovers slower at 0.2*5.0 = 1.0*delta
	var staminaRatio = float(stats["stamina"])/float(stats["maxStamina"])
	var cooldown_recover_speed = (minMod + (1.0 - minMod)*staminaRatio)*cooldown_base_recover_speed
	#more like a cool up
	for key in cooldowns.keys():
		if cooldowns[key] < 100.0:
			cooldowns[key] += cooldown_recover_speed*delta
			masterNodeRef.update_cooldown_labels(key, cooldowns[key], playerID)
		else:
			cooldowns[key] = 100.0
			



##############
############################
##########################################
########################################################
#                   Stamina
########################################################
##########################################
############################
##############

func update_stamina(staminaGain):
	stats["stamina"] += staminaGain
	if stats["stamina"] > stats["maxStamina"]:
		stats["stamina"] = stats["maxStamina"]
	if stats["stamina"] < 0:
		stats["stamina"] = 0
		isGuarding = false
		upTapped = 0
		doubleTapTimer = 0.0
	masterNodeRef.update_chars_hp_bars(self)#also does stamina

##############
############################
##########################################
########################################################
#                   Process
########################################################
##########################################
############################
##############

func _process(delta: float) -> void:
	cooldown_process(delta)
	
	#Stamina reduction process (done all at once to only render ui once)
	var staminaGain = 0.0
	
	if isGuarding == true:
		var guardStaminaMult = 5.0
		staminaGain -= guardStaminaMult*delta
	elif standingStill:
		#we gain even more stamina back when standing still
		staminaGain += 2.0*(float(stats["stamRegen"])/50.0)*delta
	
	#doubleTap timers
	if isRunning() == false:
		staminaGain += (float(stats["stamRegen"])/50.0)*delta
		doubleTapTimer -= delta
		if doubleTapTimer < 0.0:
			doubleTapTimer = 0.0
			upTapped = 0
	else:
		#we are running
		var runStaminaMult = 2.0
		staminaGain -= runStaminaMult*delta
	
	

	
	
	
	if abs(staminaGain) > 0.1*delta:
		#update stamina
		update_stamina(staminaGain)
	var GRAVITY = 9.8
	
	
	#Visually update the monster to look like they are climbing
	#if movement_state == movement_states["climbing"]:
		#var up_dir = climb_normal
		#var forward_dir = -up_dir.cross(global_transform.basis.x).normalized()
		#var target_basis = Basis(forward_dir, up_dir.cross(forward_dir), up_dir)
		#global_transform.basis = global_transform.basis.slerp(target_basis, delta * 6.0)
	
		#
	#If you notice jitter near curved walls, you can slightly “push” the body toward the surface each frame:
	#
	#if movement_state == movement_states["climbing"]:
		#var stick_force = climb_normal * -2.0 # small inward force
		#global_translate(stick_force * delta)
	#
	#
	#This gently keeps the character pressed against the terrain, ensuring your raycast continues to hit even on slightly convex parts.
	
	if movement_state == movement_states["climbing"]:
		print("climbing process")
		##Raycast to check the wall normal
		var wall_check_origin = global_transform.origin + Vector3(0, 1.0, 0)
		var wall_check_dir = -climb_normal
		var result = raycast(wall_check_origin, wall_check_dir, 1.0)#was 1.5

		if not result:
			print("raycast 1 didnt hit anything")
			end_climb(true)
		else:
			# Optionally adjust climb_normal slightly if wall curves
			#climb_normal = result.normal
			climb_normal = climb_normal.slerp(result.normal, delta * 8.0).normalized()
			print("raycast 1 hit wal, new normal = ", climb_normal)

		
		###Raycast to check if still on ground
		#causes climb to end immediately
		#var result_down = raycast(global_transform.origin + Vector3(0, 0.06,0), Vector3.DOWN, 0.1)
		#if result_down:
			#print("raycast 2 hit something")
			#var floor_normal = result_down.normal
			#if rad_to_deg(acos(floor_normal.dot(Vector3.UP))) < stats["climb"]:
				#end_climb(false)
		#else:
			#print("raycast 2 hit nothing")

		#what should we do....
	#elif movement_state == movement_states["flying"]:
		#pass
		##what should we do....
	#elif movement_state == movement_states["digging"]:
		#pass
		##what should we do....
	elif movement_state == movement_states["jumping"]:
		#just to skip the on ground setting of velocity to 0.
		movement_state = movement_states["falling"]
	elif movement_state == movement_states["knocked"]:
		if not is_on_floor():
			velocity.y -= GRAVITY * delta
		var horizVel = Vector2(velocity.x,velocity.z)
		print("knocked state, horizVel.length() = ", horizVel.length())
		if horizVel.length() < 0.23:#0.1 seems too low
			movement_state = movement_states["falling"]
	else: #grounded or falling
		if not is_on_floor():
			velocity.y -= GRAVITY * delta
			movement_state = movement_states["falling"]
			print("movement state Falling")
			
		else:
			velocity.y = 0  # reset vertical velocity when on floor
			movement_state = movement_states["grounded"]
			if is_controlled == false:
				###TODO QUICK BUGFIX,
				##if we walk into an interaction zone and interact with it while walking,
				## we lose control of the monster but it keeps walking
				##this didnt happen with spawned attacks, probably because the attack excludes movement.
				velocity = Vector3.ZERO

	
	move_and_slide()
	





##############
############################
##########################################
########################################################
#                   Terrain
########################################################
##########################################
############################
##############

func enter_terrain_effect(area):
	print("Entered terrain effect:", area.name)
	# Apply buffs or visual effects

func exit_terrain_effect(area):
	print("Left terrain effect:", area.name)
	# Remove buffs
