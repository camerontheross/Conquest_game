extends CharacterBody3D

const SPRINT_SPEED = 8.0
const WALK_SPEED = 5.0
const JUMP_VELOCITY = 10
const SENSITIVITY = 0.003
const BOB_FREQ = 2.0
const BOB_AMP = 0.08
const FOV_CHANGE = 1.5


var t_bob = 0.0
var gravity = 9.8
var speed
var base_FOV = 75.0

@onready var head = $Head
@onready var camera = $Head/Camera3D

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	#looking around with mouse input
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-60), deg_to_rad(75))

func _physics_process(delta):
	#temp fix for menu
	if Input.is_action_pressed("ui_menu"):
		get_tree().change_scene_to_file("res://scenes/menu.tscn")
	
	#change this later
	#player should be pulled towards planets rather than
	#an arbitrary "down"
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("mv_jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	#handles player speed
	if Input.is_action_pressed("mv_sprint"):
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED

	var input_dir = Input.get_vector("mv_left", "mv_right", "mv_forward", "mv_back")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = 0
			velocity.z = 0
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 2.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 2.0)
	
	#head bob
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)
	
	#FOV
	var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
	var target_fov = base_FOV + FOV_CHANGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)
	
	move_and_slide()

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos
