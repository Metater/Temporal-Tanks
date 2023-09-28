extends RigidBody2D

func _integrate_forces(_state):
	rotation = 0

func shoot(desired_position, impulse):
	position = desired_position
	print(position)
	apply_central_impulse(impulse)
	$Sprite2D.rotation = impulse.normalized().angle()

# TODO, update the position in _integrate_forces
