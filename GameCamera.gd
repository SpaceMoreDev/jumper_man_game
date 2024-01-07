extends Camera2D

class_name GameCamera

@export var cameraSpeed : float = 5
@export var startScrollingHeight : float = -40
@export var follow : Node2D
var manager:Manager

var viewSize : Vector2 = Vector2.ZERO

func _ready():
	manager = Global.GameManager
	viewSize = get_viewport_rect().size

func _physics_process(delta):
	var distance : float = follow.position.y - position.y
	if distance > 170:
		get_tree().reload_current_scene()
	position.x = follow.position.x
	
	if  follow.position.y < position.y:
		position.y = follow.position.y
	else:
		if position.y < startScrollingHeight :
			if not manager.started:
				manager.started = true
			position.y = lerp(position.y, position.y - cameraSpeed, delta * 5)

