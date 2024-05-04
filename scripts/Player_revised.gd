extends RigidBody3D

const SPRINT_SPEED = 350.0
const WALK_SPEED = 200.0
const JUMP_VELOCITY = 10
const SENSITIVITY = 0.003
const BOB_FREQ = 2.0
const BOB_AMP = 0.08
const FOV_CHANGE = 1.5

var t_bob = 0.0
var speed = WALK_SPEED
var base_FOV = 75.0

var _move_dir = Vector3.ZERO
var _last_dir = Vector3.FORWARD
var local_grav = Vector3.DOWN
var reset = false
var rotation_speed = 8.0

@onready var _model = $Head
@onready var camera = $Head/Camera3D
@onready var _start_pos = global_transform.origin

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		_model.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-60), deg_to_rad(75))
	if Input.is_action_pressed("ui_menu"):
		get_tree().change_scene_to_file("res://scenes/menu.tscn")

func _integrate_forces(state):
	if reset:
		state.transform.origin = _start_pos
		reset = false
	
	local_grav = state.total_gravity.normalized()
	
	if _move_dir.length() > 0.2:
		_last_dir = _move_dir.normalized()
	
	_move_dir = _get_model_oriented_input()
	_orient_to_dir(_move_dir, state.step)
	
	#if is_jumping(state):
		#apply_central_impulse(-local_grav * JUMP_VELOCITY)
	if is_on_floor(state):
		apply_central_force(_move_dir * speed)
	
	
	
func _get_model_oriented_input() -> Vector3:
	var input_dir = Input.get_vector("mv_left", "mv_right", "mv_forward", "mv_back")
	var direction = (_model.transform.basis * Vector3(-input_dir.x, 0, -input_dir.y)).normalized()
	
	var input = Vector3.ZERO
	input.x = input_dir.x 
	input.z = input_dir.y 
	
	input = _model.transform.basis * input
	return input

func _orient_to_dir(direction, delta):
	var left_axis = -local_grav.cross(direction)
	var rotation_basis = Basis(left_axis, -local_grav, direction).orthonormalized()
	
	var a = _model.basis.orthonormalized()
	var b = Quaternion(rotation_basis)
	var c = a.get_rotation_quaternion.slerp(
		rotation_basis, delta * rotation_speed
	)
	_model.transform.basis = Basis(c)
	
func is_on_floor(state: PhysicsDirectBodyState3D) -> bool:
	for contact in state.get_contact_count():
		var contact_normal = state.get_contact_local_normal(contact)
		
		if contact_normal.dot(-local_grav) > 0.5:
			return true
	return false
