extends Spatial

onready var podiumPlayer = preload("res://Lobby/Podium.tscn")
var loadedPlayers: Array = []

var PodiumPlayerWidth = 0.9*2


func _ready():
	get_node("/root/Multiplayer").connect("lobby_new_player", self,"lobby_new_players")

func lobby_new_players(players: Array):
	for i in loadedPlayers:
		if players.count(i) > 0:
			players.erase(i)
	for i in players:
		var PodiumPlayerInstance = podiumPlayer.instance()
		PodiumPlayerInstance.global_transform.origin.x = len(loadedPlayers)*PodiumPlayerWidth
		add_child(PodiumPlayerInstance)
