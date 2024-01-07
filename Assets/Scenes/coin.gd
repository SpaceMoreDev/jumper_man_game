extends RigidBody2D
class_name Coin

var collected : bool = false

func collect():
	Global.Score += 10
	#print(Global.Score)
	collected = true

func _physics_process(delta):
	if collected:
		if scale.x < 0.5:
			queue_free()
		else:
			position = lerp(position, Global.GameManager.player.position, delta * 10)
			scale = lerp(scale, Vector2.ZERO, delta * 5)
