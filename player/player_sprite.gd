extends Sprite2D

var position_0: Vector2
var position_1: Vector2

var rotation_0: float
var rotation_1: float

func _process(delta):
	var t = Engine.get_physics_interpolation_fraction()
	position = position_0.lerp(position_1, t)
	rotation = lerp_angle(rotation_0, rotation_1, t)

func reset():
	position_0 = $"../RigidBody2D".position
	position_1 = $"../RigidBody2D".position
	
	rotation_0 = $"../RigidBody2D".rotation
	rotation_1 = $"../RigidBody2D".rotation

func index(position, rotation):
	position_0 = position_1
	position_1 = position
	
	rotation_0 = rotation_1
	rotation_1 = rotation
