extends Node
class_name Manager

@export var UI_ScoreParticle : CPUParticles2D
@export var UI_Score: RichTextLabel
@export var clockArrow: TextureRect
@export var gameCamera: GameCamera
@export var xpBar: ProgressBar

signal newScore

var player : Player:
	get:
		return _get_player()

var xpValue : float = 0:
	set(val):
		xpBar.value += val*10
		if xpBar.value >= 100.0 and val != 0:
			xpValue+=1 
			(xpBar.get_child(0) as Label).text = "x%s" % xpValue
		elif val == 0:
			xpValue = val

var started : bool = false

func _get_player() -> Player :
	var player = get_tree().get_first_node_in_group("Player")
	return player

var scale : float = 1
var b_animate: bool = true
var reverse:bool = false
var UI_smoothTime = 5.0
var initialRot : float = 0

var b_animate_clock: bool = true
var reverse_clock:bool = false
var clockOriginal_scale : Vector2 = Vector2.ONE

func _ready():
	initialRot = clockArrow.rotation_degrees
	clockOriginal_scale = clockArrow.get_parent().scale
	started = false
	newScore.connect(_scoreEffect)
	xpBar.connect("value_changed", xpBar_changed)

func xpBar_changed(value):
	if xpBar.value == 100:
		(xpBar.get_child(0) as Label).text = "x%s" % xpValue
	elif xpBar.value == 0.0:
		xpValue = 0
		(xpBar.get_child(0) as Label).text = " "

func _scoreEffect(size : float, smoothing: float):
	UI_smoothTime = 5 * smoothing
	UI_Score.scale = Vector2.ONE
	scale = size
	
	reverse = false
	b_animate = true

func clockTime(delta):
	if clockArrow.rotation_degrees > 270:
		clockArrow.rotation = deg_to_rad(-90)
		gameCamera.cameraSpeed *= 2
		clockArrow.get_parent().scale = clockOriginal_scale
		reverse_clock = false
		b_animate_clock = true
	clockArrow.rotation += delta * .5
	pass

func scoreEffect(delta):
	if b_animate:
		if reverse:
			UI_Score.scale.x = move_toward(UI_Score.scale.x, 1, delta * UI_smoothTime)
			UI_Score.scale.y = move_toward(UI_Score.scale.y, 1, delta * UI_smoothTime)
			
			if UI_Score.scale == Vector2.ONE:
				b_animate = false
		else:
			UI_Score.scale.x = move_toward(UI_Score.scale.x, scale, delta * UI_smoothTime)
			UI_Score.scale.y = move_toward(UI_Score.scale.y, scale, delta * UI_smoothTime)
			
		if UI_Score.scale == Vector2(scale, scale):
			reverse = true
		elif UI_Score.scale == Vector2.ONE:
			reverse = false

func clockEffect(delta):
	if b_animate_clock:
		if reverse_clock:
			clockArrow.get_parent().scale.x = move_toward(clockArrow.get_parent().scale.x, clockOriginal_scale.x, delta * 10)
			clockArrow.get_parent().scale.y = move_toward(clockArrow.get_parent().scale.y, clockOriginal_scale.y, delta * 10)
			
			if clockArrow.get_parent().scale == clockOriginal_scale:
				b_animate_clock = false
		else:
			clockArrow.get_parent().scale.x = move_toward(clockArrow.get_parent().scale.x, clockOriginal_scale.x + 1.5, delta * 5)
			clockArrow.get_parent().scale.y = move_toward(clockArrow.get_parent().scale.y, clockOriginal_scale.y + 1.5, delta * 5)
			
		if clockArrow.get_parent().scale == Vector2(clockOriginal_scale.x + 1.5, clockOriginal_scale.y + 1.5):
			reverse_clock = true
		elif clockArrow.get_parent().scale == clockOriginal_scale:
			reverse_clock = false

func _process(delta):
	if xpBar.value > 0:
		xpBar.value = move_toward(xpBar.value, 0.0, delta*15)
	
	if started:
		clockTime(delta)
	
	scoreEffect(delta)
	clockEffect(delta)
	
