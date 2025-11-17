extends "res://attacks/effects/beam_effect_parent.gd"



#
#
#func get_beam_scene(elementType):
	##Given a type we want to load a certain beam
	#var beamPathAlpha = "res://attacks/beams/cone/"
	#var beamPathOmega = "beam.tscn"
	#var typeStr = elementType.to_lower()
	#var beamPath = str(beamPathAlpha, typeStr, beamPathOmega)
	#var beamScene = load(beamPath).instantiate()
	#set_proper_length(atkLength, beamScene)
	#add_child(beamScene)
	#beamScene.rotate_y(PI)#flip so it faces +z
	#beamEffectScene = beamScene


func get_charge_scene(elementType):
	#Given a type we want to load a certain beam
	var beamPathAlpha = "res://attacks/effects/coneBeams/"
	var beamPathOmega = "beam.tscn"
	var typeStr = elementType.to_lower()
	var beamPath = str(beamPathAlpha, typeStr, beamPathOmega)
	#var beamScenePrototype = load(beamPath).instantiate()
	#var beamScene = beamScenePrototype.duplicate()
	#beamScenePrototype.queue_free()
	var beamScene = load(beamPath).instantiate()
	#IMPORTANT
	beamScene.process_material.scale_curve.curve_z = beamScene.process_material.scale_curve.curve_z.duplicate()
	
	add_child(beamScene)
	beamScene.rotate_y(PI)#flip so it faces +z
	chargeEffectScene = beamScene


#func _after_add_child_ready() -> void:
	##NOTE atkData is NOT set yet, since we have to set driverNode first
	##we use on_ready_finsiihed instead
	#driverNode = $Hitbox#this doesnt work if we are setting variables before we are ready
	#$Hitbox.attackNode = self
	#startPos = global_transform.origin
	#$Hitbox/CollisionShape3D.global_transform.origin = startPos + Vector3(0.0,0.0,0.5)
	##driverNode._on_ready()


func _on_ready_finished_fully(atkData):
	#overwrite, last stage of ready for attacks, all children ready
	var elType = $Hitbox.atkData["element"]
	print("atkData at beginning = ", $Hitbox.atkData)
	#get_beam_scene(elType)
	get_charge_scene(elType)
	set_proper_radius(atkData["radius"], chargeEffectScene)
	set_proper_length(atkData["range"], chargeEffectScene, 1.0)
	#set_new_emission_colour(Color(1.0,0.0,1.0))
	chargeEffectScene.emitting = true
	chargeEffectScene.lifetime = atkData["lifetime"] #TODO get from atkData or enough to charge
	#for charging mode
	chargeEffectScene.one_shot = false
	#set_proper_length(0.1, chargeEffectScene)
	var newLength = $Hitbox.atkData["range"]
	_fix_collision_and_mesh($Hitbox.atkData["radius"],newLength)

func _on_hitbox_attack_released():
	#return
	queue_free()
	return
	
	
	
	
	#var elType = $Hitbox.atkData["element"]
	#var rad = $Hitbox.atkData["radius"]
	#get_beam_scene(elType)
	##set_proper_radius(rad, beamEffectScene)
	##beamEffectScene.emitting = false
	##beamEffectScene.one_shot = true
	#
	##for charging mode
	#
	##set_proper_length(atkLength, beamEffectScene)
	#beamEffectScene.emitting = true
	#print("beamEffectScene stats, beamEffectScene = ", beamEffectScene, ", chargeBeam = ", chargeEffectScene, ", beamEffectScene points = ",
	 #beamEffectScene.process_material.scale_curve.curve_z.get("point_0/position"), ", ", beamEffectScene.process_material.scale_curve.curve_z.get("point_1/position"))




func _process(delta: float) -> void:
	#attack_process(delta)
	if $Hitbox.needsUpdate:
		
		#we done want to set it afesaf
		#var dir = $Hitbox.global_transform.basis.z
		#var newLength = $Hitbox.atkData["range"]
		#$Hitbox.global_transform.origin = global_transform.origin - 0.5*newLength*dir
		##OLD METHOD 1
		###how to get the new length
		#var oldOrigin = global_transform.origin
		#var atkStartPos = startPos#$Hitbox.attackerNodeRef.global_transform.origin + $Hitbox.attackerNodeRef.attackPosOffset
		#var distFromStart = atkStartPos.distance_to($Hitbox.global_transform.origin)
		##var atkStartPos = $Hitbox.attackerNodeRef.global_transform.origin + $Hitbox.attackerNodeRef.attackPosOffset
		##var distFromStart = atkStartPos.distance_to(global_transform.origin)
		#
		#var newLength = distFromStart
		#if newLength < 0.1:#visuals when it isnt moving
			#newLength = 0.1
		#_fix_collision_and_mesh($Hitbox.atkData["radius"],newLength)
		###then set so the front is at same pos so it keeps moving forward
		###global_transform.origin = oldOrigin
		###var dir = (oldOrigin - atkStartPos).normalized()
		###$model.global_transform.origin = global_transform.origin - 0.5*newLength*dir
		###$Hitbox.global_transform.origin = global_transform.origin - 0.5*newLength*dir
		##
		#
		##METHOD 3:
		##collisionLengthBasedOnLifetime($Hitbox.life)
		#
		
		$Hitbox.needsUpdate = false
