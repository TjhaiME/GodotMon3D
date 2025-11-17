extends Node3D



#we want a node we can attack to monsters to give them the ability to be controlled by the computer
#it can be attached as a child to the monster.

#it may drive the controller or the monster itself.
#we need, walking to enemeny, detection area around us, raycast for sight, check for floor, check for climb

#for attacks we need to know the radius
#we can usually skip the control stage and release a button immediately, else move the stick towards enemy


#since essentially everything is done in the handle_input function we just have to rewrite this for ai
#then we also need to handle input of spawned attacks (or skip for now and release immediately)

#hmmmm nope this isnt gonna work

#we need to sinmulkate input

var monsterNode = null
var targetEnemy = null#in alert state it is the monster that just entered our area who is on another team, else we are actively targetting it
#var lastKnownPos = Vector3()
var enemiesInAlertRange = []
var alertRange = 10.0#metres
var failTimer = 0.0
var count = 0
var pressedAttackButton = ""#if "" then it is false, else buttonChar


var states = {
	"idle" : 0,#stand still do nothing for now
	#"halfAlert"
	"alert" : 1,#theres an enemy close, looking for it
	"hostile" : 2#actively targetting someone
}
var state = 0

func switch_states(newStateStr):
	count = 0
	failTimer = 0.0
	state = states[newStateStr]

func set_up_empty_input_data(input_data):
	input_data["move"] = Vector2(0.0,0.0)#Input.get_vector("-xleft", "+xright", "-ymove_forward", "+ymove_back")
	input_data["look"] = Vector2(0.0,0.0)#Input.get_vector("cam_left", "cam_right", "cam_forward", "cam_back")

	# Attack inputs
	input_data["attack_A_pressed"] = false
	input_data["attack_A_held"] = false
	input_data["attack_A_released"] = false

	input_data["attack_B_pressed"] = false
	input_data["attack_B_held"] = false
	input_data["attack_B_released"] = false
	

	input_data["attack_X_pressed"] = false
	input_data["attack_X_held"] = false
	input_data["attack_X_released"] = false
	
	input_data["attack_Y_pressed"] = false
	input_data["attack_Y_held"] = false
	input_data["attack_Y_released"] = false

	# Other actions
	input_data["dodge_pressed"] = false
	input_data["jump_pressed"] = false
	input_data["dodge_released"] = false
	input_data["jump_released"] = false
	
	return input_data

func _ready() -> void:
	monsterNode = get_parent()
	monsterNode.is_controlled = true

func _process(delta: float) -> void:
	
	
	
	var input_data = {}
	input_data = set_up_empty_input_data(input_data)
	
	


	
	
	
	if pressedAttackButton != "":
		var buttonChar = pressedAttackButton
		input_data[str("attack_",buttonChar,"_released")] = true
		pressedAttackButton = ""
	
	
	if state == states["idle"]:
		handle_idle_state(delta, input_data)
	elif state == states["alert"]:
		input_data = handle_alert_state(delta, input_data)
	else:
		input_data = handle_hostile_state(delta, input_data)
	
	
	monsterNode.handle_input(delta, input_data)

var testCount = 0
func _turn_to_enemy():
	
	testCount += 1
	if testCount > 10:
		print("monsterNode = ", monsterNode, ", pos ", monsterNode.global_transform.origin)
		print("targetEnemy = ", targetEnemy, ", pos ", targetEnemy.global_transform.origin)
		#THIS IS STRANGE THERE IS A POINT WHERE THEY ARE THE SAME NODE.... the enemy is targetting itself
		#also weird as we got an error saying get() expects only 1 variable but we have called in with 2 variables (one for defau;lt value) before and it has worked
		#needs more testing
		testCount = 0
	
	
	if targetEnemy != null:
		var oldRot = monsterNode.rotation
		monsterNode.look_at(targetEnemy.global_transform.origin, Vector3(0, 1, 0), true)
		var newRot = oldRot
		newRot.y = monsterNode.rotation.y
		monsterNode.rotation = newRot
		#(target: Vector3, up: Vector3 = Vector3(0, 1, 0), use_model_front: bool = false)

func handle_idle_state(delta, input_data):
	if enemiesInAlertRange.size() <= 0:
		return
	
	failTimer += delta
	
	if failTimer >= 3.0:
		
		
		var testTargetEnemy = enemiesInAlertRange[count]
		var dirToEnemy = testTargetEnemy.global_transform.origin - monsterNode.global_transform.origin
		var enemyRayResult = monsterNode.raycast(monsterNode.global_transform.origin, dirToEnemy, alertRange, 1 | 1<<8)
		if enemyRayResult:
			targetEnemy = testTargetEnemy
			#count = 0
			#failTimer = 0.0
			#state = states["hostile"]
			switch_states("hostile")
			return input_data
		
		
		count = (count + 1)%enemiesInAlertRange.size()
		failTimer = 0.0
	
	return input_data



