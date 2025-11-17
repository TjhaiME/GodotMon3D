extends "res://attacks/base/punchTransition.gd"


func _fix_mesh_size(radius):
	##TODO make meshes for attacks, change this so it actually fits,
	#this is a placeholder.
	$model.scale = radius*Vector3(1.0,1.0,1.0)


func _on_ready_finished(atkData):
	print("on upper ready finished function")
	_fix_collisionShape3D(atkData["radius"])
	driverNode.fix_collision_layers($Hitbox)
	spawn_effect(atkData["visual"])
	$Hitbox.needsNeedsUpdate = true


func _process(delta: float) -> void:
	driverNode.attack_process(delta)
	if $Hitbox.needsUpdate == true:
		#ToDo make more general and work with different charge types
		var radius = $Hitbox.atkData["radius"]
		_fix_collisionShape3D(radius)
		_fix_mesh_size(radius)
		$Hitbox.needsUpdate = false
