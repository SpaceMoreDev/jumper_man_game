extends Node

@export var platformTiles : TileMap
@export var WallTiles : TileMap
@export var coinsNode : Node
@onready var f_coinScene =  preload("res://Assets/Scenes/coin.tscn")

var spawnInterval : float = 75
var player : Player

var spawnHeight : float = 100
var lastPlatformPosition : Vector2 = Vector2(109,110) #last spawned platform
var lastWallPosition : Vector2i = Vector2i(-3,-45) #last spawned platform
var lastPatternIndex : float = -1 #last spawned platform

func _ready():
	player = Global.GameManager.player
	Generate()

func Generate():
	
	var wallPattern : TileMapPattern = WallTiles.tile_set.get_pattern(0)
	var tilePositon = lastWallPosition
	for cell in wallPattern.get_used_cells():
		var coord = wallPattern.get_cell_atlas_coords(cell)
		var pos = Vector2i(tilePositon.x + cell.x, tilePositon.y + cell.y)
		#print("- %s"%pos)
		
		WallTiles.set_cell(0,pos, 1, coord)
	
	lastWallPosition.y -= 55.0
	var vectorTonextPlatform = Vector2.ZERO
	var randX =  RandomNumberGenerator.new()
	
	var pos : Vector2 = lastPlatformPosition
	var oldPos : Vector2 = Vector2.ZERO
	
	for i in range(30):
		var PlatformPosition = Spawn(pos)
		if oldPos != Vector2.ZERO:
			vectorTonextPlatform = oldPos - PlatformPosition
		
		
		randX.randomize()
		var random : float = randX.randf_range(0,205)
		#random = clamp(random, 0, 205)
		spawnHeight += pos.y
		pos = Vector2( random, pos.y - spawnInterval)
		oldPos = PlatformPosition
		lastPlatformPosition = pos
		SpawnCoins(vectorTonextPlatform.normalized(), PlatformPosition)
		

		
	spawnHeight /= 100
	print("Generated!")

func SpawnCoins(vector : Vector2, SpawnPosition : Vector2):
	var randomCoinsCount = RandomNumberGenerator.new()
	randomCoinsCount.randomize()
	var coinRange = randomCoinsCount.randi_range(1,5)
	var dir = SpawnPosition + (vector)
	var coinPos = SpawnPosition
	for i in range(coinRange):
		var coin = f_coinScene.instantiate()
		coinsNode.add_child(coin)
		coinPos = dir * i
		coin.position = coinPos

func Spawn(position) -> Vector2:
	var minXvalue : int = 0
	var maxXvalue : int = 12
	
	#print("random generation started!")
	var randomPattern = randi_range(0,platformTiles.tile_set.get_patterns_count()-1)
	while lastPatternIndex == randomPattern:
		randomPattern = randi_range(0,platformTiles.tile_set.get_patterns_count()-1)
	var pattern : TileMapPattern = platformTiles.tile_set.get_pattern(randomPattern)
	lastPatternIndex = randomPattern
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
		platformTiles.set_cell(0,pos, 0, coord)
		lastcell = pos
	
	return platformTiles.map_to_local(tilePositon + Vector2i(patternSize.x/2,0))

func _physics_process(delta):
	if player.position.y < spawnHeight:
		Generate()
