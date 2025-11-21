class_name HitboxAttack
#AttackOldishHitbox
#extends Controllable

#THIS IS THE MIXED VERSION

extends Area3D

#make this into the general class of attack for all types.
#all attacks need an area node hitbox anyways


##WHAT HAVE WE DONE SO FAR?
#added an attackNode variable, this is our parent, the actual object that moves everything.
#we are just a hitbox and driver
#changed all global_transform to attackNode.global_transform
#changed all transform to attackNode.global_transform
#changed all velocity to attackNode.velocity
#changed queue_free to attackNode.queue_free()

##STILL NEED TO DO?
#change the other scenes to work with the Hitbox
#change spawning code so it targets variables in the right place, in attackNode or here in $Hitbox (I think done...)
#consolidate code from physical attack and character attacks
#replace punch so it works with this as the hitbox code
#replace slam so it works with this as the hitbox code

#################
##################################
###################################################
####################################################################
#                           Variables
####################################################################
###################################################
##################################
#################

var teamID = 0
var attackNode = null #this is now a script on a hitbox

var is_controlled = false
var playerID: int = -1#-1 means no player has been assigned
#var velocity = Vector3(0,0,0)





var atkData = { #OVERRIDE WITH ACTUAL ATTACK DATA
	"scene" : "res://attacks/base/punch.tscn", #summon a base scene with a visual effect
	"visual" : "res://effects/ice.tscn", #visual effect
	"radius" : 0.4, #width of attack
	"power" : 75.0, #75 as a multiple of basePower so we can tweak later
	"element" : "fire", #element type of attack
	"atkType" : "punch", #some monsters could have abilities to power up certain types of moves
	"special" : false, #physical or special attack
	"range" : 5.0, #how far before attack disappears, set as negative for infinite
	"lifetime" : 3.5, #how long does it last
	"controllableSpeed" : 5.0,
	"releaseSpeed" : 10.0,
	"rotationSpeed" : 10.0,
	"cost": 5.0,#for testing #was 60.0,#how much "cooldown" does it cost to use this move, 60 means we can use once then wait a little bit and use again in succession but then we have to recharge heapse
	"extraCooldownFunc" : "", #no function to generate extra cost to the atack while we are controlling the attack
}


var needsNeedsUpdate = false
var needsUpdate = false #for the parent class to check if things need changing

#var duration := 1.5
var life := 0.0

var held_button = ""
var last_velocity = Vector3(0,0,0)

var startPos = Vector3(0,0,0)

#var team0 = true
var attackerNodeRef = null

#var controllableSpeed = 5.0
#var releaseSpeed = 10.0


var extraCooldown = 0.0

var override_velocity = Vector3(0.0, 0.0, 0.0)
var controllableMoveState = central.controllableMoveStates["forward"]
var rotationMoveState = central.rotationMoveStates["allow"]
var releaseMoveState = central.releaseMoveStates["default"]

var chargePower = 0.0
#var baseAttackPower = 0.0
var originalAtkData = {}

var finalFixesDone = false

#################
##################################
###################################################
####################################################################
#                           Movement
####################################################################
###################################################
##################################
#################


func move_and_slide(delta):
	#attackNode.global_transform.origin += delta*velocity
	attackNode.hitboxDelta = delta
	attackNode.move_and_slide()

#when shot with zero velocity it should move forward anyways.
#when we use up and down we need to move vertically.


#as an attack we need to know what to do when we hit the floor or something else (that is not whitelisted like our teammates)
#so the attack itself needs to have a signal for when it explodes
#if we hit a player get their defence stat and do damage calculations (only once)
#if we hit a floor check if we are a move that should destroy terrain and do damage or leave elemental traits or hazards
#if we hit another attack then we should probably both enter our self destruct sequence (only once each)



#################
##################################
###################################################
####################################################################
#                           Initialisation
####################################################################
###################################################
##################################
#################

func _on_ready_finished(thisAtkData):
	print("ERRRORRR : on lower ready finished function")
	pass#overwrite in upper class

func _on_attack_released():
	pass

