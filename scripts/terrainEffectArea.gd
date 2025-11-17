#extends Area3D
#
#
#@export var radius: float = 5.0
#@export var height: float = 20.0
#@export var terrain_mask: int = 9
#@export var effect_color: Color = Color(0.2, 0.6, 1.0)
#
#func _ready():
	#var shape = CylinderShape3D.new()
	#shape.height = height
	#shape.radius = radius
	#$CollisionShape3D.shape = shape
#
	#$MeshInstance3D.scale = Vector3(radius, 1, radius)
#
#
#func _on_area_entered(body):
	#if body.is_in_group("monsters"):
		#body.enter_terrain_effect(self)
#
#func _on_area_exited(body):
	#if body.is_in_group("monsters"):
		#body.exit_terrain_effect(self)


#
#func _ready():
	#height_scale = central.height_scale
	#heightmap = central.heightmap_texture
	## Setup collision
	#if not $CollisionShape3D.shape:
		#$CollisionShape3D.shape = CylinderShape3D.new()
	#_set_radius(radius)
	#_set_height(height)
#
	## Setup mesh
	#if not $MeshInstance3D.mesh:
		#var plane = PlaneMesh.new()
		#plane.size = Vector2(2.0, 2.0)  # We'll scale it ourselves
		#$MeshInstance3D.mesh = plane
#
	#$MeshInstance3D.scale = Vector3(radius, 1, radius)
	#$MeshInstance3D.position = Vector3(0, 0.05, 0)  # slightly above ground
#
	## Create and apply shader material
	#var mat := ShaderMaterial.new()
	#mat.shader = preload("res://scripts/terrainEffectBase.gdshader")
	#mat.set_shader_parameter("effect_color", color)
	#mat.set_shader_parameter("opacity", opacity)
	#mat.set_shader_parameter("world_radius", radius)
	#mat.set_shader_parameter("height_scale", height_scale)
	#if heightmap:
		#mat.set_shader_parameter("heightmap", heightmap)
	#$MeshInstance3D.material_override = mat
#
	## Connect signals
	#connect("body_entered", Callable(self, "_on_body_entered"))
	#connect("body_exited", Callable(self, "_on_body_exited"))

####################################################################################################
#
#@tool
##@icon("res://icon_area.png")
#
#extends Area3D
#
#@export var radius: float = 5.0 : set = _set_radius
#@export var height: float = 20.0 : set = _set_height
#@export var color: Color = Color(0.2, 0.6, 1.0)
#@export var opacity: float = 0.5
#var height_scale: float = 5.0
#var heightmap: Texture2D
#
## Optional group filters
#@export var monster_group: String = "monsters"
#
#
#
## call this after you set height_scale and heightmap from central
#func _setup_visual_material():
	#var mat := ShaderMaterial.new()
	#mat.shader = preload("res://scripts/terrainEffectBase.gdshader")
	#mat.set_shader_parameter("effect_color", color)
	#mat.set_shader_parameter("opacity", opacity)
	#mat.set_shader_parameter("height_scale", height_scale)
	#mat.set_shader_parameter("heightmap", heightmap)
	## compute and set heightmap world origin and world size
	## assumes central has size_x, size_z, cell_size and that mesh in terrain was centered using (x - 0.5*(size_x-1))*cell_size
	#var size_x = central.size_x
	#var size_z = central.size_z
	#var cell = central.cell_size
#
	#var world_size_x = float(size_x - 1) * cell
	#var world_size_z = float(size_z - 1) * cell
	#var terrain_global_pos = central.terrain_global_pos
	#print("cell_size = ", cell)
	#print("terrain global pos = ", terrain_global_pos)
