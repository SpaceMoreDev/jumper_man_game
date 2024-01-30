extends Node

@export var swipeIsActive : bool = true
@export var hideStickOnRelease : bool = true
@export var impactSprite : Sprite2D
@export var deadZone : float = 40

var b_touching : bool = false
var Arrow : Node2D
var clickPos : Vector2 = Vector2.ZERO
var angle : float = 45
var inputDirection : Vector2 = Vector2.ZERO
var player : Player

func _ready():
	if !swipeIsActive:
		get_child(0).visible = false
	else:
		get_child(0).visible = true
	player = Global.GameManager.player
	Arrow = impactSprite.get_child(0)

func _input(event):
	if swipeIsActive:
		if event is InputEventScreenTouch and event.index == 0:
			if event.is_pressed():
				impactSprite.modulate.a = 0
				clickPos = event.position
				impactSprite.position = clickPos
			elif not event.is_pressed():
				b_touching = false
				inputDirection = Vector2.ZERO
			
		elif event is InputEventScreenDrag and event.index == 0:
			inputDirection = (event.position - clickPos)
			if inputDirection.length() > deadZone:
				b_touching = true
				var dirangle = impactSprite.global_position.angle_to(inputDirection) - 0.45
				angle = dirangle
				if inputDirection.y < -100:
					player.Jump()
				elif inputDirection.y > 100:
					player.Fall()
				
				inputDirection.x = clamp(inputDirection.x, -100, 100)
				inputDirection.y = clamp(inputDirection.y, -100, 100)
				
			else:
				b_touching = false
				inputDirection = Vector2.ZERO

func _process(delta):
	if swipeIsActive:
		player.input = inputDirection.normalized()
		if b_touching and inputDirection.length():
			if impactSprite.modulate.a < 180:
				impactSprite.modulate.a = move_toward(impactSprite.modulate.a,180.0, delta * 20)
			Arrow.global_rotation =  lerp_angle(Arrow.global_rotation, angle, delta * 10)
			var goTo = Vector2(inputDirection.x * 0.1,inputDirection.y * 0.3 )
			Arrow.position =  lerp(Arrow.position, goTo, delta * 10)
		else:
			if impactSprite.modulate.a > 0:
				impactSprite.modulate.a = move_toward(impactSprite.modulate.a,0.0, delta * 20)
			Arrow.position =  lerp(Arrow.position, Vector2.ZERO, delta * 10)
	pass
