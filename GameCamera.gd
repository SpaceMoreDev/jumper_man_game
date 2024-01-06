extends Camera2D

@export var cameraSpeed : float = 5
@export var startScrollingHeight : float = -40
@export var follow : Node2D

var viewSize : Vector2 = Vector2.ZERO

func _ready():
	viewSize = get_viewport_rect().size

func _physics_process(delta):
	var distance : float = follow.position.y - position.y
	if distance > 200:
		print("Distance: %s"%[follow.position.y - position.y])
		get_tree().reload_current_scene()
		
	position.x = follow.position.x
	
	if  follow.position.y < position.y:
		position.y = follow.position.y
	else:
		if position.y < startScrollingHeight :
			position.y = lerp(position.y, position.y - cameraSpeed, delta * 5)

