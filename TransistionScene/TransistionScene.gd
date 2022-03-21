extends Control


func _ready():
	$AnimationPlayer.play_backwards("SceneTrans")
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_node("/root/Multiplayer").reset()


func _on_Button_pressed():
	get_tree().change_scene("res://Lobby/Lobby.tscn")