func fix_collision_layers(physBodyNode):
	#NEWER METHOD
	#layer 1 monsters, layer 2 attacks
	physBodyNode.set_collision_layer_value(2, true) #you are an attack
	physBodyNode.set_collision_mask_value(1, true) #you get hit by players
	physBodyNode.set_collision_mask_value(2, true) #you get destroyed by other attacks
	if atkData.has("ignoreFloor"):
		if atkData["ignoreFloor"]:
			physBodyNode.set_collision_mask_value(9, false)
			#return #don't interact with the floor
	else:
		physBodyNode.set_collision_mask_value(9, true) #you get hit by the floor
	
	#add an exception with the player that spawned the attack
	
	



#func _ready() -> void:
#_after_parent_ready()
func _after_parent_ready() -> void:
	
	#connect attack signals
	connect("area_entered", Callable(self, "_on_area_entered"))
	connect("body_entered", Callable(self, "_on_body_entered"))
	
	
	print("after parent ready attack.gd")
	print(atkData.atkType)
	print("atkData = ", atkData)
	if atkData.has("controlState"):
		controllableMoveState = atkData["controlState"]
		print(" controllableMoveState set to ", controllableMoveState)
	
	if atkData.has("rotationState"):
		rotationMoveState = atkData["rotationState"]
	
	if atkData.has("releaseState"):
		releaseMoveState = atkData["releaseState"]
		#print(" controllableMoveState set to ", controllableMoveState)
	
	
	#baseAttackPower = atkData["power"]
	originalAtkData = atkData.duplicate(true)
	print("attack.gd ready function")
	#THIS DOES NOT RUN since punch takes priority
	#make a new function that can run
	#or delete it from punch and use on_ready_finished
	
	
	
	#NEWER METHOD
	#layer 1 monsters, layer 2 attacks
	fix_collision_layers(self)
	
	
	#rotation_speed = 180.0
	#move_speed = atkData["controllableSpeed"]
	_on_ready_finished(atkData)
	if attackNode != attackerNodeRef:
		attackNode.add_collision_exception_with(attackerNodeRef)#for this body
	#else:
		#



#################
##################################
###################################################
####################################################################
#                           Controllable
####################################################################
###################################################
##################################
#################


func give_control_back_to_parent():
	#var masterRefNode = get_parent().get_parent()
	var masterRefNode = attackerNodeRef.masterNodeRef
	#print("playerID = ", playerID)
	#print("prev cont = ", masterRefNode.get_player_var(playerID,"previous_controller"))
	#var previous_controller = masterRefNode.previous_controller
	var previous_controller = masterRefNode.get_player_var(playerID,"previous_controller")
	if previous_controller:
		attackerNodeRef.cooldownMod = {held_button : extraCooldown}
		#above has to be done before control resumes
		#we should stick to a single reference
		masterRefNode.set_control(previous_controller, playerID)
		

###################################################################################



