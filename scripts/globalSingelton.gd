extends Node

#var p1MonsterName: String = ""
#var p2MonsterName: String = ""

var capsuleRadius = 0.3#for all of them
var capsuleHeight = 1.5#for all of them
#but they still need to be set for other (non-quaternius) monsters
#var monsterModelHeights = {
	#"Alien" : "?",
	#"Birb" : 1.5,
	#"BlueDemon" : 1.5,
	#"Bunny" : 1.5,
	#"Cactoro" : "res://assets/monsters/quaternius/glTF/Alien.gltf",
	#"Demon" : 1.5,
	#"Dino" : 1.5,
	#"Fish" : 1.5,
	#"Frog" : 1.5,
	#"Monkroose" : 1.5,
	#"MushroomKing" : "res://assets/monsters/quaternius/glTF/Alien.gltf",
	#"Ninja" : 1.5,
	#"Orc" : 1.5,
	#"Orc_Skull" : 1.5,
	#"Tribal" : "res://assets/monsters/quaternius/glTF/Alien.gltf",
	#"Yeti" : 1.5,
#}

#var monsterSpeciesList := [
	#"Alien", "Birb", "BlueDemon", "Bunny",
	#"Cactoro", "Demon", "Dino", "Fish", "Frog",
	#"Monkroose", "MushroomKing", "Ninja", "Orc",
	#"Tribal", "Yeti"
#]



# Optional: scene switching helper
func change_scene(target_path: String, preReadyVars = {}):
	var tree = get_tree()
	if tree.current_scene:
		tree.current_scene.queue_free()
	var new_scene = load(target_path).instantiate()
	
	#if we have preReadyVars we need to set before adding child
	for key in preReadyVars.keys():
		#if new_scene.get(key, null) != null:
		if key in new_scene:
			new_scene.set(key, preReadyVars[key])
	
	
	tree.root.add_child(new_scene)
	tree.current_scene = new_scene


#
var height_scale: float = 5.0
var heightmap_image: Image
var heightmap_texture: Texture2D


var size_x = 0.0#central.size_x
var size_z = 0.0#central.size_z
var cell_size = 0.0#central.cell_size

var terrain_global_pos = Vector3(0.0,0.0,0.0)#central.terrain_global_pos


var controllableMoveStates = {
	"direct" : 0, #only move where we tell you to move (allows rotation)
	"forward" : 1, #move forward automatically, use control stick for other basis vectors in 3d
	#"these with and without rotation as well" : 2,
	"limit" : 2, #like a flamethrower attack, moves forward to a range then "stops" (visual looks like it keeps going, use control stick to change angle
	"ignore" : 3,#dont stop the thing just because we are in control mode
	"none" : 4,
}

var rotationMoveStates = {
	"allow" : 0,
	"none" : 1,
	"limitBoth" : 2,#both control stick axes change the angle of the attack xz, xy
}

var releaseMoveStates = {
	"default" : 0,#use the last_velocity we had
	"override" : 1,#use a specific dir or function to get the dir
	"z" : 2, #use your z dir
}



#var monsterModelPaths = {
	#"Alien" : "res://assets/monsters/quaternius/glTF/Alien.gltf",
	#"Birb" : "res://assets/monsters/quaternius/glTF/Birb.gltf",
	#"BlueDemon" : "res://assets/monsters/quaternius/glTF/Alien.gltf",
	#"Bunny" : "res://assets/monsters/quaternius/glTF/Alien.gltf",
	#"Cactoro" : "res://assets/monsters/quaternius/glTF/Alien.gltf",
	#"Demon" : "res://assets/monsters/quaternius/glTF/Alien.gltf",
	#"Dino" : "res://assets/monsters/quaternius/glTF/Alien.gltf",
	#"Fish" : "res://assets/monsters/quaternius/glTF/Alien.gltf",
	#"Frog" : "res://assets/monsters/quaternius/glTF/Birb.gltf",
	#"Monkroose" : "res://assets/monsters/quaternius/glTF/Alien.gltf",
	#"MushroomKing" : "res://assets/monsters/quaternius/glTF/Alien.gltf",
	#"Ninja" : "res://assets/monsters/quaternius/glTF/Alien.gltf",
	#"Demon" : "res://assets/monsters/quaternius/glTF/Alien.gltf",
	#"Dino" : "res://assets/monsters/quaternius/glTF/Alien.gltf",
	#"Alien" : "res://assets/monsters/quaternius/glTF/Alien.gltf",
	#"Birb" : "res://assets/monsters/quaternius/glTF/Birb.gltf",
	#"BlueDemon" : "res://assets/monsters/quaternius/glTF/Alien.gltf",
	#"Bunny" : "res://assets/monsters/quaternius/glTF/Alien.gltf",
	#"Cactoro" : "res://assets/monsters/quaternius/glTF/Alien.gltf",
	#"Demon" : "res://assets/monsters/quaternius/glTF/Alien.gltf",
	#"Dino" : "res://assets/monsters/quaternius/glTF/Alien.gltf",
#}
