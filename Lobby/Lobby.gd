extends Spatial

onready var podiumPlayer = preload("res://Lobby/Podium.tscn")
var loadedPlayers: Array = []
var loadedPlayerInstances: Array = []

var PodiumPlayerWidth = 1.8

onready var MultiplayerNode = get_node("/root/Multiplayer")

func _ready():
	MultiplayerNode.connect("lobby_new_player", self,"lobby_new_players")

func lobby_new_players(players: Array, fullDict: Dictionary):
	for i in players:
		var found = loadedPlayers.find(i)
		if found != -1:
			loadedPlayerInstances[found].get_child(0).change_color_to_ready(fullDict[i])
	for i in loadedPlayers:
		if players.count(i) > 0:
			players.erase(i)
	for i in players:
		var PodiumPlayerInstance = podiumPlayer.instance()
		PodiumPlayerInstance.global_translate(Vector3(0,0,len(loadedPlayers)*PodiumPlayerWidth))
		add_child(PodiumPlayerInstance)
		loadedPlayers.append(i)
		loadedPlayerInstances.append(PodiumPlayerInstance)
		print(loadedPlayers)


func _on_Button_toggled(button_pressed):
	MultiplayerNode.isReady = button_pressed
	MultiplayerNode.send_lobby_message()