#
	## compute world position of heightmap pixel (0,0) — top-left depending on your conventions
	## earlier we centered the mesh at terrain origin, so pixel (0,0) world offset is:
	#var origin_offset_x = -0.5 * float(size_x - 1) * cell
	#var origin_offset_z = -0.5 * float(size_z - 1) * cell
	#var heightmap_origin_world = Vector2(terrain_global_pos.x + origin_offset_x,
										 #terrain_global_pos.z + origin_offset_z)
#
	#mat.set_shader_parameter("heightmap_origin_world", heightmap_origin_world)
	#mat.set_shader_parameter("heightmap_world_size", Vector2(world_size_x, world_size_z))
#
	## set effect center initially to this Area's global XZ
	#var center = Vector2(global_transform.origin.x, global_transform.origin.z)
	#mat.set_shader_parameter("effect_center_world", center)
	#mat.set_shader_parameter("world_radius", radius)
	#
	##mat.set_shader_parameter("heightmap", heightmap)
	##mat.set_shader_parameter("height_scale", height_scale)
	##mat.set_shader_parameter("heightmap_origin_world", heightmap_origin_world)
	##mat.set_shader_parameter("heightmap_world_size", Vector2(world_size_x, world_size_z))
	##mat.set_shader_parameter("effect_center_world", Vector2(global_transform.origin.x, global_transform.origin.z))
	##mat.set_shader_parameter("world_radius", radius)
#
#
	#$MeshInstance3D.material_override = mat
#
## call _setup_visual_material() after ready when central is available
#func _ready() -> void:
	#pass
#
#func after_ready():
	##print("spawned terrain effect area, AreaPos = ", global_transform.origin)
	##height_scale = central.height_scale
	##heightmap = central.heightmap_texture
	##if not $CollisionShape3D.shape:
		##$CollisionShape3D.shape = CylinderShape3D.new()
	##_set_radius(radius)
	##_set_height(height)
##
	##_setup_visual_material()
##
	##connect("body_entered", Callable(self, "_on_body_entered"))
	##connect("body_exited", Callable(self, "_on_body_exited"))
	#
	##func _ready():
	#print("spawned terrain effect area")
	#height_scale = central.height_scale
	#heightmap = central.heightmap_texture
#
	## ensure children exist
	#if not $CollisionShape3D.shape:
		#$CollisionShape3D.shape = CylinderShape3D.new()
	#_set_radius(radius)
	#_set_height(height)
#
	#if not $MeshInstance3D.mesh:
		#var plane = PlaneMesh.new()
		#plane.size = Vector2(2.0, 2.0)
		#$MeshInstance3D.mesh = plane
#
	#$MeshInstance3D.scale = Vector3(radius, 1, radius)
	#$MeshInstance3D.position = Vector3(0, 0.05, 0)
#
	#_setup_visual_material()
#
	#connect("body_entered", Callable(self, "_on_body_entered"))
	#connect("body_exited", Callable(self, "_on_body_exited"))
#
#
## If the Area moves, update shader's effect center so the circle follows
#func _process(delta):
	#if $MeshInstance3D and $MeshInstance3D.material_override:
		#var mat = $MeshInstance3D.material_override as ShaderMaterial
		#var center = Vector2(global_transform.origin.x, global_transform.origin.z)
		#mat.set_shader_parameter("effect_center_world", center)
#
## also update radius in shader when changed
#func _set_radius(value: float) -> void:
	#radius = value
	#var shape := $CollisionShape3D.shape as CylinderShape3D
	#if shape:
		#shape.radius = radius
	#if $MeshInstance3D:
		#$MeshInstance3D.scale = Vector3(radius, 1, radius)
		#if $MeshInstance3D.material_override:
			#$MeshInstance3D.material_override.set_shader_parameter("world_radius", radius)
#
#
#
#func _set_height(value: float) -> void:
	#height = value
	#var shape := $CollisionShape3D.shape as CylinderShape3D
	#if shape:
		#shape.height = height
#
#
#func _on_body_entered(body: Node) -> void:
	#if monster_group == "" or body.is_in_group(monster_group):
		#if body.has_method("enter_terrain_effect"):
			#body.enter_terrain_effect(self)
