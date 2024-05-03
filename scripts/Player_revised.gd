extends RigidBody3D

const SPRINT_SPEED = 8.0
const WALK_SPEED = 5.0
const JUMP_VELOCITY = 10
const SENSITIVITY = 0.003
const BOB_FREQ = 2.0
const BOB_AMP = 0.08
const FOV_CHANGE = 1.5

@export var rotation_speed = 8.0

var t_bob = 0.0
var speed = WALK_SPEED
var base_FOV = 75.0

var _move_dir = Vector3.ZERO
var _last_strong_dir = Vector3.FORWARD
var local_grav = Vector3.DOWN
var _should_reset = false

@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var _start_pos = global_transform.origin

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-60), deg_to_rad(75))

func _physics_process(delta):
	
	if Input.is_action_pressed("ui_menu"):
		get_tree().change_scene_to_file("res://scenes/menu.tscn")


func _integrate_forces(state: PhysicsDirectBodyState3D):
	if _should_reset:
		state.transform.origin = _start_pos
		_should_reset = false
	
	local_grav = state.total_gravity.normalized()
	
	if _move_dir.lenth() > 0.2:
		_last_strong_dir = _move_dir.normalized()
	
	_move_dir = _get_model_oriented_input
	_orient_char_to_dir(_last_strong_dir, state.step)
	
	if is_jumping(state):
		apply_central_impulse(-local_grav * JUMP_VELOCITY)
	if is_on_floor(state):
		apply_central_force(_move_dir * speed)
	



func _get_model_oriented_input() -> Vector3:
	var input_left_right = (
		Input.get_action_strength("mv_left")
		- Input.get_action_strength("mv_right")
	)
	var input_forward = Input.get_action_strength("mv_forward")
func _orient_char_to_dir(direction: Vector3, delta: float):
	pass
func is_jumping(state: PhysicsDirectBodyState3D) -> bool:
	return false
func reset_position():
	pass
func is_on_floor(state: PhysicsDirectBodyState3D) -> bool:
	return false
