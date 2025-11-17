extends HitboxAttack
#extends AttackOldishHitbox


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

func _on_ready_finished(atkData):
	get_parent()._on_ready_finished_fully(atkData)


func _on_attack_released():
	#we overwrite this one too
	get_parent()._on_hitbox_attack_released()

func _process(delta: float) -> void:
	attack_process(delta)
	#all the below is done in the parent
	#if needsUpdate:
		#
		##how to get the new length
		#var oldOrigin = attackNode.global_transform.origin
		#var atkStartPos = attackerNodeRef.global_transform.origin + attackerNodeRef.attackPosOffset
		#var distFromStart = atkStartPos.distance_to(attackNode.global_transform.origin)
		#var newLength = distFromStart
		#_fix_collision_and_mesh(atkData["radius"],newLength)
		##then set so the front is at same pos so it keeps moving forward
		#attackNode.global_transform.origin = oldOrigin
		#var dir = (oldOrigin - atkStartPos).normalized()
		##var modelNode = get_parent().get_node("model")
		#var modelNode = attackNode.get_node("model")
		#modelNode.global_transform.origin = attackNode.global_transform.origin - 0.5*newLength*dir
		#$CollisionShape3D.global_transform.origin = attackNode.global_transform.origin - 0.5*newLength*dir
		#needsUpdate = false
#
#
#func _fix_collision_and_mesh(radius, length):
	#
	##print("$CollisionShape3D.shape.size before = ", $CollisionShape3D.shape.size)
	#var currSize = $CollisionShape3D.shape.size
	#var targetSize = Vector3(2*radius, 2*radius, length)
	#if currSize.distance_to(targetSize) < 0.15:
		#return
	#$CollisionShape3D.shape.size = targetSize
	##print("$CollisionShape3D.shape.size after = ", $CollisionShape3D.shape.size)
	##var modelNode = get_parent().get_node("model")
	#var modelNode = attackNode.get_node("model")
	#modelNode.get_node("MeshInstance3D4").mesh.size = targetSize