#
#
#func _on_body_exited(body: Node) -> void:
	#if monster_group == "" or body.is_in_group(monster_group):
		#if body.has_method("exit_terrain_effect"):
			#body.exit_terrain_effect(self)

####################################################################################



extends Area3D

@export var radius: float = 5.0 : set = _set_radius
@export var height: float = 20.0 : set = _set_height
@export var color: Color = Color(0.2, 0.6, 1.0)
@export var opacity: float = 0.5

var height_scale: float = 5.0
var heightmap: Texture2D

# Optional group filters
@export var monster_group: String = "monsters"

# Cached terrain parameters (should be set from central)
var terrain_origin: Vector3
var terrain_size_x: float
var terrain_size_z: float
var cell_size: float

# ShaderMaterial reference
var effect_material: ShaderMaterial

func _ready():
	# Wait until terrain central is ready
	after_ready()


func after_ready():
	print("Spawning terrain effect area")

	# Load terrain parameters from central
	height_scale = central.height_scale
	heightmap = central.heightmap_texture
	cell_size = central.cell_size

	terrain_size_x = float(central.size_x - 1) * cell_size
	terrain_size_z = float(central.size_z - 1) * cell_size

	# Compute terrain origin in world space (top-left corner of heightmap)
	terrain_origin = central.terrain_global_pos - Vector3(terrain_size_x * 0.5, 0, terrain_size_z * 0.5)

	# Create mesh aligned to terrain
	print("creating in on ready")
	var newMesh = _create_aligned_plane(global_transform.origin, radius)
	print(newMesh.get_surface_count())  # Should be 1
	$MeshInstance3D.mesh = newMesh

	# Assign shader material
	_setup_visual_material()

	# Collision shape
	if not $CollisionShape3D.shape:
		$CollisionShape3D.shape = CylinderShape3D.new()
	_set_radius(radius)
	_set_height(height)

	# Connect Area signals
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))
	#$MeshInstance3D.scale = Vector3(1,1,1)
	#$MeshInstance3D.position = Vector3(0,0,0)
		
	$MeshInstance3D.transform = Transform3D.IDENTITY
	$MeshInstance3D.global_transform.origin = global_transform.origin

	
	print("sizes = ",central.size_x,", ", central.size_z)
	print("cell size = ", central.cell_size)
	


# --- Generate aligned plane mesh ---
func _create_aligned_plane(center: Vector3, radius: float) -> ArrayMesh:
	var vertices = []
	var uvs = []
	var indices = []

	# Determine bounds aligned to terrain grid
	var min_x = floor((center.x - radius - terrain_origin.x) / cell_size) * cell_size + terrain_origin.x
	var max_x = ceil((center.x + radius - terrain_origin.x) / cell_size) * cell_size + terrain_origin.x
	var min_z = floor((center.z - radius - terrain_origin.z) / cell_size) * cell_size + terrain_origin.z
	var max_z = ceil((center.z + radius - terrain_origin.z) / cell_size) * cell_size + terrain_origin.z

	var steps_x = int(round((max_x - min_x) / cell_size))
	var steps_z = int(round((max_z - min_z) / cell_size))

	# Build vertices and UVs
	for z in range(steps_z + 1):
		for x in range(steps_x + 1):
			var vx = min_x + x * cell_size
			var vz = min_z + z * cell_size
			#vertices.append(Vector3(vx, 0, vz))
			
			# Instead of absolute world positions:
			var vx_local = vx - global_transform.origin.x
			var vz_local = vz - global_transform.origin.z
			vertices.append(Vector3(vx_local, 0, vz_local))

			
			# UVs normalized to terrain
			uvs.append(Vector2((vx - terrain_origin.x) / terrain_size_x,
							   (vz - terrain_origin.z) / terrain_size_z))
