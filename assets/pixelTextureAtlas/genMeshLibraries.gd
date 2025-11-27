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


##
###NEARLY WORKING NEEDS UV FOR TEXTURES
#func build_ramp_mesh(width: float = 1.0, depth: float = 1.0, height: float = 1.0) -> ArrayMesh:
	#var arr_mesh = ArrayMesh.new()
#
	## Half sizes
	#var hx = width / 2.0
	#var hz = depth / 2.0
	#var hy = height / 2.0
#
	## Vertices for 4 faces (back, sloped front, left triangle, right triangle)
	#var faces = [
		## back face (+Z) - same as wall back
		#[ Vector3(hx, -hy, hz), Vector3(-hx, -hy, hz), Vector3(-hx, hy, hz), Vector3(hx, hy, hz) ],
		##+y>+x
		##^   v (-y)
		##-x< x (start)
		## front sloped rectangle (-Z) - connects bottom back to top front
		#[ Vector3(-hx, -hy, -hz), Vector3(hx, -hy, -hz), Vector3(hx, hy, hz), Vector3(-hx, hy, hz) ],
		##+y>-x
		##^   v (-y)
		##+x< -x (start)
		## left triangle (-X)
		#[ Vector3(-hx, -hy, hz), Vector3(-hx, -hy, -hz), Vector3(-hx, hy, hz) ],
		##_=z / = diagonalyz | = y
		##_/|
		##^ +y+z v
		##-z < +z (start)
		## right triangle (+X)
		#[ Vector3(hx, -hy, -hz), Vector3(hx, -hy, hz), Vector3(hx, hy, hz) ],
		##_|/
	#]
#
	## Indices for triangles (each face)
	#var indices_faces = [
		#[0,1,2, 0,2,3],  # back rectangle
		#[0,1,2, 0,2,3],  # front sloped rectangle
		#[0,1,2],          # left triangle
		#[0,1,2],          # right triangle
	#]
#
	## UVs (same for all rectangle faces; triangles will reuse the first 3 UVs)
	#var uv_rect = [Vector2(0,0), Vector2(1,0), Vector2(1,1), Vector2(0,1)]
	#var uv_tri = [Vector2(0,0), Vector2(1,0), Vector2(1,1)]
#
	#for f in range(faces.size()):
		#var arr = []
		#arr.resize(Mesh.ARRAY_MAX)
		#arr[Mesh.ARRAY_VERTEX] = PackedVector3Array(faces[f])
		#if faces[f].size() == 4:
			#arr[Mesh.ARRAY_TEX_UV] = PackedVector2Array(uv_rect)
		#else:
			#arr[Mesh.ARRAY_TEX_UV] = PackedVector2Array(uv_tri)
		#arr[Mesh.ARRAY_INDEX] = PackedInt32Array(indices_faces[f])
		#arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr)
#
	#return arr_mesh

func build_convex_collision_from_mesh(mesh: ArrayMesh) -> ConvexPolygonShape3D:
	var all_points = PackedVector3Array()

	for s in mesh.get_surface_count():
		var arr = mesh.surface_get_arrays(s)
		var verts = arr[Mesh.ARRAY_VERTEX]
		all_points.append_array(verts)

	var shape = ConvexPolygonShape3D.new()
	shape.points = all_points
	return shape