func handle_alert_state(delta, input_data):
	_turn_to_enemy()

	if targetEnemy == null:
		switch_states("idle")
		return input_data
	if is_instance_valid(targetEnemy) == false:
		switch_states("idle")
		return input_data
	
	#look for the targetEnemy
	var dirToEnemy = targetEnemy.global_transform.origin - monsterNode.global_transform.origin
	var enemyRayResult = monsterNode.raycast(monsterNode.global_transform.origin, dirToEnemy, alertRange, 1 | 1<<8)
	var rayResultFailed = false
	if !enemyRayResult:
		#state = states["idle"]
		rayResultFailed = true
	else:
		if enemyRayResult.collider == targetEnemy:
			#failTimer = 0.0
			#state = states["hostile"]
			switch_states("hostile")
		else:
			rayResultFailed = true
	
	if rayResultFailed == true:
		failTimer += delta
		if failTimer > 2.0:
			#failTimer = 0.0
			#state = states["idle"]
			switch_states("idle")
		#return input_data
	
	input_data["move"] = Vector2(0.0,-1.0)#move forward while alert
	
	return input_data


func handle_hostile_state(delta, input_data):
	_turn_to_enemy()
	
	if pressedAttackButton != "":
		return input_data
	if targetEnemy == null:
		#state = states["idle"]
		switch_states("idle")
		return input_data
	if is_instance_valid(targetEnemy) == false:
		#state = states["idle"]
		switch_states("idle")
		return input_data
	
	#look for the targetEnemy
	var dirToEnemy = targetEnemy.global_transform.origin - monsterNode.global_transform.origin
	var enemyRayResult = monsterNode.raycast(monsterNode.global_transform.origin, dirToEnemy, alertRange, 1 | 1 << 1 | 1<<8)
	if !enemyRayResult:
		#state = states["idle"]
		failTimer += delta
		if failTimer > 3.0:
			#failTimer = 0.0
			#state = states["alert"]
			switch_states("alert")
		return input_data
	#else:
	#we can see something, should we attack, move or keep going 
	#if we see the enemy then it is a clear line of sight between us
	if enemyRayResult.collider == targetEnemy:
		pass
		#this is ideal, should we attack?
		#probs need another function for checking what our moves are, what range is, whats super effective etc, do later
		var hit_pos = enemyRayResult.position
		var dist = monsterNode.global_transform.origin.distance_to(hit_pos)
		if dist < 5.0:
			##TODO FIX CHOOSE EFFECTIVE ATTACK
			#for now we choose randomly
			var randIndex = randi()%3
			var buttons = ["A", "B", "X", "Y"]
			var buttonChar = buttons[randIndex]
			##var atkData = masterNodeRef.get_node("AttacksData").moveData[attackName]
			#var myMoves = monsterNode.stats["moves"]
			#var atkName = myMoves[buttonChar]
			#monsterNode.do_attack(buttonChar, atkName)
			#I dont want to call the attack I want to press the button to do the attack
			input_data[str("attack_",buttonChar,"_pressed")] = true
			input_data[str("attack_",buttonChar,"_held")] = true
			pressedAttackButton = buttonChar
	#elif it is on the floor (1 << 8) then do something
	#elif it is an attack then check the length to the attack (1 << 1) and gaurd/dodge (input_data["dodge_pressed"] = true + input_data["move"] = Vector2(+-1.0,0.0))
	elif enemyRayResult.collider.collision_layer & (1 << 8):
		# Hit the floor
		print("Floor blocking LOS")
		# do something

	elif enemyRayResult.collider.collision_layer & (1 << 1):
		# Hit an attack
		print("Attack detected")
		
		##BADLY DONE AS ITS NOT CHECKING THE DIRECTION OF THE ATTACK
		
		# distance check for dodge or guard:
		var hit_pos = enemyRayResult.position
		var dist = monsterNode.global_transform.origin.distance_to(hit_pos)
		if dist < 2.0: # example threshold
			input_data["dodge_pressed"] = true
			input_data["move"] = Vector2(1.0, 0.0) # strafe/evade
			return input_data
	
	input_data["move"] = Vector2(0.0,-1.0)#move forward while alert
	
	return input_data



func check_if_on_same_team(nodeRef):
	var other_teamID = nodeRef.get("teamID")
	if other_teamID == null:
		return true#if it doesnt have a teamID we DONT want to attack
	#if nodeRef.has_variable("teamID"):
	if monsterNode.teamID == other_teamID:
		print("enemyNode = ", nodeRef)
		print("on same team, aiTeamID = ", monsterNode.teamID)
		return true
	return false#we only want to attack if they have a teamID and are on a seperate team

func _on_alert_area_entered(bodyNode):
	pass
	#when a char enters ouralert area we  should add them to the list and make them a temporary target in alert state
	if bodyNode in enemiesInAlertRange:
		pass
	else:
		if !check_if_on_same_team(bodyNode):
			return
		#if monsterNode.teamID == enemyTeamID:
			#return #on same team
		enemiesInAlertRange.append(bodyNode)
		if state == states["idle"]:
			targetEnemy = enemiesInAlertRange[0]
			#state = states["alert"]
			#failTimer = 0.0
			#count = 0
			switch_states("alert")
		#elif state == states["alert"]:
			#



func _on_alert_area_exited(bodyNode):
	pass
	#when a char enters ouralert area we  should add them to the list and make them a temporary target in alert state
	if bodyNode in enemiesInAlertRange:
		enemiesInAlertRange.erase(bodyNode)
	else:
		pass
	
	if enemiesInAlertRange.size() > 0:
		targetEnemy = enemiesInAlertRange[0]
		switch_states("alert")
		#state = states["alert"]
		#failTimer = 0.0
		#count = 0
	