#uvs.append(Vector2(
	#(vx - terrain_origin.x) / terrain_size_x,
	#(vz - terrain_origin.z) / terrain_size_z
#))

	# Build indices (two triangles per quad)
	for z in range(steps_z):
		for x in range(steps_x):
			var i0 = z * (steps_x + 1) + x
			var i1 = i0 + 1
			var i2 = i0 + (steps_x + 1)
			var i3 = i2 + 1
			indices.append_array([i0, i2, i1])
			indices.append_array([i1, i2, i3])

	# Create mesh
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	#arrays[Mesh.ARRAY_VERTEX] = vertices
	#arrays[Mesh.ARRAY_TEX_UV] = uvs
	#arrays[Mesh.ARRAY_INDEX] = PackedInt32Array(indices)
	var normals = []
	for v in vertices:
		normals.append(Vector3.UP)
	#arrays[Mesh.ARRAY_NORMAL] = normals
	
	# Vertices
	arrays[Mesh.ARRAY_VERTEX] = PackedVector3Array(vertices)

	# Normals
	arrays[Mesh.ARRAY_NORMAL] = PackedVector3Array(normals)

	# UVs
	arrays[Mesh.ARRAY_TEX_UV] = PackedVector2Array(uvs)

	# Indices
	arrays[Mesh.ARRAY_INDEX] = PackedInt32Array(indices)
	
	
	var mesh = ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	print("vertices.size() = ", vertices.size())
	#print("indices = ", indices)
	print("indices.size() = ", indices.size())
	print("uvs.size() = ", uvs.size())
	return mesh


# --- Setup shader material ---
func _setup_visual_material():
	effect_material = ShaderMaterial.new()
	effect_material.shader = preload("res://scripts/shaders/terrainEffectLava.gdshader")#preload("res://scripts/terrainEffectBase.gdshader")
	effect_material.set_shader_parameter("effect_color", color)
	effect_material.set_shader_parameter("opacity", opacity)
	effect_material.set_shader_parameter("height_scale", height_scale)
	effect_material.set_shader_parameter("heightmap", heightmap)

	effect_material.set_shader_parameter("heightmap_origin_world",
		Vector2(terrain_origin.x, terrain_origin.z))
	effect_material.set_shader_parameter("heightmap_world_size",
		Vector2(terrain_size_x, terrain_size_z))

	# Set initial effect center and radius
	effect_material.set_shader_parameter("effect_center_world",
		Vector2(global_transform.origin.x, global_transform.origin.z))
	effect_material.set_shader_parameter("world_radius", radius)

	$MeshInstance3D.material_override = effect_material


# --- Update shader each frame if Area moves ---
func _process(delta):
	if effect_material:
		var center = Vector2(global_transform.origin.x, global_transform.origin.z)
		effect_material.set_shader_parameter("effect_center_world", center)


# --- Radius and height setters ---
func _set_radius(value: float) -> void:
	radius = value
	var shape = $CollisionShape3D.shape as CylinderShape3D
	if shape:
		shape.radius = radius
	# Recreate mesh to match new radius
	if $MeshInstance3D:
		print("creating in set radius")
		$MeshInstance3D.mesh = _create_aligned_plane(global_transform.origin, radius)
		if effect_material:
			effect_material.set_shader_parameter("world_radius", radius)


func _set_height(value: float) -> void:
	height = value
	var shape = $CollisionShape3D.shape as CylinderShape3D
	if shape:
		shape.height = height


# --- Area enter/exit ---
func _on_body_entered(body: Node) -> void:
	if monster_group == "" or body.is_in_group(monster_group):
		if body.has_method("enter_terrain_effect"):
			body.enter_terrain_effect(self)


func _on_body_exited(body: Node) -> void:
	if monster_group == "" or body.is_in_group(monster_group):
		if body.has_method("exit_terrain_effect"):
			body.exit_terrain_effect(self)
