class_name InteractArea3D
extends Area3D


#extends InteractArea3D
#func _ready() -> void:
	#uiPath = "res://UI/generalStoreUI.tscn"
	#pass
#when a creature comes inside this area
#we want it to be able to press "interact" and
#have this area do code

var masterRefNode = null #set in masterRefNode
#var uiPath = ""
@export var uiPath := ""#e.g. res://UI/checkInventoryUI.tscn, or res://UI/generalStoreUI.tscn
#chooses which scene to open

#func _ready() -> void:
	#uiPath = "res://UI/generalStoreUI.tscn"
	#pass

func interact(interacter):
	pass
	#when we are in this area and we press interact we should call this function
	print("we are interacting with this object")
	#now here is where we want to do the code to switch the Control node child of the subviewport to this one instead
	
	var newUI = load(uiPath).instantiate()
#spawn the new control node for the ui
#put the old one somewhere else or leave it
	var playerID = 0#this is for singleplayer
	var player = masterRefNode.players[playerID]
	#var uiViewport = player["uiViewport"]
	

#
		##set all these before spawning it
	var oldUI = player["uiViewport"].get_child(0)
	var attachedMesh = player["uiMesh"]
	var attachedViewport = player["uiViewport"]
	oldUI.visible = false
	newUI.oldUI = oldUI
	newUI.attachedMesh = attachedMesh
	newUI.attachedViewport = attachedViewport
	newUI.masterRefNode = masterRefNode
	attachedViewport.add_child(newUI)
		##do this at the end to refresh it
	var mat = attachedMesh.get_active_material(0)
	mat.albedo_texture = attachedViewport.get_texture()
	
	masterRefNode.set_control(newUI, playerID)

func _on_body_entered(body: Node3D) -> void:
	#print("body entered interact zone 1")
	if true:#its the only layer#body.get_collision_layer_value(1):
		#it's a monster
		if body.has_method("setInteractNode"):
			body.setInteractNode(self)
			print(body, " entered interact zone")
	pass # Replace with function body.


func _on_body_exited(body: Node3D) -> void:
	#print("body exited interact zone 1")
	if body.has_method("removeInteractNode"):
		body.removeInteractNode(self)
		print(body, " exited interact zone")
	pass # Replace with function body.
