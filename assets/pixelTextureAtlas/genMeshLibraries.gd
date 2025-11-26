@tool
extends EditorScript

# --- Paths ---
const ATLAS_JSON_PATH = "res://assets/pixelTextureAtlas/atlas.json"
const ATLAS_TEXTURE_PATH = "res://assets/pixelTextureAtlas/atlas.png"
const SHADER_PATH = "res://assets/pixelTextureAtlas/pixelTexture.gdshader"

const FLOOR_LIB_PATH = "res://assets/pixelTextureAtlas/FloorLibrary.tres"
const WALL_LIB_PATH  = "res://assets/pixelTextureAtlas/WallLibrary.tres"

# --- Settings ---
const TILE_SIZE = 32
const ATLAS_COLS = 14.0
const ATLAS_ROWS = 9.0
const TILE_SIZE_X = 1.0
const TILE_SIZE_Y = 1.0
const TILE_SIZE_Z = 0.1  # Floor thickness
const WALL_HEIGHT = 1.0  # Wall height


# Helper: add a vertical quad
func add_quad(pos, size, rotation_y, st):
	var quad = QuadMesh.new()
	quad.size = size
	var mi = MeshInstance3D.new()
	mi.mesh = quad
	var xform = Transform3D(Basis().rotated(Vector3.UP, rotation_y), pos)
	var arr = quad.surface_get_arrays(0)
	for i in range(len(arr[Mesh.ARRAY_VERTEX])):
		var v = arr[Mesh.ARRAY_VERTEX][i]
		var uv = arr[Mesh.ARRAY_TEX_UV][i]
		v = xform * v
		st.add_vertex(v)
		st.add_uv(uv)

func create_tile_material(shader_res, atlas_tex, uv_scale, uv_offset):
	var mat = ShaderMaterial.new()
	mat.shader = shader_res
	mat.set_shader_parameter("atlas_tex", atlas_tex)
	mat.set_shader_parameter("uv_scale", uv_scale)
	mat.set_shader_parameter("uv_offset", uv_offset)
	return mat

#func build_wall_mesh():
	## Build 4 quads forming the vertical walls (no top/bottom)
	#var arr_mesh = ArrayMesh.new()
	#var st = SurfaceTool.new()
	#st.begin(Mesh.PRIMITIVE_TRIANGLES)
	#
	#
	## Four sides
	#add_quad(Vector3(0, WALL_HEIGHT/2, -0.5), Vector2(1, WALL_HEIGHT), 0, st)
	#add_quad(Vector3(0, WALL_HEIGHT/2, 0.5), Vector2(1, WALL_HEIGHT), PI, st)
	#add_quad(Vector3(-0.5, WALL_HEIGHT/2, 0), Vector2(1, WALL_HEIGHT), -PI/2, st)
	#add_quad(Vector3(0.5, WALL_HEIGHT/2, 0), Vector2(1, WALL_HEIGHT), PI/2, st)
#
	#st.generate_normals()
	#st.index()
	#arr_mesh.add_surface_from_tool(st)
	#return arr_mesh


func build_hollow_wall_mesh(width: float = 1.0, depth: float = 1.0, height: float = 1.0) -> ArrayMesh:
	var arr_mesh = ArrayMesh.new()

	# Half sizes
	var hx = width / 2.0
	var hz = depth / 2.0
	var hy = height / 2.0

	# Vertices for 4 vertical faces (front, back, left, right)
	var faces = [
		# front face (-Z)
		[ Vector3(-hx, -hy, -hz), Vector3(hx, -hy, -hz), Vector3(hx, hy, -hz), Vector3(-hx, hy, -hz) ],
		# back face (+Z)
		[ Vector3(hx, -hy, hz), Vector3(-hx, -hy, hz), Vector3(-hx, hy, hz), Vector3(hx, hy, hz) ],
		# left face (-X)
		[ Vector3(-hx, -hy, hz), Vector3(-hx, -hy, -hz), Vector3(-hx, hy, -hz), Vector3(-hx, hy, hz) ],
		# right face (+X)
		[ Vector3(hx, -hy, -hz), Vector3(hx, -hy, hz), Vector3(hx, hy, hz), Vector3(hx, hy, -hz) ],
	]

	# Indices for triangles
	var indices_faces = [
		[0,1,2, 0,2,3],  # front (-Z) flipped
		[0,1,2, 0,2,3],  # back (+Z) flipped via vertex order above
		[0,1,2, 0,2,3],  # left
		[0,1,2, 0,2,3],  # right
	]

	# UVs (same for all faces)
	var uvs = [
		Vector2(0,0), Vector2(1,0), Vector2(1,1), Vector2(0,1)
	]

	for f in range(faces.size()):
		var arr = []
		arr.resize(Mesh.ARRAY_MAX)
		arr[Mesh.ARRAY_VERTEX] = PackedVector3Array(faces[f])
		arr[Mesh.ARRAY_TEX_UV] = PackedVector2Array(uvs)
		arr[Mesh.ARRAY_INDEX] = PackedInt32Array(indices_faces[f])
		arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr)

	return arr_mesh


