extends Node

@export var platformTiles : TileMap
@export var WallTiles : TileMap
@export var coinsNode : Node
@onready var f_coinScene =  preload("res://Assets/Scenes/coin.tscn")

var generationThread : Thread = Thread.new()
const spawnInterval = 75

var player : Player
var manager : Manager
var camera : Vector2
var spawnHeight : float = 100

var lastPlatformPosition : Vector2 = Vector2(109,110) #last spawned platform
var lastWallPosition : Vector2i = Vector2i(-3,-60) #last spawned platform
var lastPatternIndex : float = -1 #last spawned platform

var threadData : Array

func _ready():
	manager = Global.GameManager
	player = manager.player
	camera = manager.gameCamera.position
	
	threadData.append(camera) # 0
	threadData.append(spawnHeight) # 1
	threadData.append(lastWallPosition) # 2
	threadData.append(lastPlatformPosition) # 3
	threadData.append(lastPatternIndex) # 4
	
	generationThread.start(Generate)

func EraseTilemap(tilemap : TileMap, layer : int = 0):
	for i in tilemap.get_used_cells(layer):
		if tilemap.map_to_local(i).y - threadData[0].y > 200:
			tilemap.erase_cell(layer,i)

func GenerateWall():
	var wallPattern : TileMapPattern = WallTiles.tile_set.get_pattern(0)
	var tilePositon = threadData[2]
	for cell in wallPattern.get_used_cells():
		var coord = wallPattern.get_cell_atlas_coords(cell)
		var pos = Vector2i(tilePositon.x + cell.x, tilePositon.y + cell.y)
		WallTiles.set_cell(0,pos, 0, coord)
	threadData[2].y -= wallPattern.get_size().y
	


func Generate():

	call_deferred("EraseTilemap",WallTiles)
	call_deferred("EraseTilemap",platformTiles)
	
	call_deferred("GenerateWall")
	
	
	var vectorToNextPlatform
	var randX =  RandomNumberGenerator.new()
	
	var pos : Vector2 = threadData[3]
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
		
		threadData[3] = pos
		call_deferred("SpawnCoins",vectorToNextPlatform, PlatformPosition)

	threadData[1] /= 10
	print("Generated!")

func SpawnCoins(vectorDir : Vector2, SpawnPosition : Vector2):
	var randomCoinsCount = RandomNumberGenerator.new()
	randomCoinsCount.randomize()
	
	var coinRange = randomCoinsCount.randi_range(2,3)
	var coinPos = SpawnPosition + vectorDir

	vectorDir = vectorDir.normalized()
	for i in range(coinRange):
		coinPos.x -= vectorDir.x * 20
		coinPos.y -= vectorDir.y * 30
		
		var coin = f_coinScene.instantiate()
		coinsNode.add_child(coin)
		coin.position = Vector2(coinPos.x,coinPos.y)

func Spawn(position) -> Vector2:
	var minXvalue : int = 0
	var maxXvalue : int = 12
	
	#print("random generation started!")
	var randomPattern = randi_range(0,platformTiles.tile_set.get_patterns_count()-1)
	while threadData[4] == randomPattern:
		randomPattern = randi_range(0,platformTiles.tile_set.get_patterns_count()-1)
	var pattern : TileMapPattern = platformTiles.tile_set.get_pattern(randomPattern)
	threadData[4] = randomPattern
	var tilePositon = platformTiles.local_to_map(position)
	#print(pattern.get_used_cells())
	var patternSize : Vector2 = pattern.get_size()
	
	while (tilePositon.x + patternSize.x) > maxXvalue:
		tilePositon.x -= 1
	
	while tilePositon.x < minXvalue: # to ensure the platforms are in the middle
		tilePositon.x += 1
	
	var lastcell = Vector2i.ZERO
	var count = pattern.get_used_cells().size()-1
	
	#var patternData = pattern.get("tile_data")
	#print(patternData)
	#platformTiles.set("tile_data", patternData)
	
	for cell in pattern.get_used_cells():
		var coord = pattern.get_cell_atlas_coords(cell)
		var pos = Vector2i(tilePositon.x + cell.x, tilePositon.y + cell.y)
		if patternSize.y > 1:
			pos.y-=1 # to keep all platforms on the same height
		platformTiles.set_cell(0,pos, 0, coord)
		lastcell = pos
	
	return platformTiles.map_to_local(tilePositon + Vector2i(patternSize.x/2,0))

func _physics_process(delta):
	if player.position.y < threadData[1]:
		generationThread.wait_to_finish()
		generationThread.start(Generate)
