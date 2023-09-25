extends Node2D

var is_local_player = false

func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	if not is_local_player:
		return
	
	var vector = Vector2.ZERO
	
	if Input.is_action_pressed("move_left"):
		vector.x -= 1
	if Input.is_action_pressed("move_right"):
		vector.x += 1
	if Input.is_action_pressed("move_down"):
		vector.y += 1
	if Input.is_action_pressed("move_up"):
		vector.y -= 1
	
	position += vector * 4
