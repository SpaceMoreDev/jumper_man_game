extends Node
class_name LevelGeneration

@export var f_coinScene : Array[PackedScene]
@export var player : Player
#@export var WallTiles : TileMapLayer
@export var platformTiles : TileMapLayer

#var WallGenerationThread : Thread = Thread.new()
var PlatformGenerationThread : Thread = Thread.new()
var CoinSpawnThread : Thread = Thread.new() # optional, not yet used

var spawnHeight : float = -180
var manager : Manager
var cameraLocation : Vector2
const spawnInterval = 75

var lastPatternIndex : float = -1
var lastPlatformPosition : Vector2 = Vector2(109,110)
var lastWallPosition : Vector2i = Vector2i(-3,-60)

var threadData : Array

var pendingWallData : Array = []
var pendingPlatformData : Array = []
var PlayerCam : Camera2D
var generationCooldown = .1
var timeSinceLastGen = 0.0

func _ready():
	manager = Global.GameManager
	cameraLocation = manager.gameCamera.position
	PlayerCam = manager.gameCamera
	threadData = [
		lastWallPosition,
		spawnHeight,
		lastPlatformPosition,
		lastPatternIndex,
		cameraLocation
	]
	
	PlatformGenerationThread.start(_generate_platforms_thread)
	
	await get_tree().create_timer(0.05).timeout
	if PlatformGenerationThread.is_started():
		PlatformGenerationThread.wait_to_finish()
	if pendingPlatformData.size() > 0:
		_apply_platform_data(pendingPlatformData)
		pendingPlatformData.clear()


func _process(delta):
	timeSinceLastGen += delta
	var cameraThreshold = threadData[1]
	
	if PlayerCam.position.y < cameraThreshold:
		timeSinceLastGen = 0.0
		
		#if not WallGenerationThread.is_started():
			#WallGenerationThread.start(_generate_wall_thread)
		#else:
			#WallGenerationThread.wait_to_finish()
		#
		
		if not PlatformGenerationThread.is_started():
			PlatformGenerationThread.start(_generate_platforms_thread)
		else:
			PlatformGenerationThread.wait_to_finish()
		
	#if pendingWallData.size() > 0:
		#_apply_wall_data(pendingWallData)
		#pendingWallData.clear()
	
	if pendingPlatformData.size() > 0:
		_apply_platform_data(pendingPlatformData)
		pendingPlatformData.clear()

# ------------------
# THREAD TASKS ONLY COMPUTE TILE POSITIONS, NO SCENE ACCESS
# ------------------

#func _generate_wall_thread():
	#var wallPattern = WallTiles.tile_set.get_pattern(0)
	#var tilePosition : Vector2i = threadData[0]
	#var result : Array = []
#
	#for cell in wallPattern.get_used_cells():
		#var coord = wallPattern.get_cell_atlas_coords(cell)
		#var pos = Vector2i(tilePosition.x + cell.x, tilePosition.y + cell.y)
		#result.append({ "position": pos, "coord": coord })
#
	#print("done ", result.size())
	#threadData[0].y -= wallPattern.get_size().y
	#pendingWallData = result

func _generate_platforms_thread():
	var randX = RandomNumberGenerator.new()
	var pos : Vector2 = threadData[2]
	var result : Array = []

	for i in range(10):
		var patternIndex = randi_range(0, platformTiles.tile_set.get_patterns_count() - 1)
		while threadData[3] == patternIndex:
			patternIndex = randi_range(0, platformTiles.tile_set.get_patterns_count() - 1)
		threadData[3] = patternIndex

		var pattern : TileMapPattern = platformTiles.tile_set.get_pattern(patternIndex)
		var tilePosition = platformTiles.local_to_map(pos)
		var patternSize : Vector2 = pattern.get_size()

		while (tilePosition.x + patternSize.x) > 12:
			tilePosition.x -= 1
		while tilePosition.x < 0:
			tilePosition.x += 1

		for cell in pattern.get_used_cells():
			var coord = pattern.get_cell_atlas_coords(cell)
			var tilePos = Vector2i(tilePosition.x + cell.x, tilePosition.y + cell.y)
			if patternSize.y > 1:
				tilePos.y -= 1
			result.append({ "position": tilePos, "coord": coord })

		randX.randomize()
		var random : float = randX.randf_range(0, 205)
		threadData[1] = min(threadData[1], pos.y)
		pos = Vector2(random, pos.y - spawnInterval)
		threadData[2] = pos

	
	pendingPlatformData = result


# ------------------
# SAFE SCENE MODIFICATIONS (DEFERRED)
# ------------------

#func _apply_wall_data(data : Array):
	#EraseTilemap(WallTiles)
	#for item in data:
		#WallTiles.set_cell(item["position"], 0, item["coord"])

func _apply_platform_data(data : Array):
	EraseTilemap(platformTiles)
	for item in data:
		platformTiles.set_cell(item["position"], 0, item["coord"])

func EraseTilemap(tilemap : TileMapLayer, layer : int = 0):
	var cam_y = PlayerCam.position.y
	for i in tilemap.get_used_cells():
		if tilemap.map_to_local(i).y < cam_y - 400:
			tilemap.erase_cell(i)
