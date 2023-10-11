extends Sprite2D

var body_position_0: Vector2
var body_position_1: Vector2

var body_rotation_0: float
var body_rotation_1: float

func _process(_delta):
	var t = Engine.get_physics_interpolation_fraction()
	
	position = body_position_0.lerp(body_position_1, t)
	
	var angle_rad = lerp_angle(body_rotation_0, body_rotation_1, t)
	rotation = convert_angle(angle_rad)

func set_body_pose(body_position, body_rotation):
	body_position_0 = body_position
	body_position_1 = body_position
	
	body_rotation_0 = body_rotation
	body_rotation_1 = body_rotation

func index_body_pose(body_position, body_rotation):
	body_position_0 = body_position_1
	body_position_1 = body_position
	
	body_rotation_0 = body_rotation_1
	body_rotation_1 = body_rotation

func convert_angle(angle_rad):
	return (-angle_rad) - PI / 2
