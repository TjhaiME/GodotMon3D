extends InputProvider

func get_input_data() -> Dictionary:
	var input_data: Dictionary = {}

	# Movement (WASD)
	input_data["move"] = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	input_data["look"] = Input.get_vector("cam_left", "cam_right", "cam_forward", "cam_back")
	# Mouse look (optional, you can disable if not needed)
	#input_data["look"] = Vector2(
		#Input.get_last_mouse_velocity().x,
		#Input.get_last_mouse_velocity().y
	#)

	# Attack inputs
	input_data["attack_A_pressed"] = Input.is_action_just_pressed("attack_A")
	input_data["attack_A_held"] = Input.is_action_pressed("attack_A")
	input_data["attack_A_released"] = Input.is_action_just_released("attack_A")

	input_data["attack_B_pressed"] = Input.is_action_just_pressed("attack_B")
	input_data["attack_B_held"] = Input.is_action_pressed("attack_B")
	input_data["attack_B_released"] = Input.is_action_just_released("attack_B")
	

	input_data["attack_X_pressed"] = Input.is_action_just_pressed("attack_X")
	input_data["attack_X_held"] = Input.is_action_pressed("attack_X")
	input_data["attack_X_released"] = Input.is_action_just_released("attack_X")
	
	input_data["attack_Y_pressed"] = Input.is_action_just_pressed("attack_Y")
	input_data["attack_Y_held"] = Input.is_action_pressed("attack_Y")
	input_data["attack_Y_released"] = Input.is_action_just_released("attack_Y")

	# Other actions
	input_data["dodge_pressed"] = Input.is_action_just_pressed("dodge")
	input_data["jump_pressed"] = Input.is_action_just_pressed("jump")
	input_data["dodge_released"] = Input.is_action_just_released("dodge")
	input_data["jump_released"] = Input.is_action_just_released("jump")
	#print(input_data)
	
	return input_data
