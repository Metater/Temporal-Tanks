extends RigidBody2D

const body_rotation_speed = 1.5 * PI # radians / sec
const body_speed = 800 # pixels / sec
const body_accel_time = 0.5 # sec
const body_accel = body_speed / body_accel_time # pixels / sec^2
const input_accel_time = 0.5 # sec

var current_rotation = PI / 2 # face up by default
var desired_rotation = current_rotation
var last_turn_direction = 1 # turn CCW by default, -1 or 1
var input_physics_frame_count = 0

func _ready():
	$"../BodySprite2D".set_body_pose(position, current_rotation)

func _physics_process(delta):
	update_rotation(delta)
	update_linear_velocity(delta)
	
	$"../BodySprite2D".index_body_pose(position, current_rotation)

func _integrate_forces(_state):
	# must use this, not RigidBody2D.lock_rotation
	# lock_rotation causes player to get stuck on objects when up against them and
	# trying accelerating from zero at an angle towards the object
	rotation = 0

func update_rotation(delta):
	update_desired_rotation()
	# the most the rotation could change this frame, radians
	var max_rotation_delta = body_rotation_speed * delta;
	# the unit circle arc distance from current_rotation to desired_rotation, radians
	var rotation_error = Vector2.from_angle(current_rotation).angle_to(Vector2.from_angle(desired_rotation))
	if rotation_error == 0:
		pass
	elif abs(rotation_error) <= max_rotation_delta:
		current_rotation = desired_rotation
		last_turn_direction = binary_sign(rotation_error)
	else:
		var turn_direction = binary_sign(rotation_error)
		# if starting a 180, turn in the direction of the last turn
		if abs(rotation_error) > (0.99 * PI) && abs(rotation_error) < (1.01 * PI):
			turn_direction = last_turn_direction
		# turn by max increment in the specified direction
		current_rotation += max_rotation_delta * turn_direction
		last_turn_direction = turn_direction
func update_desired_rotation():
	var vector = Vector2.ZERO
	
	if Input.is_action_pressed("move_left"):
		vector.x -= 1
	if Input.is_action_pressed("move_right"):
		vector.x += 1
	if Input.is_action_pressed("move_down"):
		vector.y -= 1
	if Input.is_action_pressed("move_up"):
		vector.y += 1
	
	if vector.length() > 0:
		vector = vector.normalized()
		desired_rotation = vector.angle()
		input_physics_frame_count += 1
	else:
		input_physics_frame_count = 0
func binary_sign(value):
	if value >= 0.0:
		return 1.0
	return -1.0

func update_linear_velocity(delta):
	# dot product of current_rotation and desired_rotation, range: [-1, 1]
	var velocity_fraction = Vector2.from_angle(current_rotation).dot(Vector2.from_angle(desired_rotation))
	
	# set movement_vector to current_rotation vector with y flipped
	var movement_vector = Vector2.from_angle(current_rotation) * Vector2(1, -1)
	var input_accel_fraction = get_input_accel_fraction(delta)
	var desired = movement_vector * (body_speed * velocity_fraction * input_accel_fraction)
	if input_physics_frame_count == 0:
		desired = Vector2.ZERO
	
	# accelerate and apply
	var desired_x = move_toward(linear_velocity.x, desired.x, body_accel * delta)
	var desired_y = move_toward(linear_velocity.y, desired.y, body_accel * delta)
	var correction_impulse = Vector2(desired_x, desired_y) - linear_velocity
	apply_central_impulse(correction_impulse)
func get_input_accel_fraction(delta):
	var seconds_since_input_began = input_physics_frame_count * delta
	var t = seconds_since_input_began / input_accel_time
	t = clampf(t, 0, 1)
	return sqrt(t)
