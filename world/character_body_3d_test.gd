extends CharacterBody3D

var spd = 5.0 
func _process(delta: float) -> void:
	if Input.is_action_pressed("ui_up"):
		velocity = spd * global_transform.basis.z
	elif Input.is_action_pressed("ui_left"):
		rotate_y(delta)
	elif Input.is_action_pressed("ui_right"):
		rotate_y(-delta)
	else:
		velocity = Vector3.ZERO
	
	move_and_slide()
