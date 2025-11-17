extends Node3D

#mix with the beam attack and the attack hitbox,

#on mixing we have some problems.
#the collision stays still when the effect is charging, but the effect plays
#we need a static effect (we could probably do this just by changing the particle effect and laoding it)
#the attack and collision also move forward, which sort of works

#for normal beam
#when holding emissitting = true
#one shot = false
#when let go emitting = true
#one shot = true


#make the various types of beams
#e.g. shorter with dynamic angle control (fire breath), or longer with less dynamic control kamehameha

var atkLength = 10.0#metres

var beamEffectScene = null
var chargeEffectScene = null

func get_beam_scene(elementType):
	#Given a type we want to load a certain beam
	var beamPathAlpha = "res://attacks/effects/coneBeams/"
	var beamPathOmega = "beam.tscn"
	var typeStr = elementType.to_lower()
	var beamPath = str(beamPathAlpha, typeStr, beamPathOmega)
	var beamScene = load(beamPath).instantiate()
	set_proper_length(atkLength, beamScene)
	add_child(beamScene)
	beamScene.rotate_y(PI)#flip so it faces +z
	beamEffectScene = beamScene


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
	set_proper_length(0.1, beamScene, 0.05)
	add_child(beamScene)
	beamScene.rotate_y(PI)#flip so it faces +z
	chargeEffectScene = beamScene

#var atkLength = 10.0#metres
var myRadius = 1.0

var startPos = Vector3.ZERO

#ar myType = "Ice"




var driverNode = null #was self now is being moved to hitbox #MOVED

func _after_add_child_ready() -> void:
	#NOTE atkData is NOT set yet, since we have to set driverNode first
	#we use on_ready_finsiihed instead
	driverNode = $Hitbox#this doesnt work if we are setting variables before we are ready
	$Hitbox.attackNode = self
	startPos = global_transform.origin
	$Hitbox/CollisionShape3D.global_transform.origin = startPos + Vector3(0.0,0.0,0.5)
	#driverNode._on_ready()


func _on_ready_finished_fully(atkData):
	#overwrite, last stage of ready for attacks, all children ready
	var elType = $Hitbox.atkData["element"]
	print("atkData at beginning = ", $Hitbox.atkData)
	#get_beam_scene(elType)
	get_charge_scene(elType)
	set_proper_radius(0.5, chargeEffectScene)
	#set_new_emission_colour(Color(1.0,0.0,1.0))
	chargeEffectScene.emitting = true
	chargeEffectScene.lifetime = 5.0 #TODO get from atkData or enough to charge
	#for charging mode
	chargeEffectScene.one_shot = false
	#set_proper_length(0.1, chargeEffectScene)

func _on_hitbox_attack_released():
	#return
	chargeEffectScene.queue_free()
	
	
	var elType = $Hitbox.atkData["element"]
	var rad = $Hitbox.atkData["radius"]
	get_beam_scene(elType)
	#set_proper_radius(rad, beamEffectScene)
	#beamEffectScene.emitting = false
	#beamEffectScene.one_shot = true
	
	#for charging mode
	
	#set_proper_length(atkLength, beamEffectScene)
	beamEffectScene.emitting = true
	print("beamEffectScene stats, beamEffectScene = ", beamEffectScene, ", chargeBeam = ", chargeEffectScene, ", beamEffectScene points = ",
	 beamEffectScene.process_material.scale_curve.curve_z.get("point_0/position"), ", ", beamEffectScene.process_material.scale_curve.curve_z.get("point_1/position"))

var hitboxDelta = 0.000001
var velocity = Vector3(0.0,0.0,0.0)
func move_and_slide():
	pass
	global_transform.origin += hitboxDelta*velocity


func add_collision_exception_with(attackerNodeRef):
	pass
	#for compatibility with areas and nodes










#extends AreaAttack


#TODO
#replace with area version (that is this one)

#make a charge beam version
#we charge it up and it gets wider (easy, make bigger as we charge)
#we charge it up and it goes from wide and weak to small and strong (transfer power data through control state)
#we charge it up and it uses more cooldown points (trnasfer cooldown differences)
#make a version that reflects off walls or floors too. (make it bounce..hmmmm)
#make a version like a flamethrower, controls just change the angle, it still comes from us, letting go stops it

#ideally we want this to be mixes of variables that are in attack,gs like bouncesOfWallsbeing an integer foir the numnber of oiybcds

var beamTypeInts = {
	"normal" : 0,
	"chargeBigger" : 1,#we charge it up and it gets wider (easy, make bigger as we charge)
	"chargeCondense" : 2,#we charge it up and it goes from wide and weak to small and strong (transfer power data through control state)
	"chargeCooldown" : 3,#we charge it up and it uses more cooldown points (trnasfer cooldown differences)
	"staticRange" : 4,#make a version like a flamethrower, controls just change the angle, it still comes from us, letting go stops it
}

