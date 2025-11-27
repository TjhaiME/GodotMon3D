extends GridMap

#we want something where we can place tiles with effects and have
#the game interact in various ways becuase of it (or not)
#e.g. tall grass is deteected and causes encounters
#or water /waterfalls/npcs etc
#we can put info here on what monsters should be encountered and stuff,and details for each npc.
#that way we can place it all in the level editor, like the floors and walls
#and have it all automatically work

#other things could be autotiling and autovariation, or spawning variants with effects.

 #Vector3i local_to_map(local_position: Vector3) const
#
#Returns the map coordinates of the cell containing the given local_position. If local_position is in global coordinates, consider using Node3D.to_local() before passing it to this method. See also map_to_local().
func pos_to_tileType(globalPos):
	var localPos = to_local(globalPos)
	var cellPos = local_to_map(localPos)
	var meshLib = mesh_library
	var itemID = mesh_library.get_cell_item(cellPos)
	if itemID == INVALID_CELL_ITEM:
		print("there is nothing at this spot")
		return tileTypeEnum["nothing"]
	
	var itemName = mesh_library.get_item_name(itemID)
	if ! tileTypes.has(itemName):
		return tileTypeEnum["nothing"]
	
	return tileTypes[itemName]


func check_for_encounters(globalPos):
	var tileType = pos_to_tileType(globalPos)
	if tileType == tileTypeEnum["tallGrass"]:
		pass
		##TODO: finish and add other conditions
		#now we actually do the encounter rate etc
		#or return true
	return false

#● int get_cell_item(position: Vector3i) const
#
#The MeshLibrary item index located at the given grid coordinates. If the cell is empty, INVALID_CELL_ITEM will be returned.


#● String get_item_name(id: int) const
#
#Returns the item's name.
#
#● MeshLibrarymesh_libraryset_mesh_library(value) setterget_mesh_library() getter
#
#The assigned MeshLibrary.

var tileTypeEnum = {
	"nothing" : -1,
	"flower" : 0,
	"tallGrass" : 1,
	"tree" : 2,
}

