extends Node
class_name PlatformSpawner

enum Biome
{
	Stone,
	Grass,
	Ice,
	Decay,
	Glass,
	Divine
}
@export var PlatformScene : PackedScene
@export var Map : Node2D

var PlatformList = []

var spawnHeight : float = -75
var manager : Manager
var cameraLocation : Vector2
var SpawnerThread : Thread = Thread.new()
var PlayerCam : Camera2D
var lastPlatformPosition : Vector2 = Vector2(109,160)
const spawnInterval = 75

func _ready() -> void:
	manager = Global.GameManager
	cameraLocation = manager.gameCamera.position
	PlayerCam = manager.gameCamera
	Spawn_Platforms()
	pass


func Spawn_Platforms():
	for i in range(10):
		var randX = RandomNumberGenerator.new()
		var pos : Vector2 = lastPlatformPosition
		
		randX.randomize()
		var random : float = randX.randf_range(30, 155)
		spawnHeight = min(spawnHeight, pos.y)
		pos = Vector2(random, pos.y - spawnInterval)
		lastPlatformPosition = pos
		var instance = PlatformScene.instantiate()
		
		instance.position = lastPlatformPosition
		Map.add_child(instance)
		
		PlatformList.append(instance)
	pass


func delete_platforms():
	if PlatformList.is_empty():
		return
	
	for platform in PlatformList:
		if platform.position.y > PlayerCam.position.y + 250:
			PlatformList.erase(platform)
			platform.queue_free()
			print("cleaned platform")
			continue
	
	pass

func _process(delta):
	var cameraThreshold = spawnHeight
	delete_platforms()
	if PlayerCam.position.y < cameraThreshold:
		Spawn_Platforms()
	
	
