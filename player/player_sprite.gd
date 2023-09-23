extends Sprite2D

var position_0: Vector2
var position_1: Vector2
var rotation_0: float
var rotation_1: float

func _process(_delta):
	var t = Engine.get_physics_interpolation_fraction()
	
	position = position_0.lerp(position_1, t)
	
	var desired_rotation = lerp_angle(rotation_0, rotation_1, t)
	# the given rotation is unit circle based
	desired_rotation = (-desired_rotation) - PI / 2;
	rotation = desired_rotation

func set_pose(desired_position, desired_rotation):
	position_0 = desired_position
	position_1 = desired_position
	rotation_0 = desired_rotation
	rotation_1 = desired_rotation

func index_pose(desired_position, desired_rotation):
	position_0 = position_1
	position_1 = desired_position
	rotation_0 = rotation_1
	rotation_1 = desired_rotation
