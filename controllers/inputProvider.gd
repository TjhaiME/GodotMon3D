
class_name InputProvider
extends Node

# The goal is to return a dictionary of normalized input data.
# Each entity decides what subset of this data it cares about.
func get_input_data() -> Dictionary:
	return {
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
		"jump_pressed": false,
		"dodge_released": false,
		"jump_released": false,
	}
