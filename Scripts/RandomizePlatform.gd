extends Node2D
class_name Platform

enum PlatformType
{
	Bricks,
	Grass,
	Slime
}

@export var platformTiles : TileMapLayer

var type : PlatformType = PlatformType.Bricks;
var platformWidth : float 
var platformGenerationThread : Thread = Thread.new()

func _ready() -> void:
	#randomize platform type
	#get size of plat and place horizontally and place randomly
	platformGenerationThread.start(draw_pattern)
	pass

func EraseTilemap(tilemap : TileMapLayer):
	for i in tilemap.get_used_cells():
			tilemap.erase_cell(i)

func draw_pattern():
	EraseTilemap(platformTiles)
	
	var minXvalue : int = 0
	var maxXvalue : int = 12
	
	var patternIndex = randi_range(0, platformTiles.tile_set.get_patterns_count() - 1)
	var pattern : TileMapPattern = platformTiles.tile_set.get_pattern(patternIndex)
	var tilePosition = Vector2.ZERO
	var patternSize : Vector2 = pattern.get_size()
	
	for cell in pattern.get_used_cells():
		var coord = pattern.get_cell_atlas_coords(cell)
		var pos = Vector2i(tilePosition.x + cell.x, tilePosition.y + cell.y)
		if patternSize.y > 1:
			pos.y-=1 
		platformTiles.set_cell(pos, 0, coord)
