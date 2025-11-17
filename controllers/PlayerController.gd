# controllers/PlayerController.gd
extends Node

class_name PlayerController

@export var player_id: int = 1
@export var input_provider_scene: PackedScene
@export var viewport_scene: PackedScene # small scene that contains a SubViewport/Camera/UI

var input_provider = null
var viewport_instance = null

# The currently controlled entity for this player (CharacterBody3D, Monster node, Attack, etc.)
var current_controller = null
var previous_controller = null

func _ready():
	# instantiate input provider and viewport (optional)
	if input_provider_scene:
		input_provider = input_provider_scene.instantiate()
		# Allow the provider to know the player id / prefix
		if input_provider.has_method("set_player_prefix"):
			input_provider.set_player_prefix("p%d_" % player_id)
		add_child(input_provider) # keep it in the tree so it can be freed easily

	if viewport_scene:
		viewport_instance = viewport_scene.instantiate()
		# You should position the viewport in the UI arrangement under your main scene
		add_child(viewport_instance)

#func set_control(new_controller):
	#if current_controller:
		#current_controller.is_controlled = false
	#previous_controller = current_controller
	#current_controller = new_controller
	#if current_controller:
		#current_controller.is_controlled = true
		#if current_controller.has_method("on_set_control"):
			#current_controller.on_set_control()

func handle_frame(delta: float):
	# Called by Manager per-player each physics frame. Routes input -> current controller.
	if not current_controller or not input_provider:
		return
	var input_data = input_provider.get_input_data()
	current_controller.handle_input(delta, input_data)
