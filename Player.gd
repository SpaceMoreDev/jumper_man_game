extends CharacterBody2D
class_name Player 

@export var node_feetCheck : Area2D
@export var node_feetPaticles : CPUParticles2D
@export var areaBody : Area2D

const SPEED = 400.0
const JUMP_VELOCITY = -400.0
const JUMP_BOOST = -200

var boost : float = 0
var input : Vector2 = Vector2.ZERO
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var b_checkFeet : bool = false
var b_jumped : bool = false


func _ready():
	node_feetCheck.connect("body_entered", checkFeet_enter)
	node_feetCheck.connect("body_exited", checkFeet_exit)
	areaBody.connect("body_entered", checkArea)

func Jump():
	node_feetPaticles.emitting = false
	if !b_jumped and is_on_floor():
		if velocity.length() > 300.0:
			print("speed: %s"%velocity.length())
			boost += JUMP_BOOST
		else :
			boost = 0
		velocity.y = JUMP_VELOCITY + boost
		b_jumped = true

func Fall():
	if b_checkFeet and is_on_floor():
		$CollisionShape2D.disabled = true
		await get_tree().create_timer(0.1).timeout
		$CollisionShape2D.disabled = false

func checkArea(body):
	if body is Coin:
		(body as Coin).collect()

func checkFeet_enter(body:Node2D):
	if body.is_in_group("Platform"):
		b_checkFeet = true

func checkFeet_exit(body:Node2D):
	if body.is_in_group("Platform"):
		b_checkFeet = false

func _process(delta):
	if Input.is_action_just_pressed("UP"):
		Jump()
	elif Input.is_action_just_pressed("DOWN"):
		Fall()
	
	input.x = Input.get_axis("LEFT","RIGHT") 

func _physics_process(delta):
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		b_jumped = false

	if input.length() > 0.0:
		velocity.x += input.x * delta * SPEED
		if is_on_floor():
			if abs(velocity.x) > 10.0:
				node_feetPaticles.emitting = true
			else:
				node_feetPaticles.emitting = false
	else:
		velocity.x = move_toward(velocity.x, 0.0, SPEED)
		if velocity.x == 0.0:
			node_feetPaticles.emitting = false

	move_and_slide()
