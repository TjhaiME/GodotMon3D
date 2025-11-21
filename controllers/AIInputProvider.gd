extends Node
class_name AIInputProvider

# set these from ControllerManager after instancing
var manager = null            # ControllerManager node (must be set)
var player_index: int = 0     # which player's inputs this provider is for
@export var difficulty: float = 1.0 # [0.0..2.0] higher -> more aggressive/faster decisions
@export var think_interval: float = 0.12 # seconds between decision updates

# internal state for edge-triggered buttons
var _prev_state := {
	"attack_A": false,
	"attack_B": false,
	"attack_X": false,
	"attack_Y": false,
	"dodge": false
}
var _hold_state := {
	"attack_A": false,
	"attack_B": false,
	"attack_X": false,
	"attack_Y": false,
	"dodge": false
}

# timers
var _think_timer := 0.0
var rng := RandomNumberGenerator.new()

# short memory
var target_node = null
var last_target_pos = Vector3.ZERO
var last_move_vec = Vector2.ZERO

func _ready():
	rng.randomize()

# call this from ControllerManager after creating provider:
func set_manager_and_index(_manager, idx: int) -> void:
	manager = _manager
	player_index = idx

# helper: get this player's current controlled entity (monster or attack driver)
func _get_controlled_entity():
	if manager == null:
		return null
	if player_index < 0 or player_index >= manager.players.size():
		return null
	return manager.players[player_index]["current_controller"]

# helper: choose a target (first enemy found)
func _find_target():
	# simple selection: find first controller that isn't our player and is not null
	if manager == null:
		return null
	for i in range(manager.players.size()):
		if i == player_index:
			continue
		var other = manager.players[i]["current_controller"]
		if other != null:
			return other
	# fallback: search Entities node (if you have fixed opponent nodes)
	if get_tree().root.has_node("root") == false:
		# best-effort search under manager's scene
		pass
	return null

# convert world direction to the 2D stick vector your monsters expect:
# returns Vector2(x,right, y,forward) mapping so Monster.handle_input works:
# Monster uses: move_dir = (-move_input.y * basis.z - move_input.x * basis.x)
# We compute projections onto right and forward vectors:
func _world_dir_to_move_input(controller, dir: Vector3) -> Vector2:
	if controller == null:
		return Vector2.ZERO
	dir = dir.normalized()
	var right = controller.global_transform.basis.x
	var forward = -controller.global_transform.basis.z
	var x = dir.dot(right)
	var y = dir.dot(forward)
	var v = Vector2(x, y)
	if v.length() > 1.0:
		v = v.normalized()
	return v

# check attack readiness by reading attack cost vs cooldown from entity
# returns true if this attack button is "ready" enough to consider
func _attack_ready(controller, button_char: String, atk_name: String) -> bool:
	if controller == null:
		return false
	if not controller.has_method("cooldowns") and not controller.has_variable("cooldowns"):
		# controller uses cooldowns dict
		pass
	# controller.cooldowns holds current [0..100] values; attacks cost use moveData
	var attacks_node = manager.get_node("AttacksData") if manager and manager.has_node("AttacksData") else null
	if attacks_node == null:
		# fallback: assume ready
		return true
	if not attacks_node.has_method("moveData") and not attacks_node.has_variable("moveData"):
		# try direct property
		pass
	var moveData = attacks_node.moveData if attacks_node.has_variable("moveData") else {}
	if not moveData.has(atk_name):
		return false
	var cost = float(moveData[atk_name].get("cost", 30.0))
	# controller.cooldowns is a dictionary of A/B/X/Y -> value (0..100)
	if controller.cooldowns.has(button_char):
		return controller.cooldowns[button_char] >= cost
	# fallback true
	return true

