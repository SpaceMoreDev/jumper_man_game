extends Node
class_name Manager

@export var UI_ScoreParticle : CPUParticles2D
@export var UI_Score: RichTextLabel

signal newScore

var player : Player:
	get:
		return _get_player()

func _get_player() -> Player :
	var player = get_tree().get_first_node_in_group("Player")
	return player

var scale : float = 1
var b_animate: bool = true
var reverse:bool = false
var UI_smoothTime = 5.0

func _ready():
	newScore.connect(_scoreEffect)

func _scoreEffect(size : float, smoothing: float):
	UI_smoothTime = 5 * smoothing
	UI_Score.scale = Vector2.ONE
	scale = size
	reverse = false
	b_animate = true

func _process(delta):
	if b_animate:
		
		if reverse:
			UI_Score.scale.x = move_toward(UI_Score.scale.x, 1, delta * UI_smoothTime)
			UI_Score.scale.y = move_toward(UI_Score.scale.y, 1, delta * UI_smoothTime)
			if UI_Score.scale == Vector2.ONE:
				b_animate = false
				print(UI_Score.scale)
		else:
			UI_Score.scale.x = move_toward(UI_Score.scale.x, scale, delta * UI_smoothTime)
			UI_Score.scale.y = move_toward(UI_Score.scale.y, scale, delta * UI_smoothTime)
		
		if UI_Score.scale == Vector2(scale, scale):
			reverse = true
		elif UI_Score.scale == Vector2.ONE:
			reverse = false
			
