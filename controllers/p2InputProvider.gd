extends InputProvider

func get_input_data() -> Dictionary:
	var input_data: Dictionary = {}

	# Movement (WASD)
	input_data["move"] = Input.get_vector("move_left_p2", "move_right_p2", "move_forward_p2", "move_back_p2")
	input_data["look"] = Input.get_vector("cam_left_p2", "cam_right_p2", "cam_forward_p2", "cam_back_p2")
	# Mouse look (optional, you can disable if not needed)
	#input_data["look"] = Vector2(
		#Input.get_last_mouse_velocity().x,
		#Input.get_last_mouse_velocity().y
	#)

	# Attack inputs
	input_data["attack_A_pressed"] = Input.is_action_just_pressed("attack_A_p2")
	input_data["attack_A_held"] = Input.is_action_pressed("attack_A_p2")
	input_data["attack_A_released"] = Input.is_action_just_released("attack_A_p2")

	input_data["attack_B_pressed"] = Input.is_action_just_pressed("attack_B_p2")
	input_data["attack_B_held"] = Input.is_action_pressed("attack_B_p2")
	input_data["attack_B_released"] = Input.is_action_just_released("attack_B_p2")
	

	input_data["attack_X_pressed"] = Input.is_action_just_pressed("attack_X_p2")
	input_data["attack_X_held"] = Input.is_action_pressed("attack_X_p2")
	input_data["attack_X_released"] = Input.is_action_just_released("attack_X_p2")
	
	input_data["attack_Y_pressed"] = Input.is_action_just_pressed("attack_Y_p2")
	input_data["attack_Y_held"] = Input.is_action_pressed("attack_Y_p2")
	input_data["attack_Y_released"] = Input.is_action_just_released("attack_Y_p2")

	# Other actions
	input_data["dodge_pressed"] = Input.is_action_just_pressed("dodge_p2")
	input_data["jump_pressed"] = Input.is_action_just_pressed("jump_p2")
	input_data["dodge_released"] = Input.is_action_just_released("dodge_p2")
	input_data["jump_released"] = Input.is_action_just_released("jump_p2")
	
	input_data["interact_pressed"] = Input.is_action_just_pressed("interact_p2")
	input_data["interact_held"] = Input.is_action_pressed("interact_p2")
	input_data["interact_released"] = Input.is_action_just_released("interact_p2")
	
	#print(input_data)
	
	return input_data
