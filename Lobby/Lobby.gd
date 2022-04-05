extends Spatial

onready var podiumPlayer = preload("res://Lobby/Podium.tscn")
var loadedPlayers: Array = []
var loadedPlayerInstances: Array = []

var PodiumPlayerWidth = 1.8

onready var MultiplayerNode = get_node("/root/Multiplayer")

func _ready():
	MultiplayerNode.send_lobby_message()
	MultiplayerNode.connect("lobby_new_player", self,"lobby_new_players")
	MultiplayerNode.connect("change_to_game", self, "change_to_game")
	$Timer.connect("timeout",self,"on_timer_timeout")

func _process(delta):
	$Control/Label.text = str(round($Timer.time_left))

func lobby_new_players(players: Array, fullDict: Dictionary):
	if "timer" in fullDict:
		$Control/Label.show()
		$Timer.wait_time = 5.0-fullDict["timer"]
		$Timer.start()
	#check if object has the lobby data needed
	if !("lobbydata" in fullDict["players"][players[0]].keys()): return
	# Check id if ready and update color or animation, idk what will change eventually
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
#				MultiplayerNode.send_lobby_message()
				break
			loadedPlayerInstances[loadedPlayers.find(i)].get_child(0).change_name_above_head(fullDict["players"][i]["name"])
	

func _on_Button_toggled(button_pressed):
	MultiplayerNode.isReady = button_pressed
	MultiplayerNode.send_lobby_message()

func on_timer_timeout():
	MultiplayerNode.send_timer_timeout()

func change_to_game():
	get_tree().change_scene("res://Game/MainScene.tscn")
