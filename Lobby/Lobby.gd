extends Node3D

@onready var podiumPlayer = preload("res://Lobby/Podium.tscn")
var loadedPlayers: Array = []
var loadedPlayerInstances: Array = []

var PodiumPlayerWidth = 1.8

func _ready():
	multiplayer.send_lobby_message()
	multiplayer.connect("lobby_new_player", lobby_new_players)
	multiplayer.connect("change_to_game", change_to_game)
	$Timer.connect("timeout", on_timer_timeout)

func _process(delta):
	$Control/Label.text = str(round($Timer.time_left))


func lobby_new_players(players: Array, fullDict: Dictionary):
	if "timer" in fullDict:
		$Control/Label.show()
		$Timer.wait_time = 5.0-fullDict["timer"]
		$Timer.start()
	#check if object has the lobby data needed
	if !("lobbydata" in fullDict["players"][players[0]].keys()): return
	
	for i in loadedPlayerInstances:
		i.get_child(0).change_color_to_ready(fullDict["players"][i.get_child(0).id]["lobbydata"])
		
	for i in loadedPlayers:
		if players.count(i) > 0:
			players.erase(i)
	
	for i in players:
		var PodiumPlayerInstance = podiumPlayer.instance()
		PodiumPlayerInstance.global_translate(Vector3(0,0,len(loadedPlayers)*PodiumPlayerWidth))
		PodiumPlayerInstance.get_child(0).id = i
		add_child(PodiumPlayerInstance)
		loadedPlayers.append(i)
		loadedPlayerInstances.append(PodiumPlayerInstance)
		
	# add names to players
	for i in loadedPlayers:
		if fullDict["players"][i].keys().has("name") and loadedPlayers.find(i) != -1:
			if fullDict["players"][i]["name"].empty():
#				Multiplayer.send_lobby_message()
				break
			loadedPlayerInstances[loadedPlayers.find(i)].get_child(0).change_name_above_head(fullDict["players"][i]["name"])
	

func _on_Button_toggled(button_pressed):
	multiplayer.isReady = button_pressed
	multiplayer.send_lobby_message()

func on_timer_timeout():
	multiplayer.send_timer_timeout()

func change_to_game():
	get_tree().change_scene("res://Game/MainScene.tscn")