func build_ramp_mesh(width: float = 1.0, depth: float = 1.0, height: float = 1.0) -> ArrayMesh:
	var arr_mesh = ArrayMesh.new()

	var hx = width / 2.0
	var hz = depth / 2.0
	var hy = height / 2.0

	# --- ORIGINAL GEOMETRY (unchanged) ---
	var faces = [
		# Back face (+Z)
		[
			Vector3(hx, -hy, hz), #br
			Vector3(-hx, -hy, hz),#-x #bl
			Vector3(-hx, hy, hz),#+y #tl
			Vector3(hx, hy, hz)#+x #tr
			#-y
		], #br,bl,tl,tr

		# Sloped front quad
		[
			Vector3(-hx, -hy, -hz), #bl
			Vector3(hx, -hy, -hz),#+x #br
			Vector3(hx, hy, hz),#+y #tr
			Vector3(-hx, hy, hz)#-x #tl
			#-y
		],#bl,br,tr,tl

		# Left triangle (-X)
		[
			Vector3(-hx, -hy, hz), #bc
			Vector3(-hx, -hy, -hz), #bf
			Vector3(-hx, hy, hz) #t
		], #bc, bf, c

		# Right triangle (+X)
		[
			Vector3(hx, -hy, -hz), #bf
			Vector3(hx, -hy, hz), #bc
			Vector3(hx, hy, hz) #t
		]
	] #bf,bc,t

	# --- TRIANGLE / QUAD INDICES (unchanged) ---
	var indices = [
		[0,1,2, 0,2,3],
		[0,1,2, 0,2,3],
		[0,1,2],
		[0,1,2]
	]

	# --- PER-FACE UVs (THIS IS THE IMPORTANT PART) ---

	# Back face UVs
	var uv_back = [
		Vector2(0,0),
		Vector2(1,0),
		Vector2(1,1),
		Vector2(0,1)
	]

	# Slope face UVs
	#var uv_slope = [
		#Vector2(0,0),
		#Vector2(1,0),
		#Vector2(1,1),
		#Vector2(0,1)
	#]
	var uv_slope = [
		Vector2(1,0),
		Vector2(0,0),
		Vector2(0,1),
		Vector2(1,1)
	]

	# Left triangle UVs
	var uv_left_tri = [
		Vector2(1,0),
		Vector2(0,0),
		Vector2(1,1)
	]

	# Right triangle UVs
	var uv_right_tri = [
		Vector2(0,0),
		Vector2(1,0),
		Vector2(1,1)
	]

	var uv_sets = [
		uv_back,
		uv_slope,
		uv_left_tri,
		uv_right_tri
	]

	# --- BUILD SURFACES ---
	for i in range(faces.size()):
		var arr = []
		arr.resize(Mesh.ARRAY_MAX)

		arr[Mesh.ARRAY_VERTEX] = PackedVector3Array(faces[i])
		arr[Mesh.ARRAY_INDEX] = PackedInt32Array(indices[i])
		arr[Mesh.ARRAY_TEX_UV] = PackedVector2Array(uv_sets[i])

		arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr)

	return arr_mesh





#
#func build_wall_mesh():
	#var arr_mesh = ArrayMesh.new()
	#
	#var quads = [
		#{ "pos": Vector3(0, WALL_HEIGHT/2, -0.5), "rot": 0 },        # front
		#{ "pos": Vector3(0, WALL_HEIGHT/2, 0.5), "rot": PI },        # back
		#{ "pos": Vector3(-0.5, WALL_HEIGHT/2, 0), "rot": -PI/2 },    # left
		#{ "pos": Vector3(0.5, WALL_HEIGHT/2, 0), "rot": PI/2 }       # right
	#]
	#
	#for q in quads:
		#var quad = QuadMesh.new()
		#quad.size = Vector2(1, WALL_HEIGHT)
		#
		#var arr = quad.surface_get_arrays(0)
		#var xform = Transform3D(Basis().rotated(Vector3.UP, q.rot), q.pos)
		#
		#var new_arr = []
		#for i in range(arr.size()):
			#new_arr.append(arr[i])
		#
		## transform vertices
		#var verts = new_arr[Mesh.ARRAY_VERTEX]
		#for i in range(verts.size()):
			#verts[i] = xform * verts[i]
		#new_arr[Mesh.ARRAY_VERTEX] = verts
		#
		#arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, new_arr)
	#
	#return arr_mesh


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
	
	var ramp_mesh = build_ramp_mesh(TILE_SIZE_X, TILE_SIZE_Y, 1.0)
	var ramp_collision = build_convex_collision_from_mesh(ramp_mesh)
	
	
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


			# --- Ramp mesh instance ---
			var ramp_copy = ramp_mesh.duplicate()
			#ramp_mesh.surface_set_material(0, tile_mat)

			for s in range(ramp_copy.get_surface_count()):
				ramp_copy.surface_set_material(s, tile_mat)

			var ramp_item_id = wall_lib.get_last_unused_item_id()
			wall_lib.create_item(ramp_item_id)
			wall_lib.set_item_mesh(ramp_item_id, ramp_copy)

			# Create collision
			#var ramp_collision = ConvexPolygonShape3D.new()
			#ramp_collision.points = ramp_mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]  # use vertices
			#wall_lib.set_item_shapes(ramp_item_id, [ramp_collision])

			
			wall_lib.set_item_shapes(ramp_item_id, [ramp_collision])


			
			
			wall_lib.set_item_name(ramp_item_id, tile_name + "_ramp")

			## Optional: preview in scene
			#var ramp_inst = MeshInstance3D.new()
			#ramp_inst.mesh = ramp_mesh
			#ramp_inst.name = tile_name + "_ramp_preview"
			#ramp_inst.material_override = tile_mat
			#ramp_inst.transform.origin = Vector3(tile_index_x, 0, tile_index_y)
			#wall_cat_node.add_child(ramp_inst)


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
