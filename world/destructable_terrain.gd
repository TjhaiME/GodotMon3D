
extends StaticBody3D


#also to go with this:
#was in monster attack code:
		###TODO MOVE TO AN ATTACK, THIS SUMMONS A TERRAIN EFFECT THAT MOVES WITH DESTRUCTABLE TERRAIN
		##DO NOT DELETE
		#var terrainEffectArea = load("res://world/terrainEffectArea.tscn").instantiate()
		#masterNodeRef.add_child(terrainEffectArea)##TODO fix add to proper parent
		#terrainEffectArea.global_transform.origin = global_transform.origin##DANGEROUS CAUSES ALIGNMENT ISSUES
		#terrainEffectArea.global_transform.origin.y = 0.0
		#terrainEffectArea.after_ready()





@export var size_x: int = 64
@export var size_z: int = 64
@export var cell_size: float = 1.0
@export var height_scale: float = 7.5
@export var base_color: Color = Color(0.4, 0.8, 0.4)

var heightmap: Image
var heightmap_texture: ImageTexture
var collision_shape: HeightMapShape3D

func _ready():
	_create_heightmap()
	_create_mesh()
	_create_collider()
	central.height_scale = height_scale
	central.heightmap_image = heightmap
	central.heightmap_texture = heightmap_texture
	central.size_x = size_x#central.size_x
	central.size_z = size_z#central.size_z
	central.cell_size = cell_size#central.cell_size
	
	central.terrain_global_pos = global_transform.origin#central.terrain_global_pos


func _create_heightmap():
	heightmap = Image.create(size_x, size_z, false, Image.FORMAT_RF)

	# --- Procedural noise setup ---
	var noise := FastNoiseLite.new()
	noise.seed = randi()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX  # smooth and organic
	noise.frequency = 0.05                         # smaller = larger hills
	noise.fractal_octaves = 4
	noise.fractal_gain = 0.5
	noise.fractal_lacunarity = 2.0

	 #--- Fill heightmap with noise ---
	#normal method
	for z in range(size_z):
		for x in range(size_x):
			var n = noise.get_noise_2d(float(x), float(z))
			# FastNoiseLite returns -1..1, remap to 0..1
			var h = (n * 0.5) + 0.5
			heightmap.set_pixel(x, z, Color(h, 0, 0))
			
	
	###TODO change back
	#testing method
	#for z in range(size_z):
		#for x in range(size_x):
			#heightmap.set_pixel(x, z, Color(float(x)/float(size_x), 0, 0))
			##heightmap.set_pixel(x, z, Color(float(x+z)/float(size_x+size_z), 0, 0))

	# Create texture
	heightmap_texture = ImageTexture.create_from_image(heightmap)


