extends HitboxAttack
#this is a slam attack

var driverNode = self


#func _ready():
	#_after_parent_ready()


##RUNS WHEN ATTACK SPAWNED BY MONSTER (halfway through)
func _after_add_child_ready():
	driverNode = self
	#driverNode.attackNode = self
	pass
	#runs when we spawn the attack

##RUNS WHEN ATTACK SPAWNED BY MONSTER (after entire process)
##attackDriver._after_parent_ready()
##then that calls on_ready_finished overwritten below

#override
func _on_ready_finished(atkData):
	#runs after we have set all variables and spawned all children
	driverNode.attackNode = driverNode.attackerNodeRef
	controllableMoveState = central.controllableMoveStates["direct"]
	
	#for the slam we want it to move the character it self

func _process(delta: float) -> void:
	attack_process(delta)


#TODO:
#add the default turning directions



#for monster we need attackNode.hitboxDelta

#we set the attackNode and the attackerNodeRef to the monster who used it, hopefully it works


func _on_attack_body_entered(body: Node3D) -> void:
	driverNode._on_attack_body_entered_base(body)