func handle_input(delta: float, input_data: Dictionary) -> void:
	#print(self, "is_controlled? = ", is_controlled)
	if not is_controlled:
		#print("punch not controlled")
		return

	var keyReleased = false
	var keyString = str("attack_",held_button,"_released")
	#print("keyString = ", keyString)
	if input_data.has(keyString):
		if input_data[keyString] == true:
			keyReleased = true
			_on_attack_released()
			#print("attack button released")
			#if key is released we wnt o stop controlling it
			print("attack was released")
			attackerNodeRef.finish_stuck_animation()
			give_control_back_to_parent()

	
	
	#this is where we are charging
	##TODO
	if atkData.has("chargeState"):
	#if true:
		if atkData["chargeState"] == "power":
			chargePower += delta
			print("chargePower = ", chargePower, ", life = ", life)
			#if atkData.has("chargeState"): then atkData has chargeVar
			var powerMultiplierMax = atkData["chargeVar"]
			var powerMultiplierRatio = chargePower/atkData["lifetime"]#same as life/atkData["lifetime"]
			var powerMult = 1.0 + (powerMultiplierMax - 1.0)*powerMultiplierRatio #should always be between 1.0 and max
			var baseAttackPower = originalAtkData["power"]
			atkData["power"] = powerMult*baseAttackPower
			var baseAttackCost = originalAtkData["cost"]
			atkData["cost"] = powerMult*baseAttackCost#min(100.0, powerMult*baseAttackCost)
		
		elif atkData["chargeState"] == "size":
			chargePower += delta 
			var sizeMultiplierMax = atkData["chargeVar"]
			var sizeMultiplierRatio = chargePower/atkData["lifetime"]#same as life/atkData["lifetime"]
			var sizeMult = 1.0 + (sizeMultiplierMax - 1.0)*sizeMultiplierRatio #should always be between 1.0 and max
			var baseAttackPower = originalAtkData["radius"]
			atkData["radius"] = sizeMult*baseAttackPower
			needsUpdate = true
			print("updating size = ")
			print(atkData["radius"])
	
		##METHOD 2, alwyas move foward, let control stick move up and down
	var move_input: Vector2 = input_data["move"]
	var move_dir = Vector2(0.0, 0.0)
	
	var bypass_move_dir_check = false
	
	if controllableMoveState == central.controllableMoveStates["direct"]:
		move_dir = (-move_input.y*attackNode.global_transform.basis.z -move_input.x*attackNode.global_transform.basis.x).normalized()
	elif controllableMoveState == central.controllableMoveStates["forward"]:
		move_dir = (2.0*attackNode.global_transform.basis.z-move_input.y*attackNode.global_transform.basis.y -move_input.x*attackNode.global_transform.basis.x)
	elif controllableMoveState == central.controllableMoveStates["ignore"]:
		move_dir = attackNode.global_transform.basis.z
	elif controllableMoveState == central.controllableMoveStates["none"]:
		move_dir = Vector3(0.0,0.0,0.0)
		bypass_move_dir_check = true
	move_dir = move_dir.normalized()
	
	
	
	
	if move_dir.length() > 0.0001 or bypass_move_dir_check:
		attackNode.velocity = move_dir * atkData["controllableSpeed"]#move_speed
		
		#method 1 creates jitters
		#rotation.y = lerp_angle(rotation.y, atan2(-move_dir.x, -move_dir.z), delta * rotation_speed)
		
		#method 2 directly change transform
		#var target_rot = Basis()
		#target_rot = target_rot.looking_at(-move_dir, Vector3.UP)
		#transform.basis = transform.basis.slerp(target_rot, delta * atkData["rotationSpeed"])
		
		if rotationMoveState == central.rotationMoveStates["allow"]:
			#print("allowing rotation")
			
			var target_rot = Basis.looking_at(-move_dir, Vector3.UP)
			attackNode.global_transform.basis = attackNode.global_transform.basis.slerp(target_rot, delta * atkData["rotationSpeed"])
		elif rotationMoveState == central.rotationMoveStates["limitBoth"]:
			#print("limiting both")
			#use move_input as x and y and attackerNodeRef.global_transform.basis.z as the constant z to choose a direction in the hemisphere in front of us
			var new_move_dir = -move_input.y*attackNode.global_transform.basis.y -move_input.x*attackNode.global_transform.basis.x
			# Get current facing direction
			var forward = -attackerNodeRef.global_transform.basis.z
			
			# Convert move_dir to global space if it's local
			var desired = new_move_dir.normalized()
			
			# Compute angle between forward and desired
			var angle = forward.angle_to(desired)
			
			# Limit how far off-forward we can turn (e.g. 90°)
			var max_angle = deg_to_rad(90)
			
			if angle > max_angle:
				# Clamp the direction to the edge of the forward hemisphere
				var axis = forward.cross(desired).normalized()
				var limited = forward.rotated(axis, max_angle)
				desired = limited.normalized()
			
			# Now rotate smoothly toward the clamped direction
			#var target_rot = Basis()
			var target_rot = Basis.looking_at(desired, Vector3.UP)
			attackNode.global_transform.basis = attackNode.global_transform.basis.slerp(target_rot, delta * atkData["rotationSpeed"])
		#should be instant because the player uses the shape to determine what direction it is going in
		#TODO: should we rotate the player too for some moves?

		last_velocity = attackNode.global_transform.basis.z
	else:
		attackNode.velocity = Vector3.ZERO
	
	
	#print("vel = ",velocity)




#################
##################################
###################################################
####################################################################
#                           Process (called elsewhere)
####################################################################
###################################################
##################################
#################