# main API used by ControllerManager
func get_input_data() -> Dictionary:
	# default neutral input
	var input_data := {
		"move": Vector2.ZERO,
		"look": Vector2.ZERO,
		"attack_A_pressed": false,
		"attack_A_held": false,
		"attack_A_released": false,
		"attack_B_pressed": false,
		"attack_B_held": false,
		"attack_B_released": false,
		"attack_X_pressed": false,
		"attack_X_held": false,
		"attack_X_released": false,
		"attack_Y_pressed": false,
		"attack_Y_held": false,
		"attack_Y_released": false,
		"dodge_pressed": false,
		"dodge_held": false,
		"dodge_released": false,
		"jump_pressed": false,
		"interact_pressed" : false,
		"interact_held" : false,
		"interact_released" : false
	}

	_think_timer -= Engine.get_physics_interpolation_fraction() # use frame time approx
	# safer: use delta if passed — but your InputProvider API doesn't pass delta. We'll tick with OS.get_ticks_msec.
	# We'll update decisions only at intervals to reduce jitter
	# Use real time to control think interval
	# We maintain an internal clock:
	if _think_timer <= 0.0:
		_make_decisions()
		_think_timer = max(0.02, think_interval * (1.0 / max(0.2, difficulty)))

	# translate _hold_state -> pressed/released edges
	for key in ["attack_A", "attack_B", "attack_X", "attack_Y", "dodge"]:
		var held = _hold_state[key]
		var prev = _prev_state[key]
		var pressed_key = "%s_pressed" % key.replace("_", "").to_upper()
		var held_key = "%s_held" % key.replace("_", "").to_upper()
		var released_key = "%s_released" % key.replace("_", "").to_upper()
		# map names properly:
		# attack_A -> attack_A_pressed etc.
		# dodge -> dodge_pressed
		# Build mapping manually:
		if key.begins_with("attack"):
			var letter = key.split("_")[1]
			input_data["attack_%s_pressed" % letter] = (held and (not prev))
			input_data["attack_%s_held" % letter] = held
			input_data["attack_%s_released" % letter] = (not held and prev)
		elif key == "dodge":
			input_data["dodge_pressed"] = (held and (not prev))
			input_data["dodge_held"] = held
			input_data["dodge_released"] = (not held and prev)

	_prev_state = _hold_state.duplicate(true)

	# move + look are maintained in _hold_state as "last_move_vec" and "last_look_vec"
	input_data["move"] = last_move_vec
	input_data["look"] = Vector2.ZERO

	# return the generated input
	return input_data

