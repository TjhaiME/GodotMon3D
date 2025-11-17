extends CharacterBody3D


#thos should extend attavk, it should just put areaAttack on the areaNode, or be an areaNode instead
var driverNode = null #was self now is being moved to hitbox
func _after_add_child_ready() -> void:
	driverNode = $Hitbox#this doesnt work if we are setting variables before we are ready
	driverNode.attackNode = self
	#driverNode._on_ready()

var hitboxDelta = 0.000001
#more options to modify the attack
#where do we start relative to the player
#how should we work in control and release modes
#when we hit the floor do we create a crater, how big etc
#do we have secondary effects that need to be run, if so what are they


#have a fast movement speed
#and a short suration so we only exit for a short time


#THIS OVERRIDES attck.gd ready function
#func _ready() -> void:
	#print("punch.gd ready function")
	#pass
	##move_speed = 10.0
	##duration = 5.0#0.5


func _fix_collisionShape3D(radius):
	return
	
	##Testin
	print("$CollisionShape3D.shape.size before = ", $CollisionShape3D.shape.size)
	$CollisionShape3D.shape.size = Vector3(2*radius, radius, 3*radius)
	print("$CollisionShape3D.shape.size after = ", $CollisionShape3D.shape.size)
	
	##TODO: general mode
	#if $CollisionShape3D.shape.has("size"):
		#print("$CollisionShape3D.shape.size before = ", $CollisionShape3D.shape.size)
		#$CollisionShape3D.shape.size = Vector3(2*radius, radius, 3*radius)
		#print("$CollisionShape3D.shape.size after = ", $CollisionShape3D.shape.size)
	#elif $CollisionShape3D.shape.has("radius"):
		#$CollisionShape3D.shape.radius = radius



func spawn_effect(effectScenePath):
	print("effectChildren = ", $effect.get_child_count())
	var newEffect = load(effectScenePath).instantiate()
	$effect.add_child(newEffect)
	newEffect.global_transform.origin = $effect.global_transform.origin
	await get_tree().process_frame
	var p = newEffect.get_node("GPUParticles3D")
	p.emitting = true
	p.restart()
	print("spawned new effect, effectChildren = ", $effect.get_child_count())
	#something exists it just isnt working for some reason

#func _after_add_child_ready():
	#pass

func _on_ready_finished(atkData):
	print("on upper ready finished function")
	_fix_collisionShape3D(atkData["radius"])
	driverNode.fix_collision_layers($Hitbox)
	spawn_effect(atkData["visual"])
	
	#spawn_mesh(atkData["type"])
	
	pass#overwrite in upper class



func _process(delta: float) -> void:
	driverNode.attack_process(delta)


func _on_attack_body_entered(body: Node3D) -> void:
	driverNode._on_attack_body_entered_base(body)
	pass # Replace with function body.


func _on_attack_area_entered(area: Area3D) -> void:
	#is probably an attack
	pass # Replace with function body.
