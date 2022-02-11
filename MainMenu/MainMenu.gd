extends Spatial


func _ready():
	get_node("TestScene/KinematicBody").queue_free()
	var anim = get_node("AnimationPlayer")
	anim.play("RotationBackground")