func attack_process(delta: float) -> void:
	
	#transform.basis = Basis.looking_at(-last_velocity, Vector3.UP)
	if not finalFixesDone:
		if not is_controlled:
			print("atkPower = ", atkData["power"])
			print("atkCost = ", atkData["cost"])
			print("releaseMoveState = ", releaseMoveState)
			if releaseMoveState == central.releaseMoveStates["default"]:
				
				
				attackNode.look_at(attackNode.global_transform.origin-last_velocity, Vector3.UP)
				attackNode.velocity = atkData["releaseSpeed"]*(last_velocity.normalized())
			elif releaseMoveState == central.releaseMoveStates["override"]:
				
				
				var properOverrideVel = attackerNodeRef.attackNode.global_transform.basis * override_velocity
				
				#alternative method, take the attackers x and y basis and add on a vertical component.
				#var oneOnRtTwo = 1.0/sqrt(2.0)
				#var properOverrideVel = oneOnRtTwo*(attackerNodeRef.global_transform.basis.x + attackerNodeRef.global_transform.basis.z) + Vector3(0,2.0,0)
				
				attackNode.look_at(attackerNodeRef.global_transform.origin-properOverrideVel, Vector3.UP)
				
				attackNode.velocity = atkData["releaseSpeed"]*(properOverrideVel.normalized())
				
				print("override_velocity_local = ", override_velocity)
				print("myTransform = ", attackNode.global_transform)
				print("releaseSpeed = ", properOverrideVel)
			elif releaseMoveState == central.releaseMoveStates["z"]:
				
				
				attackNode.look_at(attackNode.global_transform.origin-attackNode.global_transform.basis.z, Vector3.UP)
				attackNode.velocity = atkData["releaseSpeed"]*(attackNode.global_transform.basis.z)
				print("release vel = ", atkData["releaseSpeed"]*(attackNode.global_transform.basis.z))
			print("final fixes done")
			finalFixesDone = true
		
		#velocity = controllableSpeed*last_velocity.normalized()
	else:
		pass
		#velocity = releaseSpeed*last_velocity.normalized()
	move_and_slide(delta)#using velocity from handle input
	
	#TODO
	#tell parent class if it needs to update
	#change to more general condition
	#like a variable we have that is set to false that can be set to true
	if needsNeedsUpdate:
		needsUpdate = true

	#method 1:
	#var distFromStart = attackerNodeRef.global_transform.origin.distance_to(attackNode.global_transform.origin)
	
	#method 2:
	var distFromStart = startPos.distance_to(attackNode.global_transform.origin)
	
	#print("startPos = ", attackerNodeRef.global_transform.origin)
	#print("myPos = ", global_transform.origin)
	#print("dist = ", distFromStart)
	
	life += delta
	
	var rangeEndCondition = false
	if atkData["range"] > 0.0:
		rangeEndCondition = (distFromStart > atkData["range"])
	if life >= atkData["lifetime"] or rangeEndCondition: #so if range < 0.0 then it only checks for lifetime
		
		
		
		var cancel_death = false
		if is_controlled:
			#some things should just disappear otrhers should release
			if atkData.has("chargeState"):# and keyReleased == false:
				#keyReleased = true
				life = 0.0
				cancel_death = true
			attackerNodeRef.finish_stuck_animation()
			give_control_back_to_parent()
		
		if cancel_death:
			return
		
		if attackNode == attackerNodeRef:
			#we can't queue_free the attacker
			attackNode.end_attack(self)
		else:
			attackNode.queue_free()






#################
##################################
###################################################
####################################################################
#                           Hit something
####################################################################
###################################################
##################################
#################

func destroy_attack():
	life += atkData["lifetime"]  # destroy projectile if desired #instead of queue free


#TODO move all these to attack.gd
#so trhey can be called by signals

#func _hit_floor(floorRef):
	##explode and change terrain
	#pass
	



func _hit_floor(floorRef):
	#this just applies a crater, what about attacks that need to stick to the floor
	#and become a hazard
	var floorHazard = false
	if floorHazard == true:
		pass
		#there are a few ways we can do this and the choice is yours
		#spawn a hazard area - new script
		#just place the thing here change its vars so it stops moving
	
	
	print("hit floor")
	#if not terrain_ref:
		#return
	if floorRef.has_method("apply_crater") == false:
		print("doesnt have method")
		return
	
	var craterRadius = 0.0
	if atkData.has("craterRadius"):
		craterRadius = atkData["craterRadius"]
	
	if abs(craterRadius) < 1.0:
		#if craterRadius is too small or it doesn't exist then we return
		return
	if craterRadius < 0.0:
		#it is negative so we want to add terrain instead of removing it
		pass
		return
	#else: craterRadius is positive and above 1., apply crater
	
	# Get the world impact position of this attack
	var impact_pos = attackNode.global_transform.origin

	# Apply a small crater / dent
	var radius = 12.5
	var depth = 3.5

	floorRef.apply_crater(impact_pos, radius, depth)

	# Optional: add explosion FX
	#_spawn_hit_fx(impact_pos)
	destroy_attack()



