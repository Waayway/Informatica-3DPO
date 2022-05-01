extends KinematicBody


##
## Load the MultiplayerNode so it is easier to access from this script
##
onready var multiplayer_node = get_node("/root/Multiplayer")


##
## Load all camera related Nodes, so the camera and pivot, which are both needed
##
onready var camera = $Pivot/Camera
onready var pivot = $Pivot
onready var camera_raycast = $Pivot/Camera/CameraRay


##
## Seeker UI Elements, namely the 2 crosshairs. and the overarching node above it.
## You can show and hide both depending on situation, But Seeker
##
onready var seeker_ui: Node2D = $SeekerUI
onready var crosshair1: Sprite = $SeekerUI/Crosshair1
onready var crosshair2: Sprite = $SeekerUI/Crosshair2


##
## Movement Variables and constants.
##
export var gravity: float = -20
export var max_speed: float = 16
export var max_sprint_speed: float = 20
export var ground_acceleration: float = 10
export var air_acceleration: float = 2
export var air_time_multiplier: float = 0.2
var cur_speed = 0
var cur_max_speed = max_speed
var jump_speed = 10
var mouse_sensitivity = 0.002  # radians/pixel
var velocity = Vector3.ZERO
var acceleration: float = ground_acceleration
var air_time: float = 0

##
## Animation variables and constants, the cur_anim will be sent via the multiplayer script
##
var cur_anim: int = 0
var cur_anim_reversed: bool = false
enum Animations {
	Idle = 0,
	Walk = 1,
	Run = 2,
	StrafeLeft = 3,
	StrafeRunLeft = 4,
	StrafeRight = 5,
	StrafeRunRight = 6,
}

##
## Ready, Set Mouse mode and show seeker ui if player is seeker. 
## Slight flaw with code is that window resize will not set the ui in the middle position again.
##
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if multiplayer_node.self_seeker:
		seeker_ui.show()
		seeker_ui.position = get_viewport().size/2


##
## Default Godot function. execute other functions like input() and the rest of the movement code.
##
func _physics_process(delta: float) -> void:
	input()
	execute_gravity_and_jump(delta)
	get_animation_state()
	movement(delta)
	if multiplayer_node.self_seeker:
		execute_seeker()
	set_data_multiplayer()


##
## Default godot function, get mouse position and set the camera to a rotation
##
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		pivot.rotate_x(-event.relative.y * mouse_sensitivity)
		rotate_y(-event.relative.x * mouse_sensitivity)
		pivot.rotation.x = clamp(pivot.rotation.x, -1.2, 1.2)


##
## Get Input, will be executed every frame. This is mostly utility things like capturing mouse and toggling fullscreen
##
func input() -> void:
	if Input.is_action_just_pressed("toggle_mouse_capture"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


##
## Apply movement vectors and do some velocity calculations
##
func movement(delta: float) -> void:
	if is_on_floor():
		acceleration = ground_acceleration
	else:
		acceleration = air_acceleration
	var input_dir = get_movement_input()
	var new_velocity: Vector3 = input_dir*cur_max_speed
	
	var temp_velocity: Vector3 = velocity.linear_interpolate(new_velocity, acceleration*delta)
	
	velocity.x = temp_velocity.x
	velocity.z = temp_velocity.z
	velocity = move_and_slide(velocity, Vector3.UP, true)

##
## Get movement and set animation accordingly
##
func get_animation_state() -> void:
	var anim_dir: Vector2 = Vector2.ZERO
	var cur_animation = 0
	var cur_animation_reversed = false
	
	anim_dir.x = int(Input.is_action_pressed("strafe_right"))-int(Input.is_action_pressed("strafe_left"))
	anim_dir.y = int(Input.is_action_pressed("move_forward"))-int(Input.is_action_pressed("move_backward"))

	if anim_dir.y != 0:
		cur_animation = Animations.Walk
		if anim_dir.y < 0:
			cur_animation_reversed = true
	if anim_dir.x > 0:
		cur_animation = Animations.StrafeRight
	elif anim_dir.x < 0:
		cur_animation = Animations.StrafeLeft
	
	if Input.is_action_pressed("sprint") && cur_animation != 0:
		cur_animation += 1
	
	cur_anim = cur_animation
	cur_anim_reversed = cur_animation_reversed

##
## get movement vector from input.
##
func get_movement_input() -> Vector3:
	var input_dir: Vector3 = Vector3.ZERO
	if Input.is_action_pressed("move_forward"):
		input_dir += -camera.global_transform.basis.z
	if Input.is_action_pressed("move_backward"):
		input_dir += camera.global_transform.basis.z
	if Input.is_action_pressed("strafe_left"):
		input_dir += -camera.global_transform.basis.x
	if Input.is_action_pressed("strafe_right"):
		input_dir += camera.global_transform.basis.x
	
	if Input.is_action_pressed("sprint"):
		cur_max_speed = max_sprint_speed
	else:
		cur_max_speed = max_speed
	
	input_dir = input_dir.normalized()
	
	return input_dir


##
## Add gravity to velocity and reverse velocity if the player jumps
##
func execute_gravity_and_jump(delta: float):
	if is_on_floor():
		air_time = 0.0
	else:
		air_time += delta
	velocity.y += (gravity + gravity*air_time*air_time_multiplier) * delta
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = jump_speed


##
## Set the data in the multiplayer_node global node.
##
func set_data_multiplayer():
	## Position Variables
	multiplayer_node.pos = global_transform.origin
	multiplayer_node.rot = rotation_degrees
	multiplayer_node.vel = velocity
	
	## Animation Variables
	multiplayer_node.anim = cur_anim
	multiplayer_node.anim_reversed = cur_anim_reversed


##
## Only execute when someone is seekr will get the raycast from the camera and will check if it is colliding, if it is change crosshair icons
##
func execute_seeker():
	var colliding_object = camera_raycast.get_collider()
	if colliding_object:
		if colliding_object.is_in_group("Player"):
			crosshair1.hide()
			crosshair2.show()
			if Input.is_action_just_pressed("find"):
				multiplayer_node.send_player_found(colliding_object.id)
		else:
			crosshair1.show()
			crosshair2.hide()
	else:
		crosshair1.show()
		crosshair2.hide()