var tileTypes = {
	"cactus_short" : tileTypeEnum["tree"],
	"cactus_tall" : tileTypeEnum["tree"],
	"crops_bambooStageB" : tileTypeEnum["tree"],
	"stump_oldTall" : tileTypeEnum["tree"],
	"stump_roundDetailed" : tileTypeEnum["tree"],
	"stump_squareDetailed" : tileTypeEnum["tree"],
	"stump_squareDetailedWide" : tileTypeEnum["tree"],
	"tree_blocks" : tileTypeEnum["tree"],
	"tree_blocks_dark" : tileTypeEnum["tree"],
	"tree_cone" : tileTypeEnum["tree"],
	"tree_cone_fall" : tileTypeEnum["tree"],
	"tree_default" : tileTypeEnum["tree"],
	"tree_default_dark" : tileTypeEnum["tree"],
	"tree_detailed" : tileTypeEnum["tree"],
	"tree_detailed_dark" : tileTypeEnum["tree"],
	"tree_detailed_fall" : tileTypeEnum["tree"],
	"tree_fat" : tileTypeEnum["tree"],
	"tree_fat_darkh" : tileTypeEnum["tree"],
	"tree_fat_fall" : tileTypeEnum["tree"],
	"tree_oak" : tileTypeEnum["tree"],
	"tree_oak_dark" : tileTypeEnum["tree"],
	"tree_oak_fall" : tileTypeEnum["tree"],
	"tree_palm" : tileTypeEnum["tree"],
	"tree_palmBend" : tileTypeEnum["tree"],
	"tree_palmDetailedShort" : tileTypeEnum["tree"],
	"tree_palmDetailedTall" : tileTypeEnum["tree"],
	"tree_palmShort" : tileTypeEnum["tree"],
	"tree_palmTall" : tileTypeEnum["tree"],
	"tree_pineDefaultA" : tileTypeEnum["tree"],
	"tree_pineDefaultB" : tileTypeEnum["tree"],
	"tree_pineGroundA" : tileTypeEnum["tree"],
	"tree_pineGroundB" : tileTypeEnum["tree"],
	"tree_pineRoundA" : tileTypeEnum["tree"],
	"tree_pineRoundB" : tileTypeEnum["tree"],
	"tree_pineRoundC" : tileTypeEnum["tree"],
	"tree_pineRoundD" : tileTypeEnum["tree"],
	"tree_pineRoundE" : tileTypeEnum["tree"],
	"tree_pineRoundF" : tileTypeEnum["tree"],
	"tree_pineSmallA" : tileTypeEnum["tree"],
	"tree_pineSmallB" : tileTypeEnum["tree"],
	"tree_pineSmallC" : tileTypeEnum["tree"],
	"tree_pineSmallD" : tileTypeEnum["tree"],
	"tree_pineTallA" : tileTypeEnum["tree"],
	"tree_pineTallA_detailed" : tileTypeEnum["tree"],
	"tree_pineTallB" : tileTypeEnum["tree"],
	"tree_pineTallB_detailed" : tileTypeEnum["tree"],
	"tree_pineTallC" : tileTypeEnum["tree"],
	"tree_pineTallC_detailed" : tileTypeEnum["tree"],
	"tree_pineTallD" : tileTypeEnum["tree"],
	"tree_pineTallD_detailed" : tileTypeEnum["tree"],
	"tree_plateau" : tileTypeEnum["tree"],
	"tree_plateau_dark" : tileTypeEnum["tree"],
	"tree_plateau_fall" : tileTypeEnum["tree"],
	"tree_simple" : tileTypeEnum["tree"],
	"tree_simple_dark" : tileTypeEnum["tree"],
	"tree_simple_fall" : tileTypeEnum["tree"],
	"tree_small" : tileTypeEnum["tree"],
	"tree_small_fall" : tileTypeEnum["tree"],
	"tree_tall" : tileTypeEnum["tree"],
	"tree_tall_dark" : tileTypeEnum["tree"],
	"tree_tall_fall" : tileTypeEnum["tree"],
	"tree_thin" : tileTypeEnum["tree"],
	"tree_thin_fall" : tileTypeEnum["tree"],
	
	
	
	"flower_purpleB" : tileTypeEnum["flower"],
	"flower_redA" : tileTypeEnum["flower"],
	"flower_yellowC" : tileTypeEnum["flower"],
	"mushroom_red" : tileTypeEnum["flower"],
	"mushroom_redGroup" : tileTypeEnum["flower"],
	"mushroom_tanGroup" : tileTypeEnum["flower"],
	"mushroom_tanTall" : tileTypeEnum["flower"],
	#"lily_large" : tileTypeEnum["tallGrass"],
	#"lily_small" : tileTypeEnum["tallGrass"],
	
	
	
	"grass" : tileTypeEnum["tallGrass"],
	"Grass_Common_Short" : tileTypeEnum["tallGrass"],
	"Grass_Common_Tall" : tileTypeEnum["tallGrass"],
	"grass_large" : tileTypeEnum["tallGrass"],
	"grass_leafs" : tileTypeEnum["tallGrass"],
	"grass_leafsLarge" : tileTypeEnum["tallGrass"],
	"Grass_Wispy_Short" : tileTypeEnum["tallGrass"],
	"Grass_Wispy_Tall" : tileTypeEnum["tallGrass"],


	"Plant_1" : tileTypeEnum["tallGrass"],
	"Plant_2" : tileTypeEnum["tallGrass"],
	"plant_bush" : tileTypeEnum["tallGrass"],
	"plant_bushDetailed" : tileTypeEnum["tallGrass"],
	"plant_bushLarge" : tileTypeEnum["tallGrass"],
	"plant_bushLargeTriangle" : tileTypeEnum["tallGrass"],
	"plant_bushSmall" : tileTypeEnum["tallGrass"],
	"plant_bushTriangle" : tileTypeEnum["tallGrass"],
	"plant_flatShort" : tileTypeEnum["tallGrass"],
	"plant_flatTall" : tileTypeEnum["tallGrass"],
	"Plant_Flowers" : tileTypeEnum["tallGrass"],
}