func _hit_enemy(enemyRef):
	pass
	#explode and do dmaage
	#when we get hit by something we should figure out what to do
	var myStats = attackerNodeRef.stats
	var enemyStats = enemyRef.stats
	
	#Old method, uses the special stat to determine spawn type
	#var isPhysicalAttack = false
	#if self.get_class() == "CharacterBody3D":
		#isPhysicalAttack = true
	#else if it is an area...
	
	#new method, ALL attacks are inhereted from the hitbox area attack.gd
	var isPhysicalAttack = true
	if atkData["special"] == true:#then it is a special attack instead
		isPhysicalAttack = false
	
	#get stats
	var myAtk = 0.0
	var theirDef = 0.0
	if isPhysicalAttack:
		myAtk = myStats["physAtk"]
		theirDef = enemyStats["physDef"]
	else:
		myAtk = myStats["spclAtk"]
		theirDef = enemyStats["spclDef"]
	
	var myAtkType = atkData["element"]
	if atkData["element"] == "Innate":
		#set the attack type to our type
		myAtkType = myStats["element1"]
	elif atkData["element"] == "Innate2":
		#set the attack type to our type
		myAtkType = myStats["element2"]
	elif atkData["element"] == "InnateRandom":
		#set the attack type to our type
		var rand = randf()
		if rand > 0.5:
			myAtkType = myStats["element1"]
		else:
			myAtkType = myStats["element2"]
	
	var enemyTypes = [enemyStats["element1"], enemyStats["element2"]]
	var myTypes = [myStats["element1"], myStats["element2"]]
	
	#Also need S.T.A.B
	var STAB_Mod = 1.0
	if myAtkType in myTypes:
		STAB_Mod = 1.5
	
	#Also need damage boost from elemental
	var masterNodeRef = attackerNodeRef.masterNodeRef
	var elementDmgMult = masterNodeRef.get_node("AttacksData").get_damage_type_multiplier(myAtkType, enemyTypes[0], enemyTypes[1])
	#get_damage_type_multiplier(atkType, defenderType1, defenderType2 = "")
	
	#power ups through charging can affect the atkData stat before we get to this point
	
	#Calculate damage:
	
	var defenceMultiplier = 15.0 #myAtk*power/def is still outwighed by numerator, se we need extra denominator in [0,100], #tests show 50.0 is too hhigh withmy simple formular for damagae
	var finalDamage = float(atkData["power"]*myAtk*elementDmgMult*STAB_Mod)/float(defenceMultiplier*theirDef)
	
	#apply damage
	enemyStats["HP"] -= finalDamage
	print("///////////////////////////////////////////////////////")
	print("Did ", finalDamage, " amount of damage to the enemy")
	print("STAB_Mod = ", STAB_Mod, ", elementDmgMult = ", elementDmgMult, ", ...")
	print("///////////////////////////////////////////////////////")
	#(Alt apply damage to enemy and make them check their own defence and resistance and check for KO)
	
	
	##############################
	## KNOCKBACK
	################################
	if atkData.has("impact"):
		var impactVec = Vector2(0.0,0.0)
		impactVec = atkData["impact"]#Vector2 
		var horizontalImpact = impactVec.x
		var verticalImpact = impactVec.y
		var knockbackVelocity = Vector3.ZERO
		knockbackVelocity += horizontalImpact*attackNode.global_transform.basis.z
		knockbackVelocity += verticalImpact*Vector3.UP
		
		enemyRef.velocity += 1.0*knockbackVelocity
		#enemyRef.knockedBack = true
		enemyRef.movement_state = enemyRef.movement_states["knocked"]
		#enemyRef.movement_state = enemyRef.movement_states["jumping"]
	
	#KO if health below zero
	enemyRef.check_if_died()
	#if enemyStats["HP"] <= 0:
		#enemyRef.enter_KO_state()
	
	########################
	## DRAINING HEALTH
	#######################
	if atkData.has("drain"):
		var drainRatio = 0.0
		drainRatio = atkData["drain"]
		#pokemon does it through a proportion of attack power
		#we will do it as a proportion of health damaged
		var drainedHealth = drainRatio * finalDamage
		myStats["HP"] = min(myStats["HP"] + drainedHealth, myStats["maxHP"])#don't go above maxHP
		
	
	attackerNodeRef.lastHitEnemy = enemyRef
	
	#masterNodeRef.update_hp_bars(myStats, enemyStats, playerID)
	masterNodeRef.update_chars_hp_bars(attackerNodeRef)
	masterNodeRef.update_chars_hp_bars(enemyRef)
	destroy_attack()
	
	enemyRef.hit_by_attack(attackerNodeRef)#tells the hit anim to play and cpu state to respond if idle
	#enemyRef.switch_animation("HitReact")


