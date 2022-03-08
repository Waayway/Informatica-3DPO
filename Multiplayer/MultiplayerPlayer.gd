extends KinematicBody

export var id: String = ""
export var username: String = ""

onready var anim: AnimationPlayer = $xbot/RootNode/AnimationPlayer
onready var xbot: Spatial = $xbot
var pos = Vector3.ZERO
var rot = Vector3.ZERO
var vel = Vector3.ZERO

func _ready():
	get_node("Spatial/Viewport/Label").text = username
	anim.play("IdleAnimation")

func _process(delta):
	move_and_slide(vel)
	
func _play_animation(animation: String, reversed: bool):
	if reversed:
		anim.play_backwards(animation)
	else:
		anim.play(animation)
	
func _set_animation(animation: int, reversed: bool):
	if animation == 0 and anim.current_animation != "IdleAnimation":
		_play_animation("IdleAnimation", reversed)
	elif animation == 1 and anim.current_animation != "WalkingAnimation":
		_play_animation("WalkingAnimation", reversed)
	elif animation == 2 and anim.current_animation != "RunningAnimation":
		_play_animation("RunningAnimation", reversed)
	elif animation == 3 and anim.current_animation != "StrafeLeftAnimation":
		_play_animation("StrafeLeftAnimation", reversed)
	elif animation == 4 and anim.current_animation != "StrafeLeftRunAnimation":
		_play_animation("StrafeLeftRunAnimation", reversed)
	elif animation == 5 and anim.current_animation != "StrafeRightAnimation":
		_play_animation("StrafeRightAnimation", reversed)
	elif animation == 6 and anim.current_animation != "StrafeRightRunAnimation":
		_play_animation("StrafeRightRunAnimation", reversed)

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
