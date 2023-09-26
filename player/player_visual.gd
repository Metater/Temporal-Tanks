extends Sprite2D

var body_position_0: Vector2
var body_position_1: Vector2
var body_rotation_0: float
var body_rotation_1: float

func _process(_delta):
	var t = Engine.get_physics_interpolation_fraction()
	body(t)

func body(t):
	position = body_position_0.lerp(body_position_1, t)
	
	var desired_rotation = lerp_angle(body_rotation_0, body_rotation_1, t)
	# the given rotation is unit circle based
	desired_rotation = (-desired_rotation) - PI / 2;
	rotation = desired_rotation
func set_body_pose(desired_position, desired_rotation):
	body_position_0 = desired_position
	body_position_1 = desired_position
	body_rotation_0 = desired_rotation
	body_rotation_1 = desired_rotation
func index_body_pose(desired_position, desired_rotation):
	body_position_0 = body_position_1
	body_position_1 = desired_position
	body_rotation_0 = body_rotation_1
	body_rotation_1 = desired_rotation
