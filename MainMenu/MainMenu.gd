extends Spatial

onready var UsernameInput: LineEdit = $Control/VBoxContainer/Username
onready var IPInput: LineEdit = $Control/VBoxContainer/Ip

var IPRegex = RegEx.new()
var HostnameRegex = RegEx.new()

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	var anim = get_node("AnimationPlayer")
	anim.play("RotationBackground")
	
	IPRegex.compile("(\\b25[0-5]|\\b2[0-4][0-9]|\\b[01]?[0-9][0-9]?)(\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)){3}")
	HostnameRegex.compile("^(?=.{1,255}$)[0-9A-Za-z](?:(?:[0-9A-Za-z]|-){0,61}[0-9A-Za-z])?(?:\\.[0-9A-Za-z](?:(?:[0-9A-Za-z]|-){0,61}[0-9A-Za-z])?)*\\.?$")


func _on_Button_pressed():
	#WARNING, REMOVE IPTEXT.empty IN FINAL BUILD
	
	var map_button_pressed = int($Control/VBoxContainer/MapSelection/Map1.pressed)
		
	var IPtext = IPInput.text
	if (IPRegex.search(IPtext) or HostnameRegex.search(IPtext)) and not UsernameInput.text.empty():
		Multiplayer.username = UsernameInput.text
		Multiplayer.map_used = map_button_pressed
		Multiplayer.start_connection("ws://"+IPtext+":8888/ws")
		get_tree().change_scene("res://Lobby/Lobby.tscn")

func _on_Options_pressed():
	$Settings.show()
	$Control.hide()

func _on_Settings_exit_settings():
	$Control.show()

