extends Node
class_name LevelGeneration

@export var f_coinScene : Array[PackedScene]
@export var player : Player
@export var WallTiles : TileMapLayer
@export var platformTiles : TileMapLayer

var WallGenerationThread : Thread = Thread.new()
var PlatformsGenerationThread : Thread = Thread.new()

var threadData : Array
var spawnHeight : float = 100
var manager : Manager
var cameraLocation : Vector2
const spawnInterval = 75

var lastPatternIndex : float = -1 #last spawned platform
var lastPlatformPosition : Vector2 = Vector2(109,110) #last spawned platform
var lastWallPosition : Vector2i = Vector2i(-3,-60) #last spawned platform

func _ready():
	manager = Global.GameManager
	cameraLocation = manager.gameCamera.position
	
	threadData.append(lastWallPosition) # 0
	threadData.append(spawnHeight)
	threadData.append(lastPlatformPosition)
	threadData.append(lastPatternIndex) # 3
	threadData.append(cameraLocation) # 4
	
	PlatformsGenerationThread.start(GeneratePlatforms)
	pass


func GenerateWall():
	call_deferred("EraseTilemap", WallTiles)
	
	var wallPattern : TileMapPattern = WallTiles.tile_set.get_pattern(0)
	var tilePositon = threadData[0]
	
	for cell in wallPattern.get_used_cells():
		var coord = wallPattern.get_cell_atlas_coords(cell)
		var pos = Vector2i(tilePositon.x + cell.x, tilePositon.y + cell.y)
		WallTiles.set_cell(pos, 0, coord)
	threadData[0].y -= wallPattern.get_size().y

func GeneratePlatforms():
	call_deferred("EraseTilemap", platformTiles)
	
	var vectorToNextPlatform
	var randX =  RandomNumberGenerator.new()
	
	var pos : Vector2 = threadData[2]
	var PlatformPosition : Vector2 = Vector2(100,165)
	var coinsLocations : Array
	for i in range(10):
		vectorToNextPlatform = PlatformPosition
		PlatformPosition = Spawn(pos)
		vectorToNextPlatform -=  PlatformPosition 
		
		randX.randomize()
		var random : float = randX.randf_range(0,205)
		
		threadData[1] += pos.y
		pos = Vector2( random, pos.y - spawnInterval)
		
		threadData[2] = pos
		
	threadData[1] /= 10

func Spawn(position) -> Vector2:
	var minXvalue : int = 0
	var maxXvalue : int = 12
	
	#print("random generation started!")
	var randomPattern = randi_range(0,platformTiles.tile_set.get_patterns_count()-1)
	while threadData[3] == randomPattern:
		randomPattern = randi_range(0,platformTiles.tile_set.get_patterns_count()-1)
	var pattern : TileMapPattern = platformTiles.tile_set.get_pattern(randomPattern)
	threadData[3] = randomPattern
	var tilePositon = platformTiles.local_to_map(position)
	#print(pattern.get_used_cells())
	var patternSize : Vector2 = pattern.get_size()
	
	while (tilePositon.x + patternSize.x) > maxXvalue:
		tilePositon.x -= 1
	
	while tilePositon.x < minXvalue: # to ensure the platforms are in the middle
		tilePositon.x += 1
	
	var lastcell = Vector2i.ZERO
	var count = pattern.get_used_cells().size()-1
	
	for cell in pattern.get_used_cells():
		var coord = pattern.get_cell_atlas_coords(cell)
		var pos = Vector2i(tilePositon.x + cell.x, tilePositon.y + cell.y)
		if patternSize.y > 1:
			pos.y-=1 # to keep all platforms on the same height
		platformTiles.set_cell(pos, 0, coord)
		lastcell = pos
	
	return platformTiles.map_to_local(tilePositon + Vector2i(patternSize.x/2,0))

func EraseTilemap(tilemap : TileMapLayer, layer : int = 0):
	for i in tilemap.get_used_cells():
		if tilemap.map_to_local(i).y - threadData[0].y > 200:
			tilemap.erase_cell(i)


func _process(delta):
	if player.position.y < threadData[1]:
		if WallGenerationThread.is_started():
			WallGenerationThread.wait_to_finish()
		
		WallGenerationThread.start(GenerateWall)
		
		if PlatformsGenerationThread.is_started():
			PlatformsGenerationThread.wait_to_finish()
		
		PlatformsGenerationThread.start(GeneratePlatforms)
