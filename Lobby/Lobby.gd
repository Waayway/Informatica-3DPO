extends Spatial

onready var podiumPlayer = preload("res://Lobby/Podium.tscn")
var loadedPlayers: Array = []
var loadedPlayerInstances: Array = []

var PodiumPlayerWidth = 1.8

onready var MultiplayerNode = get_node("/root/Multiplayer")

func _ready():
	MultiplayerNode.connect("lobby_new_player", self,"lobby_new_players")

func lobby_new_players(players: Array, fullDict: Dictionary):
	#check if object has the lobby data needed
	if !("lobbydata" in fullDict[players[0]].keys()): return
	# Check id if ready and update color or animation, idk what will change eventually
	for i in loadedPlayerInstances:
		i.get_child(0).change_color_to_ready(fullDict[i.get_child(0).id]["lobbydata"])
		
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
		print(fullDict)
		if fullDict[i].keys().has("name") and loadedPlayers.find(i) != -1:
			if fullDict[i]["name"].empty():
				MultiplayerNode.send_lobby_message()
				break
			loadedPlayerInstances[loadedPlayers.find(i)].get_child(0).change_name_above_head(fullDict[i]["name"])
	

func _on_Button_toggled(button_pressed):
	MultiplayerNode.isReady = button_pressed
	MultiplayerNode.send_lobby_message()