# internal decision routine
func _make_decisions() -> void:
	var controller = _get_controlled_entity()
	if controller == null:
		# nothing to control
		last_move_vec = Vector2.ZERO
		_hold_state["attack_A"] = false
		_hold_state["attack_B"] = false
		_hold_state["attack_X"] = false
		_hold_state["attack_Y"] = false
		_hold_state["dodge"] = false
		return

	# locate target
	if target_node == null or not is_instance_valid(target_node):
		target_node = _find_target()

	# If we are currently controlling an attack (attack driver), steer it toward target
	# Attack drivers usually have attributes like teamID, attackerNodeRef, and a startPos
	# We'll treat it like any other controller: move toward target
	if str(controller.get_class()).to_lower().find("attack") != -1 or controller.name.find("driver") != -1 or controller.has_variable("teamID") and controller.has_variable("atkData"):
		# steer projectile toward target
		if target_node != null:
			var dir = (target_node.global_transform.origin - controller.global_transform.origin)
			last_move_vec = _world_dir_to_move_input(controller, dir)
		else:
			last_move_vec = Vector2.ZERO
		# keep holding no attack buttons while steering attack
		_hold_state["attack_A"] = false
		_hold_state["attack_B"] = false
		_hold_state["attack_X"] = false
		_hold_state["attack_Y"] = false
		_hold_state["dodge"] = false
		return

	# Normal monster control:
	# 1) Move toward target with some offset
	# 2) If an attack is available and target is in range, press attack
	# 3) Dodge if enemy attack driver or incoming projectile is too close

	# default movement: idle jitter
	last_move_vec = Vector2.ZERO

	if target_node != null:
		var to_target = target_node.global_transform.origin - controller.global_transform.origin
		var dist = to_target.length()
		# compute stick vector
		var desired_move = _world_dir_to_move_input(controller, to_target)
		# approach or circle depending on distance
		var approach_thresh = 6.0 - (difficulty * 2.0) # smaller with higher difficulty -> get closer
		if dist > approach_thresh:
			# move toward
			last_move_vec = desired_move
		else:
			# in range: small strafing motion to be less predictable
			var strafe = Vector2(-desired_move.y, desired_move.x) * 0.6
			last_move_vec = (desired_move * 0.3 + strafe * 0.7).normalized()

	# decide attacks
	# query move data to choose an attack that is ready and in range
	var attacks_node = manager.get_node("AttacksData") if manager and manager.has_node("AttacksData") else null
	if attacks_node != null:
		var moveData = attacks_node.moveData
		# simple priority order: A, B, X, Y
		for pair in [["A","A"], ["B","B"], ["X","X"], ["Y","Y"]]:
			var btn = pair[0]
			# try to find name assigned to this button on controller
			# controllers may not have a mapping from button->move; we attempt common names:
			# assume controller has a property or mapping, try safe-guards:
			var atk_name = null
			# try reading assigned move name from controller (if you store it)
			if controller.has_variable("move_assignments") and controller.move_assignments.has(btn):
				atk_name = controller.move_assignments[btn]
			else:
				# fallback: pick a move in the global list with same name as common mapping
				# we'll try couple known names to be safe
				var candidates = ["Beam","Charge Punch","Slam","Dodge"]
				for c in candidates:
					if moveData.has(c):
						atk_name = c
						break
			if atk_name == null:
				continue
			# crude range check if move defines range
			var in_range = true
			if moveData[atk_name].has("range") and target_node != null:
				in_range = (target_node.global_transform.origin.distance_to(controller.global_transform.origin) <= float(moveData[atk_name]["range"]) * 1.1)
			# check cooldown via controller.cooldowns
			var ready = true
			if controller.cooldowns.has(btn):
				var cost = float(moveData[atk_name].get("cost", 30.0))
				ready = controller.cooldowns[btn] >= cost
			# attack if ready and in range with some probability scaled by difficulty
			if ready and in_range and rng.randf() < 0.6 * clamp(difficulty, 0.2, 2.0):
				_hold_state["attack_%s" % btn] = true
				# hold a bit then release in next AI tick; emulate a quick press
				# we set hold true for one tick; the pressed edge will be emitted
				# schedule release next tick by clearing on next decision
				# implement simple release scheduling:
				# we'll set it true only this tick; next tick we'll set to false by default below
				# break after first chosen attack
				# ensure other attacks not held
				for k in ["A","B","X","Y"]:
					if k != btn:
						_hold_state["attack_%s" % k] = false
				break

	# between decisions, randomly decide to dodge if target is attacking or close
	var should_dodge = false
	if target_node != null:
		# if an attack node (projectile) is near us, dodge
		# simple check: search in parent Attacks for nodes close by
		if manager and manager.has_node("Attacks"):
			var attacks_parent = manager.get_node("Attacks")
			for child in attacks_parent.get_children():
				if not is_instance_valid(child):
					continue
				# crude: check distance to any attack not from our team
				if child.has_variable("teamID") and child.teamID == controller.teamID:
					continue
				if child.global_transform.origin.distance_to(controller.global_transform.origin) < 2.0:
					should_dodge = true
					break
		# also dodge sometimes when very close to target and target looks like charging (best-effort)
		if controller and target_node and target_node.has_variable("busyDodging") and target_node.busyDodging:
			if rng.randf() < 0.8 * difficulty:
				should_dodge = true

	if should_dodge and rng.randf() < 0.6 * difficulty:
		_hold_state["dodge"] = true
	else:
		_hold_state["dodge"] = false

	# small randomness: clear attack holds so they become press edges next decision
	# simple timing: only hold an attack for a single decision cycle
	for k in ["A","B","X","Y"]:
		if _hold_state.has("attack_%s" % k) and _hold_state["attack_%s" % k] == true:
			# leave as-is this tick; next tick we will clear unless we want to continue holding
			# implement short hold: randomly decide if hold continues
			if rng.randf() < 0.25 * difficulty:
				# continue hold
				pass
			else:
				_hold_state["attack_%s" % k] = false