# -----------------------
# Mesh creation using arrays
# -----------------------
func _create_mesh():
	var vertices := PackedVector3Array()
	var uvs := PackedVector2Array()
	var indices := PackedInt32Array()

	# build grid vertices and uvs (size_x * size_z)
	for z in range(size_z):
		for x in range(size_x):
	#for x in range(size_x):
		#for z in range(size_z):
			#var vx = float(x) * cell_size
			#var vz = float(z) * cell_size
			#Needs to be offset
			var vx = (float(x) - 0.5*(size_x - 1.0)) * cell_size# + cell_size
			var vz = (float(z) - 0.5*(size_z - 1.0)) * cell_size# + cell_size
			
			#seems to fit better when adjusted with cell_size, 0.5*cell_size)
			
			
			# initial y = 0, shader will displace using heightmap
			vertices.append(Vector3(vx, 0.0, vz))
			#method 1:
			#uvs.append(Vector2(float(x) / float(size_x - 1), float(z) / float(size_z - 1)))
			#method 2:
			var uv_x = (float(x) + 0.5) / float(size_x)
			var uv_z = (float(z) + 0.5) / float(size_z)
			uvs.append(Vector2(uv_x, uv_z))


	# build indices for triangles (two triangles per quad)
	for z in range(size_z-1):
		for x in range(size_x-1):
	#for x in range(size_x-1):
		#for z in range(size_z-1):
			var i0 = z * size_x + x
			var i1 = i0 + 1
			var i2 = i0 + size_x
			var i3 = i2 + 1

			# triangle 1 (i0, i1, i2)
			indices.append(i0)
			indices.append(i1)
			indices.append(i2)

			# triangle 2 (i1, i3, i2)
			indices.append(i1)
			indices.append(i3)
			indices.append(i2)

	# compute normals per-vertex from triangles (average face normals)
	var normals := PackedVector3Array()
	normals.resize(vertices.size())
	for i in range(normals.size()):
		normals[i] = Vector3.ZERO

	for tri_i in range(0, indices.size(), 3):
		var a_i = indices[tri_i + 0]
		var b_i = indices[tri_i + 1]
		var c_i = indices[tri_i + 2]
		var a = vertices[a_i]
		var b = vertices[b_i]
		var c = vertices[c_i]
		var face_normal = (b - a).cross(c - a).normalized()
		normals[a_i] += face_normal
		normals[b_i] += face_normal
		normals[c_i] += face_normal

	for i in range(normals.size()):
		normals[i] = normals[i].normalized()

	# prepare arrays per Godot Mesh API
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_INDEX] = indices

	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)

	# attach shader material and heightmap texture
	var mat := ShaderMaterial.new()
	mat.shader = preload("res://scripts/shaders/terrain_shader_colour.gdshader")
	mat.set_shader_parameter("heightmap", heightmap_texture)
	mat.set_shader_parameter("height_scale", height_scale)
	#mat.set_shader_parameter("color", base_color)
	var terrainColours = {
		"grass" : Vector3(0.3, 0.7, 0.3),
		"dirt" : Vector3(0.5, 0.35, 0.2),
		"stone" : Vector3(0.4, 0.4, 0.5),
		"darkStone" : Vector3(0.2,0.2,0.4),
		
		"lightSand" : (1.0/255.0)*Vector3(246.0,237.0,210.0),
		"midSand" : (1.0/255.0)*Vector3(229.0,200.0,163.0),
		"darkSand" : (1.0/255.0)*Vector3(201.0,172.0,135.0),
		
		"snow" : Vector3(0.99,0.99,1.0),
		"lightIce" : (1.0/255.0)*Vector3(227.0,253.0,255.0),
		"midIce" : (1.0/255.0)*Vector3(192.0,247.0,255.0),
		"blueIce" : (1.0/255.0)*Vector3(148.0,247.0,255.0) ,
		
		"red" : Vector3(0.8,0.1,0.2),
		"yellow" : Vector3(0.9, 0.9, 0.2),
		
	}
	
	var shaderTerrain = ["darkStone", "dirt", "grass", "stone"] #for grass levels
	#var shaderTerrain = ["darkSand", "midSand", "lightSand"] #for desert levels
	#var shaderTerrain = ["blueIce", "midIce", "snow"] #for snow levels
	
	#var shaderTerrain = ["red", "yellow", "snow"] #for grass levels #weird
	
	mat.set_shader_parameter("color_bottom", terrainColours[shaderTerrain[0]])
	mat.set_shader_parameter("color_mid", terrainColours[shaderTerrain[1]])
	mat.set_shader_parameter("color_top", terrainColours[shaderTerrain[2]])
	mat.set_shader_parameter("slope_color", terrainColours[shaderTerrain[3]])
	
	var noise_tex := NoiseTexture2D.new()
	noise_tex.noise = FastNoiseLite.new()
	noise_tex.width = 256
	noise_tex.height = 256
	noise_tex.seamless = true
	noise_tex.noise.frequency = 0.01 #0.02 is cool
	noise_tex.noise.fractal_octaves = 3
	noise_tex.noise.fractal_lacunarity = 2.0
	mat.set_shader_parameter("detail_tex", noise_tex)

	
	mesh.surface_set_material(0, mat)

	$MeshInstance3D.mesh = mesh
	# center mesh origin so coordinates are nicer (optional)
	# you can translate the MeshInstance3D or this Node to place field properly


# -----------------------
# Collider using HeightMapShape3D
# -----------------------
func _create_collider():
	collision_shape = HeightMapShape3D.new()
	_update_collider() # fills map_data, width/depth, cell_size
	$CollisionShape3D.shape = collision_shape
	#CollisionShape3D.set_collision_layer_value(5, true)
	var floorLayer = 9
	set_collision_layer_value(floorLayer, true)
	set_collision_mask_value(floorLayer, true)
	set_collision_layer_value(1, false) #needs to be done explicitly it seems
	set_collision_mask_value(1, false)


