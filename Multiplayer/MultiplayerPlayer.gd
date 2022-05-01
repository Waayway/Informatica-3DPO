extends KinematicBody

export var id: String = ""
export var username: String = ""

onready var anim: AnimationPlayer = $xbot/RootNode/AnimationPlayer
onready var xbot: Spatial = $xbot
var pos = Vector3.ZERO
var rot = Vector3.ZERO
var vel = Vector3.ZERO

var isSeeker = false

enum Animations {
	Idle = 0,
	Walk = 1,
	Run = 2,
	StrafeLeft = 3,
	StrafeRunLeft = 4,
	StrafeRight = 5,
	StrafeRunRight = 6,
}
const AnimationNames = {
	Idle = "IdleAnimation",
	Walk = "WalkingAnimation",
	Run = "RunningAnimation",
	StrafeLeft = "StrafeLeftAnimation",
	StrafeRunLeft = "StrafeLeftRunAnimation",
	StrafeRight = "StrafeRightAnimation",
	StrafeRunRight = "StrafeRightRunAnimation",
}

enum Sounds {
	Walking = 0,
}
onready var WalkingOrRunningSound = $Audio/Walk

func _ready():
	get_node("Spatial/Viewport/Label").text = username
	anim.play("IdleAnimation")
	if isSeeker:
		var mat = get_node("xbot/RootNode/Beta_Joints").get_surface_material(0).duplicate()
		mat.albedo_color = Color.purple
		get_node("xbot/RootNode/Beta_Joints").set_surface_material(0,mat)
	else:
		var mat = get_node("xbot/RootNode/Beta_Joints").get_surface_material(0).duplicate()
		mat.albedo_color = Color.aqua
		get_node("xbot/RootNode/Beta_Joints").set_surface_material(0,mat)

func _process(delta):
	move_and_slide(vel)
	
func _play_animation(animation: String, reversed: bool):
	if reversed:
		anim.play_backwards(animation)
	else:
		anim.play(animation)

func _play_sound_by_animation(sound_num: int):
	if sound_num == Sounds.Walking && !WalkingOrRunningSound.playing:
		WalkingOrRunningSound.play()

func _set_animation(animation: int, reversed: bool):
	if animation == Animations.Idle and anim.current_animation != AnimationNames.Idle:
		_play_animation(AnimationNames.Idle, reversed)
	elif animation == Animations.Walk and anim.current_animation != AnimationNames.Walk:
		_play_animation(AnimationNames.Walk, reversed)
	elif animation == Animations.Run and anim.current_animation != AnimationNames.Run:
		_play_animation(AnimationNames.Run, reversed)
	elif animation == Animations.StrafeLeft and anim.current_animation != AnimationNames.StrafeLeft:
		_play_animation(AnimationNames.StrafeLeft, reversed)
	elif animation == Animations.StrafeRunLeft and anim.current_animation != AnimationNames.StrafeRunLeft:
		_play_animation(AnimationNames.StrafeRunLeft, reversed)
	elif animation == Animations.StrafeRight and anim.current_animation != AnimationNames.StrafeRight:
		_play_animation(AnimationNames.StrafeRight, reversed)
	elif animation == Animations.StrafeRunRight and anim.current_animation != AnimationNames.StrafeRunRight:
		_play_animation(AnimationNames.StrafeRunRight, reversed)
	
	if animation != Animations.Idle:
		_play_sound_by_animation(Sounds.Walking)

func apply_data(data: Dictionary):
	var local_pos = data["pos"]
	var local_rot = data["rot"]
	var local_vel = data["vel"]
	pos = Vector3(local_pos["x"],local_pos["y"],local_pos["z"])
	self.global_transform.origin = pos
	rot = Vector3(local_rot["x"],local_rot["y"],local_rot["z"])
	self.rotation_degrees = rot
	vel = Vector3(local_vel["x"],local_vel["y"],local_vel["z"])
	_set_animation(data["anim"]["num"], data["anim"]["reversed"])
