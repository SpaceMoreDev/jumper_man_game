extends RigidBody2D
class_name Coin

var collected : bool = false
var _manager : Manager

func collect(manager : Manager):
	manager.score += 1
	_manager = manager
	collected = true

func _physics_process(delta):
	if collected:
		if is_equal_approx(scale.length(), 0):
			queue_free()
		else:
			position = lerp(position, _manager.player.position, delta * 10)
			scale = lerp(scale, Vector2.ZERO, delta * 5)
