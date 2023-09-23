extends RigidBody2D

const rotation_speed = 1.5 * PI # radians / sec
const forward_speed = 800 # pixels / sec
const accel_time = 0.5 # sec
const forward_accel = forward_speed / accel_time # pixels / sec^2
const input_accel_time = 0.5 # sec

var current_heading = PI / 2 # face up by default
var desired_heading = current_heading
var last_turn_direction = 1 # turn CCW by default
var input_physics_frame_count = 0

func _ready():
	position = Vector2(200, 200)
	
	$"../Sprite2D".reset()

func _integrate_forces(state):
	rotation = sin(Time.get_ticks_msec() / 1000.0)

func get_input_accel_fraction(delta):
	var seconds_since_input_began = input_physics_frame_count * delta
	var t = seconds_since_input_began / input_accel_time
	t = clampf(t, 0, 1)
	return sqrt(t)

func teleport(position, rotation):
	