func _hit_attack(attackRef):
	#explode both
	destroy_attack()
	#perhaps we should call it on the attack we hit too, just to make sure.
	pass



func check_if_on_same_team(nodeRef):
	var other_teamID = nodeRef.get("teamID")
	if other_teamID == null:
		return true#if it doesnt have a teamID we DONT want to attack
	#if nodeRef.has_variable("teamID"):
	if teamID == other_teamID:
		print("enemyNode = ", nodeRef)
		print("on same team, atkTeamID = ", teamID)
		return true
	return false#we only want to attack if they have a teamID and are on a seperate team


func _on_attack_body_entered_base(body: Node3D) -> void:
	print("on attack body entered")
	if body == attackerNodeRef:
		print("we are hitting ourselves")
		return
	#could be the floor, an attack, or the player
	#check collision layer
	print("body = ", body.name, ", body.get_collision_layer_value(1) = ", body.get_collision_layer_value(1))
	if body.get_collision_layer_value(1):
		print("hit layer 1")
		#is a monster
		if check_if_on_same_team(body):
			print("yo")
			#if we hit a teammate with a healing move the code would probs need to be here
			return
		
		_hit_enemy(body)
	elif body.get_collision_layer_value(2):
		print("hit layer 2")
		#is an attack
		if check_if_on_same_team(body):
			return
		_hit_attack(body)
	elif body.get_collision_layer_value(9):
		print("hit a floor...")
		#is a floor
		_hit_floor(body)
		pass
	else:
		print("no conditions were satisfied")



func _on_area_entered(area: Area3D) -> void:
	_on_attack_body_entered_base(area)
	pass # Replace with function body.


func _on_body_entered(body: Node3D) -> void:
	_on_attack_body_entered_base(body)
	pass # Replace with function body.


#################
##################################
###################################################
####################################################################
#                           Notes
####################################################################
###################################################
##################################
#################

#various attack types
#punch shoot attack choose direction then go straight
#move slowly while able to change direction then shoot straight
#not be able to move at all (still rotate) then shoot straight very fast
#punches have distance limitations, based on the distance from the attacker, if you exit control mode and let the punch fly and also run forward you can increase the range of the punch like a charge with a PUNCH

#beam charge up then shoot straight (no charge on some or afterwards)
#close punch/bite etc - directly in front, cant aim strong
#some of these physical moves might have a dash too, so you can use it as a secondary dodge
#move a target along the ground and artillery rains from above

#some moves always follow a definite path

#some moves that just leave traps

#some moves that just charge slowly as you hold the button, getting stronger or wider

#some moves that start wide and weak and then as you hold the button it charges into a refined beam and gets stronger
#as you charge the beam the cooldown could go down more, initial attack takes of 0.5 then extra takes off more

#some moves dont go entirely into cooldown and instead go into a partial cooldown, if you use it too much then you can use again (bullet seed)

#some moves are more about knockback than offense


#speed, width, strength, rotation speed, cooldown speed can all be tradeoffs
#some attacks cant go too far

#double button attacks
#move and shoot something else


#we need a way of loading the whole thing
#that is, load base attack, material adjust, effect loading, set up variables etc
#so we need a database of attacks




#we need to consolidate beam and punch
