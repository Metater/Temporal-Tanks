extends RigidBody2D

@export var spawn_position: Vector2

const rotation_speed = 1.5 * PI # radians / sec
const forward_speed = 800 # pixels / sec
const accel_time = 0.5 # sec
const forward_accel = forward_speed / accel_time # pixels / sec^2
const input_accel_time = 0.5 # sec

var current_heading = PI / 2 # face up by default
var desired_heading = current_heading
var last_turn_direction = 1 # turn CCW by default
var input_physics_frame_count = 0

var position_0: Vector2
var position_1: Vector2
var rotation_0: float
var rotation_1: float

func _ready():
	position = spawn_position
	
	position_0 = position
	position_1 = position
	rotation_0 = rotation
	rotation_1 = rotation

func _process(delta):
	var t = Engine.get_physics_interpolation_fraction()
	$"../Sprite2D".position = position_0.lerp(position_1, t)
	$"../Sprite2D".rotation = lerp_angle(rotation_0, rotation_1, t)

func _integrate_forces(state):
	state.linear_velocity = Vector2(240, 0)
	state.angular_velocity = 2 * PI
	
	position_0 = position_1
	position_1 = position
	rotation_0 = rotation_1
	rotation_1 = rotation
