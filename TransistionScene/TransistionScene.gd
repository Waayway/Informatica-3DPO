extends Control

var gameOverData: Dictionary

func _ready():
	$AnimationPlayer.play_backwards("SceneTrans")
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	multiplayer.reset()
	gameOverData = multiplayer.gameOverData
	if not gameOverData["hiders"]:
		$VBoxContainer/Label.text = "The Seeker won"


func _on_Button_pressed():
	get_tree().change_scene("res://Lobby/Lobby.tscn")