#
#func build_hollow_wall_mesh(width: float = 1.0, depth: float = 1.0, height: float = 1.0) -> ArrayMesh:
	#var arr_mesh = ArrayMesh.new()
#
	## Half sizes
	#var hx = width / 2.0
	#var hz = depth / 2.0
	#var hy = height / 2.0
#
	## Vertices for 4 vertical faces (front, back, left, right)
	#var faces = [
		## front face (normal pointing -Z)
		#[ Vector3(-hx, -hy, -hz), Vector3(hx, -hy, -hz), Vector3(hx, hy, -hz), Vector3(-hx, hy, -hz) ],
		## back face (normal pointing +Z) -> flip vertex order
		#[ Vector3(-hx, -hy, hz), Vector3(hx, -hy, hz), Vector3(hx, hy, hz), Vector3(-hx, hy, hz) ],
		## left face (normal pointing -X)
		#[ Vector3(-hx, -hy, hz), Vector3(-hx, -hy, -hz), Vector3(-hx, hy, -hz), Vector3(-hx, hy, hz) ],
		## right face (normal pointing +X)
		#[ Vector3(hx, -hy, -hz), Vector3(hx, -hy, hz), Vector3(hx, hy, hz), Vector3(hx, hy, -hz) ],
	#]
#
	## Flip back face winding
	#var indices_faces = [
		#[0,1,2, 0,2,3],   # front
		#[0,2,1, 0,3,2],   # back (flipped)
		#[0,1,2, 0,2,3],   # left
		#[0,1,2, 0,2,3],   # right
	#]
#
	#var uvs = [
		#Vector2(0,0), Vector2(1,0), Vector2(1,1), Vector2(0,1)
	#]
#
	#for f in range(faces.size()):
		#var arr = []
		#arr.resize(Mesh.ARRAY_MAX)
		#arr[Mesh.ARRAY_VERTEX] = PackedVector3Array(faces[f])
		#arr[Mesh.ARRAY_TEX_UV] = PackedVector2Array(uvs)
		#arr[Mesh.ARRAY_INDEX] = PackedInt32Array(indices_faces[f])
		#arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr)
#
	#return arr_mesh


#func build_hollow_wall_mesh(width: float = 1.0, depth: float = 1.0, height: float = 1.0) -> ArrayMesh:
	#var arr_mesh = ArrayMesh.new()
#
	## Half sizes
	#var hx = width / 2.0
	#var hz = depth / 2.0
	#var hy = height / 2.0
#
	## Vertices for 4 vertical faces (front, back, left, right)
	#var faces = [
		## front face
		#[ Vector3(-hx, -hy, -hz), Vector3(hx, -hy, -hz), Vector3(hx, hy, -hz), Vector3(-hx, hy, -hz) ],
		## back face
		#[ Vector3(hx, -hy, hz), Vector3(-hx, -hy, hz), Vector3(-hx, hy, hz), Vector3(hx, hy, hz) ],
		## left face
		#[ Vector3(-hx, -hy, hz), Vector3(-hx, -hy, -hz), Vector3(-hx, hy, -hz), Vector3(-hx, hy, hz) ],
		## right face
		#[ Vector3(hx, -hy, -hz), Vector3(hx, -hy, hz), Vector3(hx, hy, hz), Vector3(hx, hy, -hz) ],
	#]
#
	#var uvs = [
		#Vector2(0,0), Vector2(1,0), Vector2(1,1), Vector2(0,1)
	#]
#
	#for face in faces:
		#var arr = []
		#arr.resize(Mesh.ARRAY_MAX)
		#arr[Mesh.ARRAY_VERTEX] = PackedVector3Array(face)
		#arr[Mesh.ARRAY_TEX_UV] = PackedVector2Array(uvs)
		#arr[Mesh.ARRAY_INDEX] = PackedInt32Array([0,1,2, 0,2,3])
		#arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr)
