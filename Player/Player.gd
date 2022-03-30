extends KinematicBody

onready var camera = $RotationHelper/Camera
onready var rotation_helper = $RotationHelper
onready var ground_ray = $GroundRay

onready var crosshairText1: Sprite = $SeekerUI/Crosshair1
onready var crosshairText2: Sprite = $SeekerUI/Crosshair2

var gravity = -30
var max_speed = 8
var max_sprint_speed = 16
var cur_max_speed = max_speed
var jump_speed = 10
var mouse_sensitivity = 0.002  # radians/pixel

var velocity = Vector3.ZERO

var animationBlendValue: int = 0
const ANIMATION_IDLE = 0
const ANIMATION_WALK = 1
const ANIMATION_RUN = 2
const ANIMATION_STRAFE_LEFT = 3
const ANIMATION_STRAFE_RUN_LEFT = 4
const ANIMATION_STRAFE_RIGHT = 5
const ANIMATION_STRAFE_RUN_RIGHT = 6

const RAY_LENGTH = 1000

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if get_node("/root/Multiplayer").self_seeker:
		$SeekerUI.show()
		$SeekerUI.position = get_viewport().size/2

func get_input():
	var input_dir = Vector3.ZERO
	var smooving: bool = false
	var strafin: int = 0
	var reversed: bool = false
	if Input.is_action_pressed("move_forward"):
		input_dir += -camera.global_transform.basis.z
		smooving = true
	if Input.is_action_pressed("move_backward"):
		input_dir += camera.global_transform.basis.z
		smooving = true
		reversed = true
	if Input.is_action_pressed("strafe_left"):
		input_dir += -camera.global_transform.basis.x
		strafin = -1
	if Input.is_action_pressed("strafe_right"):
		input_dir += camera.global_transform.basis.x
		strafin = 1
		reversed = true
	input_dir = input_dir.normalized()
	
	if strafin != 0:
		if strafin == -1:
			animationBlendValue = ANIMATION_STRAFE_LEFT
		elif strafin == 1:
			animationBlendValue = ANIMATION_STRAFE_RIGHT
			
		if Input.is_action_pressed("sprint"):
			if strafin == -1:
				animationBlendValue = ANIMATION_STRAFE_RUN_LEFT
			elif strafin == 1:
				animationBlendValue = ANIMATION_STRAFE_RUN_RIGHT
	elif smooving:
		animationBlendValue = ANIMATION_WALK
		if Input.is_action_pressed("sprint"):
			animationBlendValue = ANIMATION_RUN
	else:
		animationBlendValue = ANIMATION_IDLE
	
	get_node("/root/Multiplayer").anim = animationBlendValue
	get_node("/root/Multiplayer").anim_reversed = reversed
	
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
	
	if get_node("/root/Multiplayer").self_seeker:
		var colliding_object = $RotationHelper/Camera/CameraRay.get_collider()
		if colliding_object:
			if colliding_object.is_in_group("Player"):
				crosshairText1.hide()
				crosshairText2.show()
				if Input.is_action_just_pressed("find"):
					print("found: "+colliding_object.id)
			else:
				crosshairText1.show()
				crosshairText2.hide()
		else:
			crosshairText1.show()
			crosshairText2.hide()
