extends KinematicBody

onready var camera = $RotationHelper/Camera
onready var rotation_helper = $RotationHelper
onready var ground_ray = $GroundRay

var gravity = -30
var max_speed = 8
var max_sprint_speed = 16
var cur_max_speed = max_speed
var jump_speed = 10
var mouse_sensitivity = 0.002  # radians/pixel

var velocity = Vector3.ZERO

var animationBlendValue: int = -1
const ANIMATION_IDLE = -1
const ANIMATION_WALK = 0
const ANIMATION_RUN = 1

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func get_input():
	var input_dir = Vector3.ZERO
	var smooving: bool = false
	if Input.is_action_pressed("move_forward"):
		input_dir += -camera.global_transform.basis.z
		smooving = true
	if Input.is_action_pressed("move_backward"):
		input_dir += camera.global_transform.basis.z
		smooving = true
	if Input.is_action_pressed("strafe_left"):
		input_dir += -camera.global_transform.basis.x
	if Input.is_action_pressed("strafe_right"):
		input_dir += camera.global_transform.basis.x
	input_dir = input_dir.normalized()
	
	if smooving:
		animationBlendValue = ANIMATION_WALK
		if Input.is_action_pressed("sprint"):
			animationBlendValue = ANIMATION_RUN
	else:
		animationBlendValue = ANIMATION_IDLE
	
	get_node("/root/Multiplayer").anim = animationBlendValue
	
	if Input.is_action_pressed("sprint"):
		cur_max_speed = max_sprint_speed
	else:
		cur_max_speed = max_speed
	return input_dir
	
func _unhandled_input(event):
	if event is InputEventMouseButton and Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotation_helper.rotate_x(-event.relative.y * mouse_sensitivity)
		rotate_y(-event.relative.x * mouse_sensitivity)
		rotation_helper.rotation.x = clamp(rotation_helper.rotation.x, -1.2, 1.2)

func _physics_process(delta):
	velocity.y += gravity * delta
	var desired_velocity = get_input() * cur_max_speed
	if Input.is_action_just_pressed("jump") and ground_ray.is_colliding():
		velocity.y = jump_speed
	
	velocity.x = desired_velocity.x
	velocity.z = desired_velocity.z
	velocity = move_and_slide(velocity, Vector3.UP, true)
	get_node("/root/Multiplayer").pos = global_transform.origin
	get_node("/root/Multiplayer").rot = rotation_degrees
	get_node("/root/Multiplayer").vel = velocity