#
	#return arr_mesh

func build_wall_mesh():
	var arr_mesh = ArrayMesh.new()
	
	var quads = [
		{ "pos": Vector3(0, WALL_HEIGHT/2, -0.5), "rot": 0 },        # front
		{ "pos": Vector3(0, WALL_HEIGHT/2, 0.5), "rot": PI },        # back
		{ "pos": Vector3(-0.5, WALL_HEIGHT/2, 0), "rot": -PI/2 },    # left
		{ "pos": Vector3(0.5, WALL_HEIGHT/2, 0), "rot": PI/2 }       # right
	]
	
	for q in quads:
		var quad = QuadMesh.new()
		quad.size = Vector2(1, WALL_HEIGHT)
		
		var arr = quad.surface_get_arrays(0)
		var xform = Transform3D(Basis().rotated(Vector3.UP, q.rot), q.pos)
		
		var new_arr = []
		for i in range(arr.size()):
			new_arr.append(arr[i])
		
		# transform vertices
		var verts = new_arr[Mesh.ARRAY_VERTEX]
		for i in range(verts.size()):
			verts[i] = xform * verts[i]
		new_arr[Mesh.ARRAY_VERTEX] = verts
		
		arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, new_arr)
	
	return arr_mesh


func _run():
	print("=== Tile Library Generation ===")

	var atlas_tex = load(ATLAS_TEXTURE_PATH)
	var shader_res = load(SHADER_PATH)
	if not atlas_tex or not shader_res:
		push_error("Failed to load atlas or shader!")
		return

	var atlas_file_text = FileAccess.get_file_as_string(ATLAS_JSON_PATH)
	var atlas_data = JSON.parse_string(atlas_file_text)
	if typeof(atlas_data) != TYPE_DICTIONARY:
		push_error("Failed to parse atlas JSON")
		return

	var floor_mesh = PlaneMesh.new()
	floor_mesh.size = Vector2(1, 1)

	var wall_mesh = build_hollow_wall_mesh() # 4 vertical quads

	var floor_lib = MeshLibrary.new()
	var wall_lib  = MeshLibrary.new()

	var floor_box = BoxShape3D.new()
	floor_box.size = Vector3(TILE_SIZE_X, TILE_SIZE_Z, TILE_SIZE_Y)

	var wall_box = BoxShape3D.new()
	wall_box.size = Vector3(TILE_SIZE_X, WALL_HEIGHT, TILE_SIZE_Y)

	for category in atlas_data.keys():
		for tile_name in atlas_data[category].keys():
			var tile_info = atlas_data[category][tile_name]

			var tile_index_x = int(tile_info.x / TILE_SIZE)
			var tile_index_y = int(tile_info.y / TILE_SIZE)

			var uv_scale  = Vector2(1.0 / ATLAS_COLS, 1.0 / ATLAS_ROWS)
			var uv_offset = Vector2(tile_index_x, tile_index_y) * uv_scale

			var tile_mat = create_tile_material(shader_res, atlas_tex, uv_scale, uv_offset)

			# FLOOR
			var f_id = floor_lib.get_last_unused_item_id()
			floor_lib.create_item(f_id)
			var floor_copy = floor_mesh.duplicate()
			floor_copy.material = tile_mat
			floor_lib.set_item_mesh(f_id, floor_copy)
			floor_lib.set_item_shapes(f_id, [floor_box])
			floor_lib.set_item_name(f_id, tile_name)

			# WALL
			var w_id = wall_lib.get_last_unused_item_id()
			wall_lib.create_item(w_id)
			var wall_copy = wall_mesh.duplicate()
			for s in range(wall_copy.get_surface_count()):
				wall_copy.surface_set_material(s, tile_mat)
			wall_lib.set_item_mesh(w_id, wall_copy)
			wall_lib.set_item_shapes(w_id, [wall_box])
			wall_lib.set_item_name(w_id, tile_name)

	if ResourceSaver.save(floor_lib, FLOOR_LIB_PATH) != OK:
		push_error("Failed to save floor library")
	if ResourceSaver.save(wall_lib, WALL_LIB_PATH) != OK:
		push_error("Failed to save wall library")

	print("=== Tile Libraries Generated ===")











