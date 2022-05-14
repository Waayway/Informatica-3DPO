extends Node3D

@export var id: String = ""
var basePosition: Vector3 = Vector3.ZERO
var differentHeight: float = .1
var speed = 3
var Ready: bool = false

var counter = 0
func _ready():
	basePosition = global_transform.origin
	$xbot/RootNode/AnimationPlayer.play("IdleAnimation")

func _process(delta):
	pass

func change_color_to_ready(isReady: bool):
	Ready = isReady
	var color = Color.BLACK
	if ready:
		color = Color.GREEN
		$xbot/RootNode/AnimationPlayer.play("RaiseHand")
		$xbot/RootNode/AnimationPlayer.animation_set_next("RaiseHand","IdleAnimation")
	get_parent().get_node("Spatial/Viewport/Label").set("custom_colors/font_color", color)
	
func change_name_above_head(name: String):
	get_parent().get_node("Spatial/Viewport/Label").text = name
