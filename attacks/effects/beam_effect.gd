extends GPUParticles3D



#this is an effect for a beam, it has a bigger part of the beam that goes to 30m throughout a lifetime
#there is an extra part that comes after the beam but it is just light

#we need to be able to change lifetime and x and y scale for the various attacks
#as well as change colour etc so it matches each element

#it is single shot so we need to use emitting

#scale.x = 0.237 gives about a 1m radius
#0.5 is about 2m radius
#so it is linear.
#
#0.474 is 2m

var atkLength = 30.0#metres
var myRadius = 1.0

var startPos = Vector3.ZERO

func _ready() -> void:
	set_proper_radius(0.5)
	set_new_emission_colour(Color(1.0,0.0,1.0))
	emitting = true
	lifetime = 3.0
	startPos = global_transform.origin
	$Area3D/CollisionShape3D.global_transform.origin = startPos + Vector3(0.0,0.0,0.5)

func set_proper_radius(radius):
	var scale = 0.237*radius
	process_material.scale_curve.curve_x.set("point_0/position", Vector2(0.0,scale))
	process_material.scale_curve.curve_x.set("point_0/position", Vector2(1.0,scale))
	process_material.scale_curve.curve_y.set("point_1/position", Vector2(0.0,scale))
	process_material.scale_curve.curve_y.set("point_1/position", Vector2(1.0,scale))



func set_new_emission_colour(newCol):
	var mat = draw_pass_1.get("surface_0/material")
	mat.emission = newCol

var myLife = 0.0
func _process(delta: float) -> void:
	myLife += delta
	collisionLengthBasedOnLifetime()


#
#
#func _process(delta: float) -> void:
	#attack_process(delta)
	#if needsUpdate:
		#
		##how to get the new length
		#var oldOrigin = global_transform.origin
		#var atkStartPos = attackerNodeRef.global_transform.origin + attackerNodeRef.attackPosOffset
		#var distFromStart = atkStartPos.distance_to(global_transform.origin)
		#var newLength = distFromStart
		#_fix_collision_and_mesh(atkData["radius"],newLength)
		##then set so the front is at same pos so it keeps moving forward
		#global_transform.origin = oldOrigin
		#var dir = (oldOrigin - atkStartPos).normalized()
		#$model.global_transform.origin = global_transform.origin - 0.5*newLength*dir
		#$CollisionShape3D.global_transform.origin = global_transform.origin - 0.5*newLength*dir
		#needsUpdate = false


func _fix_collision_and_mesh(radius, length):
	
	print("$CollisionShape3D.shape.size before = ", $Area3D/CollisionShape3D.shape.size)
	var currSize = $Area3D/CollisionShape3D.shape.size
	var targetSize = Vector3(2*radius, 2*radius, length)
	if currSize.distance_to(targetSize) < 0.15:
		return
	$Area3D/CollisionShape3D.shape.size = targetSize
	print("$CollisionShape3D.shape.size after = ", $Area3D/CollisionShape3D.shape.size)
	#$model/MeshInstance3D4.mesh.size = targetSize
	$Area3D/CollisionShape3D.global_transform.origin = global_transform.origin + 0.5*length*global_transform.basis.z


func collisionLengthBasedOnLifetime():
	##########
	
	#jksdfv
	#fgjsekho;ehwaiewlfJelkaJFlk'aeJ"F
	##fucked it
	
	########3
	#this is how we would do it if it took the whole time to get to the end.
	#var lifeRatio = float(myLife)/float(lifetime)
	#var collisionLength = lifeRatio*atkLength
	#_fix_collision_and_mesh(myRadius, collisionLength)
	#
	#but it gets there like halfway then stays
	var timeRatio = 0.6
	
	var lifeRatio = 1.0
	#if myLife < timeRatio*lifetime:
	lifeRatio = float(myLife)/float(lifetime)
	#float(myLife)/float(timeRatio*lifetime)
	print("llifeRatio = ", lifeRatio)
	print("myLife = ", myLife, " lifetime = ", lifetime)
	var collisionLength = lifeRatio*atkLength
	_fix_collision_and_mesh(myRadius, collisionLength)
	#var oldOrigin = global_transform.origin
	##var atkStartPos = attackerNodeRef.global_transform.origin + attackerNodeRef.attackPosOffset
	#var atkStartPos = startPos
	#print("atkStartPos = ", atkStartPos)
	#print("$Area3D/CollisionShape3D.global_transform.origin = ", $Area3D/CollisionShape3D.global_transform.origin)
	#var distFromStart = atkStartPos.distance_to($Area3D/CollisionShape3D.global_transform.origin)
	#var newLength = distFromStart
	##_fix_collision_and_mesh(atkData["radius"],newLength)
	##then set so the front is at same pos so it keeps moving forward
	#global_transform.origin = oldOrigin
	#var dir = ($Area3D/CollisionShape3D.global_transform.origin - atkStartPos).normalized()
	##$model.global_transform.origin = global_transform.origin - 0.5*newLength*dir
	#print("dir = ", dir)
	#$Area3D/CollisionShape3D.global_transform.origin = global_transform.origin + 0.5*newLength*dir
#so dir is backwards in a weird way and coll shape just movewss to zero and then dir  becomes zero
