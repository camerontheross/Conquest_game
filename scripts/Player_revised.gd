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
	
	#open menu (temp)
	if Input.is_action_pressed("ui_menu"):
		get_tree().change_scene_to_file("res://scenes/menu.tscn")

