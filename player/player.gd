extends RigidBody2D

const BODY_ROTATION_SPEED = 1.5 * PI # radians / sec
const BODY_SPEED = 800 # pixels / sec
const BODY_ACCEL_TIME = 0.5 # sec
const BODY_ACCEL = BODY_SPEED / BODY_ACCEL_TIME # pixels / sec^2
const INPUT_ACCEL_TIME = 0.5 # sec

#const BULLET_SCENE = preload("res://bullet/bullet.tscn")

var body_current_rotation = PI / 2 # face up by default
var body_desired_rotation = body_current_rotation
var last_body_turn_direction = 1 # turn CCW by default, -1 or 1
var input_physics_frame_count = 0

var barrel_current_rotation = body_current_rotation
var barrel_desired_rotation = barrel_current_rotation

@onready var BodySprite2D = $"../BodySprite2D"
@onready var MuzzleNode2D = $"../BodySprite2D/BarrelSprite2D/MuzzleNode2D"
@onready var BarrelSprite2D = $"../BodySprite2D/BarrelSprite2D"

func _ready():
	BodySprite2D.set_body_pose(position, body_current_rotation)

func _process(_delta):
	update_barrel_rotation()
	
#	if Input.is_action_just_pressed("shoot"):
#		var desired_position = MuzzleNode2D.global_position
#		var impulse = Vector2.UP.rotated(barrel_current_rotation) * 400
#
#		var instance = BULLET_SCENE.instantiate()
#		instance.get_child(0).shoot(desired_position, impulse)
#		$"../".add_child(instance)

func _physics_process(delta):
	update_body_rotation(delta)
	update_linear_velocity(delta)
	
	BodySprite2D.index_body_pose(position, body_current_rotation)

func _integrate_forces(_state):
	# must use this, not RigidBody2D.lock_rotation
	# lock_rotation causes player to get stuck on objects when up against them and
	# trying accelerating from zero at an angle towards the object
	rotation = 0

func update_body_rotation(delta):
	update_body_desired_rotation()
	# the most the rotation could change this frame, radians
	var max_rotation_delta = BODY_ROTATION_SPEED * delta
	# the unit circle arc distance from body_current_rotation to body_desired_rotation, radians
	var rotation_error = Vector2.from_angle(body_current_rotation).angle_to(Vector2.from_angle(body_desired_rotation))
	if rotation_error == 0:
		pass
	elif abs(rotation_error) <= max_rotation_delta:
		body_current_rotation = body_desired_rotation
		last_body_turn_direction = binary_sign(rotation_error)
	else:
		var turn_direction = binary_sign(rotation_error)
		# if starting a 180, turn in the direction of the last turn
		if abs(rotation_error) > (0.99 * PI) && abs(rotation_error) < (1.01 * PI):
			turn_direction = last_body_turn_direction
		# turn by max increment in the specified direction
		body_current_rotation += max_rotation_delta * turn_direction
		last_body_turn_direction = turn_direction
func update_body_desired_rotation():
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
		body_desired_rotation = vector.angle()
		input_physics_frame_count += 1
	else:
		input_physics_frame_count = 0
func binary_sign(value):
	if value >= 0.0:
		return 1.0
	return -1.0

func update_linear_velocity(delta):
	# dot product of body_current_rotation and body_desired_rotation, range: [-1, 1]
	var velocity_fraction = Vector2.from_angle(body_current_rotation).dot(Vector2.from_angle(body_desired_rotation))
	
	# set movement_vector to body_current_rotation vector with y flipped
	var movement_vector = Vector2.from_angle(body_current_rotation) * Vector2(1, -1)
	var input_accel_fraction = get_input_accel_fraction(delta)
	var desired = movement_vector * (BODY_SPEED * velocity_fraction * input_accel_fraction)
	if input_physics_frame_count == 0:
		desired = Vector2.ZERO
	
	# accelerate and apply
	var desired_x = move_toward(linear_velocity.x, desired.x, BODY_ACCEL * delta)
	var desired_y = move_toward(linear_velocity.y, desired.y, BODY_ACCEL * delta)
	var impulse = Vector2(desired_x, desired_y) - linear_velocity
	apply_central_impulse(impulse)
func get_input_accel_fraction(delta):
	var seconds_since_input_began = input_physics_frame_count * delta
	var t = seconds_since_input_began / INPUT_ACCEL_TIME
	t = clampf(t, 0, 1)
	return sqrt(t)

func update_barrel_rotation():
	# find unit circle angle to point barrel towards mouse
	barrel_desired_rotation = ((get_global_mouse_position() - position).normalized() * Vector2(1, -1)).angle()
	
	# point barrel towards mouse
	BarrelSprite2D.global_rotation = convert_angle(barrel_desired_rotation)

func convert_angle(angle_rad):
	return (-angle_rad) - PI / 2