func _update_collider():
	print("Top-left:", (heightmap.get_pixel(0, 0).r - 0.5) * height_scale)
	print("Bottom-right:", (heightmap.get_pixel(size_x - 1, size_z - 1).r - 0.5) * height_scale)
	print("Top-right:", (heightmap.get_pixel(size_x - 1, 0).r - 0.5) * height_scale)
	print("Bottom-left:", (heightmap.get_pixel(0, size_z - 1).r - 0.5) * height_scale)
	
	print("first 3 x = ", [(heightmap.get_pixel(0, 0).r - 0.5) * height_scale, (heightmap.get_pixel(1, 0).r - 0.5) * height_scale, (heightmap.get_pixel(2, 0).r - 0.5) * height_scale])
	print("last 3 x = ", [(heightmap.get_pixel(size_x - 1, 0).r - 0.5) * height_scale, (heightmap.get_pixel(size_x - 2, 0).r - 0.5) * height_scale, (heightmap.get_pixel(size_x - 3, 0).r - 0.5) * height_scale])
	print("first 3 z = ", [(heightmap.get_pixel(0, 0).r - 0.5) * height_scale, (heightmap.get_pixel(0, 1).r - 0.5) * height_scale, (heightmap.get_pixel(0, 2).r - 0.5) * height_scale])
	print("///////////////////////////////////////////////////////////////////")
	var map_data := PackedFloat32Array()
	map_data.resize(size_x * size_z)

	# ✅ Flip only X
	for z in range(size_z):
		for x in range(size_x):
	#for x in range(size_x):
		#for z in range(size_z):
			var h = heightmap.get_pixel(x, z).r#
			var world_h = (h - 0.5) * height_scale
			map_data[z * size_x + x] = world_h
			#map_data[x * size_z + z] = world_h




	collision_shape.map_width = size_x
	collision_shape.map_depth = size_z
	#map_data.reverse()
	collision_shape.map_data = map_data

	$CollisionShape3D.scale = Vector3(cell_size, 1.0, cell_size)

	print("Collider height first:", map_data[0])
	print("Collider height last:", map_data[map_data.size() - 1])
	print("first 3 = ", [map_data[0], map_data[1], map_data[2]])
	print("last 3 first row = ", [map_data[size_x-1], map_data[size_x-2], map_data[size_x-3]])
	print("first 3 vertically = ", [map_data[0], map_data[size_x], map_data[2*size_x]])
	
	print("meshPos = ", $MeshInstance3D.global_transform.origin, ", colPos = ", $CollisionShape3D.global_transform.origin)


# -----------------------
# Runtime deformation (crater)
# -----------------------
func apply_crater(world_pos: Vector3, radius_m: float, depth_m: float):
	# Convert world position to local terrain coordinates
	var local = to_local(world_pos)

	# Convert local.x,z to grid indexes, accounting for centered mesh:
	# Vertex x world position = (i - 0.5*(size_x-1)) * cell_size
	var half_x = 0.5 * float(size_x - 1)
	var half_z = 0.5 * float(size_z - 1)
	var gx = (local.x / cell_size) + half_x
	var gz = (local.z / cell_size) + half_z
	var center = Vector2(gx, gz)

	var radius_in_cells = radius_m / cell_size

	# guard
	if center.x < -1.0 or center.y < -1.0 or center.x > size_x or center.y > size_z:
		return

	# Paint crater using smooth falloff (cosine falloff)
	for z in range(size_z):
		for x in range(size_x):
			var pos = Vector2(x, z)
			var dist = pos.distance_to(center)
			if dist <= radius_in_cells:
				var t = dist / radius_in_cells
				# smooth falloff:  (1 - t^2) or cosine
				var falloff = 0.5 * (cos(t * PI) + 1.0)  # smooth cosine from 1->0
				var cur = heightmap.get_pixel(x, z).r
				# convert depth_m -> [0..1] texture delta consistent with shader: world = (h - 0.5)*height_scale
				var delta = (depth_m / height_scale) * falloff
				var new_val = clamp(cur - delta, 0.0, 1.0)
				heightmap.set_pixel(x, z, Color(new_val, 0, 0))

	# update GPU texture and rebuild collider (debounce if necessary)
	heightmap_texture.update(heightmap)
	_update_collider()


# -----------------------
# Element color helper
# -----------------------
func set_element_color(c: Color):
	var mat = $MeshInstance3D.mesh.surface_get_material(0)
	if mat and mat is ShaderMaterial:
		mat.set_shader_parameter("element_tint", c)
