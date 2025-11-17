extends Camera3D


func _process(delta: float) -> void:
	if Input.is_action_pressed("ui_page_down"):
		global_transform.origin.y -= 100.0*delta
	if Input.is_action_pressed("ui_page_up"):
		global_transform.origin.y += 50.0*delta
	if Input.is_action_pressed("ui_text_backspace"):
		var masterNode = get_parent()
		var playerNode = masterNode.get_node("Entities/Player")
		var dir = (playerNode.global_transform.origin - global_transform.origin).normalized()
		global_transform.origin += 25.0*delta*dir
