extends Node3D

@export var input_provider_scene: PackedScene
var input_provider: InputProvider
var current_controller
var previous_controller



#var current_controller: Controllable
#var previous_controller: Controllable
#func set_control(new_controller: Controllable):
func set_control(new_controller):
	
	#if previous_controller:
		#if previous_controller.is_controlled == true:
	
	if current_controller:
		#if we have someone already deactivate them
		current_controller.is_controlled = false
		previous_controller = current_controller
	current_controller = new_controller
	current_controller.is_controlled = true
	if current_controller.has_method("on_set_control"):
		current_controller.on_set_control()

#######################################################################33
#     UI
#####################3

func update_hp_bars(myStats,enemyStats):
	#so we need to get HP and maxHP
	#then calculate the total length of the hp bar based on this ratio
	
	#enemyHP
	#size in [Vector2(0.0, 40.0), Vector2(675.0, 40.0)] #[empty, full]
	#position in [Vector2(668.0, 1.0), Vector2(-7.0,1.0)]
	#for enemyHP size.x gets changed to 675*HP/maxHP
	#position also goes from 668 to -7 = 675 difference
	#do pos.x = 668 - 675.0*HP/maxHP
	
	#myHP
	#size in [Vector2(0.0, 40.0), Vector2(671.0, 40.0)] #[empty, full]
	#position in [, Vector2(-2.0,-1.0)]
	#for myHP my size.x gets changed to 671*HP/maxHP
	
	
	$SubViewport/UIControl/enemiesHP/enemy_hpAbove.size.x = 671.0*float(enemyStats["HP"])/float(enemyStats["maxHP"])
	
	var myHPratio = 671.0*float(myStats["HP"])/float(myStats["maxHP"])
	$SubViewport/UIControl/myHP/hpAbove.size.x = myHPratio
	$SubViewport/UIControl/myHP/hpAbove.position.x = 668.0 - myHPratio
	
	
	##update labels:
	$SubViewport/UIControl/enemiesHP/Label.text = str(enemyStats["HP"], " HP")
	$SubViewport/UIControl/myHP/Label.text = str(myStats["HP"], " HP")

func update_cooldown_labels(buttonChar, value):
	#print("updating cooldown values to ", value)
	$SubViewport/UIControl/attackIcons/Label2.text = str(value,"%")
	

func update_generalCooldown_lock_visual(boolVal):
	#print("updating cooldown values to ", value)
	$SubViewport/UIControl/lockVisual.visible = boolVal


func update_generalCooldown_lock_visual_SAFE(boolVal):
	#maybe faster to check a boolean then to set visibility every frame...probs the same though
	#print("updating cooldown values to ", value)
	var isVisible = $SubViewport/UIControl/lockVisual.visible
	if isVisible != boolVal:
		$SubViewport/UIControl/lockVisual.visible = boolVal

###########################################################
func _ready():
	print("hello")
	var myStats = $Entities/Player.stats
	var enemyStats = $Entities/CharacterBody3D2.stats
	update_hp_bars(myStats, enemyStats)
	
	
	
	#var viewportNode = $FreeCam/MeshInstance3D.mesh.material.albedo_texture.viewport_path
	#$FreeCam/MeshInstance3D.mesh.material.albedo_texture.viewport_path = $FreeCam/MeshInstance3D.get_path_to($SubViewport)
	var mat = $FreeCam/MeshInstance3D.get_active_material(0)
	#var mat = $GoDoBox.get_active_material(0)
	mat.albedo_texture = $SubViewport.get_texture()
	
	#TODO fix
	
	# Spawn and attach the input provider (e.g., keyboard)
	if input_provider_scene:
		input_provider = input_provider_scene.instantiate()
		add_child(input_provider)
	else:
		push_warning("No input provider assigned!")
		
	
	
	#current_controller = $CharacterBody3D
	$Entities/Player.masterNodeRef = self
	set_control($Entities/Player)


var timer = 0.0
var threshold = 2.0
var mult = -1

func _physics_process(delta):
	if not current_controller or not input_provider:
		return

	var input_data = input_provider.get_input_data()
	#print(input_data)
	current_controller.handle_input(delta, input_data)
	
	
	##################################
	# test moving enemy
	#############
	timer += delta
	if timer > threshold:
		timer = 0.0
		mult *= -1
		#print("mult = ", mult)
		$Entities/CharacterBody3D2.velocity = 3.0*mult*global_transform.basis.z
	
	
	$Entities/CharacterBody3D2.move_and_slide()
	
	


func _on_area_3d_body_entered(body: Node3D) -> void:
	print("enemy hit by ", body)
	pass # Replace with function body.
