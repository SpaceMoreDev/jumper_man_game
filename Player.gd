extends CharacterBody2D

@export var hideStickOnRelease : bool = true

@export var node_feetCheck : Area2D
@export var deadZone : float = 40
@export var impactSprite : Sprite2D

const SPEED = 100.0
const JUMP_VELOCITY = -400.0

var inputDirection : Vector2 = Vector2.ZERO
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var b_checkFeet : bool = false
var b_jumped : bool = false
var b_touching : bool = false
var Arrow : Node2D

var clickPos : Vector2 = Vector2.ZERO
var angle : float = 45
func _input(event):
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
			if inputDirection.y < -150:
				Jump()
			elif inputDirection.y > 150:
				Fall()
			
			inputDirection.x = clamp(inputDirection.x, -100, 100)
			inputDirection.y = clamp(inputDirection.y, -100, 100)
			
		else:
			b_touching = false
			inputDirection = Vector2.ZERO
	

func _ready():
	Arrow = impactSprite.get_child(0)
	node_feetCheck.connect("body_entered", checkFeet_enter)
	node_feetCheck.connect("body_exited", checkFeet_exit)

func Jump():
	if !b_jumped and is_on_floor():
		velocity.y = JUMP_VELOCITY
		b_jumped = true

func Fall():
	if b_checkFeet and is_on_floor():
		$CollisionShape2D.disabled = true
		await get_tree().create_timer(0.1).timeout
		$CollisionShape2D.disabled = false

func checkFeet_enter(body:Node2D):
	if body.is_in_group("Platform"):
		b_checkFeet = true

func checkFeet_exit(body:Node2D):
	if body.is_in_group("Platform"):
		b_checkFeet = false

func _process(delta):
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

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		b_jumped = false

	if Input.is_action_just_pressed("UP"):
		Jump()
	elif Input.is_action_just_pressed("DOWN"):
		Fall()

	if inputDirection.length() > deadZone:
		velocity.x = inputDirection.x * delta * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