var beamType = 0

#normal:
#charging mode goes nowhere but can change angle, release cant be controlled moves forward
#with various charge power and size modes the atkData radius gets increased

#what about flamethrower mode
#this has to be the right length already while in charge state so we can move it around
#when released it can be deleted
#if its only the flamethrower we can do an overwrite script



func _ready() -> void:
	$Hitbox.needsNeedsUpdate = true
	#get_beam_scene(myType)#myType must be set before ready runs so done in after add child ready







func set_proper_radius(radius, effectScene):
	#var scale = 0.237*radius
	#var scale = 
	var newScale = radius
	effectScene.process_material.scale_curve.curve_x.set("point_0/position", Vector2(0.0,newScale))
	effectScene.process_material.scale_curve.curve_x.set("point_1/position", Vector2(1.0,newScale))
	effectScene.process_material.scale_curve.curve_y.set("point_0/position", Vector2(0.0,newScale))
	effectScene.process_material.scale_curve.curve_y.set("point_1/position", Vector2(1.0,newScale))


func set_proper_length(length, effectScene, newMinVal=1.0):
	#var scale = 0.237*radius
	#var scale = 
	effectScene.process_material.scale_curve.curve_z.set("point_0/position", Vector2(0.0,newMinVal))
	effectScene.process_material.scale_curve.curve_z.set("point_1/position", Vector2(1.0,length))



func set_new_emission_colour(newCol):
	var mat = beamEffectScene.draw_pass_1.get("surface_0/material")
	mat.emission = newCol

#var myLife = 0.0
#func _process_TEST(delta: float) -> void:
	#myLife += delta
	#collisionLengthBasedOnLifetime()




func _fix_collision_and_mesh(radius, length):
	var colNode = $Hitbox/CollisionShape3D
	#print("$CollisionShape3D.shape.size before = ", colNode.shape.size)
	var currSize = colNode.shape.size
	var targetSize = Vector3(2*radius, 2*radius, length)
	if currSize.distance_to(targetSize) < 0.15:
		return
	colNode.shape.size = targetSize
	#print("$CollisionShape3D.shape.size after = ", colNode.shape.size)
	#$model/MeshInstance3D4.mesh.size = targetSize
	colNode.global_transform.origin = global_transform.origin + 0.5*length*global_transform.basis.z




############################################3
## actual attack old code:

func _process(delta: float) -> void:
	#attack_process(delta)
	if $Hitbox.needsUpdate:
		
		#OLD METHOD 1
		##how to get the new length
		var oldOrigin = global_transform.origin
		var atkStartPos = startPos#$Hitbox.attackerNodeRef.global_transform.origin + $Hitbox.attackerNodeRef.attackPosOffset
		var distFromStart = atkStartPos.distance_to($Hitbox.global_transform.origin)
		#var atkStartPos = $Hitbox.attackerNodeRef.global_transform.origin + $Hitbox.attackerNodeRef.attackPosOffset
		#var distFromStart = atkStartPos.distance_to(global_transform.origin)
		
		var newLength = distFromStart
		if newLength < 0.1:#visuals when it isnt moving
			newLength = 0.1
		elif newLength > atkLength:
			newLength = atkLength
		_fix_collision_and_mesh($Hitbox.atkData["radius"], newLength)
		##then set so the front is at same pos so it keeps moving forward
		##global_transform.origin = oldOrigin
		##var dir = (oldOrigin - atkStartPos).normalized()
		##$model.global_transform.origin = global_transform.origin - 0.5*newLength*dir
		##$Hitbox.global_transform.origin = global_transform.origin - 0.5*newLength*dir
		#
		
		#METHOD 3:
		#collisionLengthBasedOnLifetime($Hitbox.life)
		
		
		$Hitbox.needsUpdate = false










func collisionLengthBasedOnLifetime(myLife):
	
	#no longer used #needs to be? or is it covered?
	var timeRatio = 0.6
	
	var lifeRatio = 1.0
	#if myLife < timeRatio*lifetime:
	lifeRatio = float(myLife)/float(beamEffectScene.lifetime)
	#float(myLife)/float(timeRatio*lifetime)
	print("llifeRatio = ", lifeRatio)
	if lifeRatio > 1.0:#double lifetime as lifetime is for the individual particles
		if lifeRatio > 2.0:
			#ideally when it gets to 1 lifetime the collision box should shrink from the other end
			var areaNode = get_node_or_null("Area3D")
			if areaNode:
				areaNode.queue_free()#test
		return
	print("myLife = ", myLife, " lifetime = ", beamEffectScene.lifetime)
	var collisionLength = lifeRatio*atkLength
	_fix_collision_and_mesh(myRadius, collisionLength)
