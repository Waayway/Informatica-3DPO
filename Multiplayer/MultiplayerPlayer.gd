extends KinematicBody

export var id: String = ""
export var username: String = ""

onready var anim_tree = $xbot/RootNode/AnimationTree

var pos = Vector3.ZERO
var rot = Vector3.ZERO
var vel = Vector3.ZERO

func _ready():
	get_node("Spatial/Viewport/Label").text = username

func _process(delta):
	move_and_slide(vel)

func apply_data(data: Dictionary):
	var local_pos = data["pos"]
	var local_rot = data["rot"]
	var local_vel = data["vel"]
	pos = Vector3(local_pos["x"],local_pos["y"],local_pos["z"])
	self.global_transform.origin = pos
	rot = Vector3(local_rot["x"],local_rot["y"],local_rot["z"])
	self.rotation_degrees = rot
	vel = Vector3(local_vel["x"],local_vel["y"],local_vel["z"])
	anim_tree.set("parameters/Blend3/blend_amount", data["anim"])