#@tool
#extends EditorScript
#
## --- Paths ---
#const ATLAS_JSON_PATH = "res://assets/pixelTextureAtlas/atlas.json"
#const ATLAS_TEXTURE_PATH = "res://assets/pixelTextureAtlas/atlas.png"
#const SHADER_PATH = "res://assets/pixelTextureAtlas/pixelTexture.gdshader"
#
#const FLOOR_LIB_PATH = "res://assets/pixelTextureAtlas/FloorLibrary.tres"
#const WALL_LIB_PATH  = "res://assets/pixelTextureAtlas/WallLibrary.tres"
#
## --- Settings ---
#const TILE_SIZE = 32
#const ATLAS_COLS = 14.0
#const ATLAS_ROWS = 9.0
#const TILE_SIZE_X = 1.0
#const TILE_SIZE_Y = 1.0
#const TILE_SIZE_Z = 0.1  # Floor thickness
#const WALL_HEIGHT = 1.0  # Wall height
#
#func create_tile_material(shader_res, atlas_tex, uv_scale, uv_offset):
	#var mat = ShaderMaterial.new()
	#mat.shader = shader_res
	#mat.set_shader_parameter("atlas_tex", atlas_tex)
	#mat.set_shader_parameter("uv_scale", uv_scale)
	#mat.set_shader_parameter("uv_offset", uv_offset)
	#return mat
#
#
#func _run():
	#print("=== Tile Library Generation ===")
#
	## Load resources
	#var atlas_tex = load(ATLAS_TEXTURE_PATH)
	#var shader_res = load(SHADER_PATH)
	#if not atlas_tex or not shader_res:
		#push_error("Failed to load atlas or shader!")
		#return
#
	#var atlas_file_text = FileAccess.get_file_as_string(ATLAS_JSON_PATH)
	#var atlas_data = JSON.parse_string(atlas_file_text)
	#if typeof(atlas_data) != TYPE_DICTIONARY:
		#push_error("Failed to parse atlas JSON")
		#return
#
	## Shared meshes
	#var floor_mesh = PlaneMesh.new()
	#floor_mesh.size = Vector2(1, 1)
#
	#var wall_mesh = BoxMesh.new()
	#wall_mesh.size = Vector3(1, WALL_HEIGHT, 1)
#
	## MeshLibraries
	#var floor_lib = MeshLibrary.new()
	#var wall_lib  = MeshLibrary.new()
#
	## Collision shapes
	#var floor_box = BoxShape3D.new()
	#floor_box.size = Vector3(TILE_SIZE_X, TILE_SIZE_Z, TILE_SIZE_Y)
#
	#var wall_box = BoxShape3D.new()
	#wall_box.size = Vector3(TILE_SIZE_X, WALL_HEIGHT, TILE_SIZE_Y)
#
	## Iterate categories
	#for category in atlas_data.keys():
		#for tile_name in atlas_data[category].keys():
			#var tile_info = atlas_data[category][tile_name]
#
			## Convert pixel coords → tile indices
			#var tile_index_x = int(tile_info.x / TILE_SIZE)
			#var tile_index_y = int(tile_info.y / TILE_SIZE)
#
			#var uv_scale  = Vector2(1.0 / ATLAS_COLS, 1.0 / ATLAS_ROWS)
			#var uv_offset = Vector2(tile_index_x, tile_index_y) * uv_scale
#
			#var tile_mat = create_tile_material(shader_res, atlas_tex, uv_scale, uv_offset)
#
			## --- FLOOR ITEM ---
			#var f_id = floor_lib.get_last_unused_item_id()
			#floor_lib.create_item(f_id)
			#var floor_mesh_copy = floor_mesh.duplicate()
			#floor_mesh_copy.material = tile_mat
			#floor_lib.set_item_mesh(f_id, floor_mesh_copy)
			#floor_lib.set_item_shapes(f_id, [floor_box])
			#floor_lib.set_item_name(f_id, tile_name)
#
			## --- WALL ITEM ---
			#var w_id = wall_lib.get_last_unused_item_id()
			#wall_lib.create_item(w_id)
			#var wall_mesh_copy = wall_mesh.duplicate()
			#wall_mesh_copy.material = tile_mat
			#wall_lib.set_item_mesh(w_id, wall_mesh_copy)
			#wall_lib.set_item_shapes(w_id, [wall_box])
			#wall_lib.set_item_name(w_id, tile_name)
#
	## Save MeshLibraries
	#if ResourceSaver.save(floor_lib, FLOOR_LIB_PATH) != OK:
		#push_error("Failed to save floor library")
	#if ResourceSaver.save(wall_lib, WALL_LIB_PATH) != OK:
		#push_error("Failed to save wall library")
#
	#print("=== Tile Libraries Generated ===")
