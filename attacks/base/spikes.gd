extends CharacterBody3D

#we want spikes that come out of the ground, maybe they can raise the terrain a bit too,
#they should ignore the floor as a physics object and come from underneath.
#not sure what controllable speed will be etc.


#startPos = Vector3(0.0, -0.541, 0.7)
#startRotation = Vector3(-39.3deg,0.0,0.0)

#endPos = Vector3(0.0, 0.078, 1.526)

#var dir = (endPos - startPos).normalized() = Vector3(0.0, 0.619, 0.826).normalized()
#sqrt(0.383161 + 0.682276) = 1.032200077504357
#var dir = Vector3(0.0, 0.5996899375328589, 0.800232452992151)

#press button and it should go into controllable mode
#we can move the startpos forward and back and rotate it
#when we let go it launches up from this spot under the ground up in the dir so the spikes point out of the ground
#always launches in dir direction
#we shouldnt rotate, instead we should move sideways

#we could summon more spike meshes and grow them and add them to us as we charge







func _on_ready_finished(atkData):
	print("on upper ready finished function")
	#_fix_collisionShape3D(atkData["radius"])
	$Hitbox.fix_collision_layers($Area3D)
	#spawn_effect(atkData["visual"])
	$Hitbox.controllableMoveState = central.controllableMoveStates["direct"]
	#spawn_mesh(atkData["type"])
	$Hitbox.rotationMoveState = central.rotationMoveStates["none"]
	$Hitbox.releaseMoveState = central.releaseMoveStates["override"]
	$Hitbox.override_velocity = Vector3(0.0, 0.5996899375328589, 0.800232452992151)
	pass#overwrite in upper class



func _process(delta: float) -> void:
	$Hitbox.attack_process(delta)


func _on_attack_body_entered(body: Node3D) -> void:
	$Hitbox._on_attack_body_entered_base(body)
	pass # Replace with function body.


func _on_attack_area_entered(area: Area3D) -> void:
	#is probably an attack
	pass # Replace with function body.
