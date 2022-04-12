extends Spatial

onready var MultiplayerNode = get_node("/root/Multiplayer")

var TIMERLABELFORMAT = "%02d:%02d"

var gameTimer: Timer
var dataTimer: Timer

var map: Spatial

func _ready():
	if MultiplayerNode.map_used == 0:
		var mapResource = load("res://Game/Map.tscn")
		map = mapResource.instance()
		add_child(map)
	elif MultiplayerNode.map_used == 1:
		var mapResource = load("res://Game/Map1.tscn")
		map = mapResource.instance()
		add_child(map)
	MultiplayerNode.send_lobbyloaded_message()
	dataTimer = MultiplayerNode.create_data_timer()
	gameTimer = MultiplayerNode.create_game_timer()
	print(gameTimer)
	MultiplayerNode.connect("back_to_lobby",self,"_back_to_lobby")
	MultiplayerNode.connect("spectate", self,"spectate")
	$Control/ColorRect/Timer.connect("timeout",self,"animation_finished")
	if MultiplayerNode.id == MultiplayerNode.seeker:
		$Control/SeekerLabel.text = "You are the Seeker"
		$Control/BlackScreen.show()
		$Player.translation = map.get_node("SeekerSpawn").translation
	else:
		$Control/SeekerLabel.text = MultiplayerNode.playerNames[MultiplayerNode.seeker]+" is the Seeker"
		var possibleSpawnPos = map.get_node("PossibleSpawnPositions").get_children()
		$Player.translation = possibleSpawnPos[randi()%possibleSpawnPos.size()].translation
	$Control/ColorRect/AnimationPlayer.play("SeekerlabelFade")

func _process(_delta):
	if gameTimer:
		var time_left = int(round(gameTimer.time_left))
		var minute_time_left = int(round(time_left/60))
		var seconds_time_left = time_left%60
		
		$Control/Label.text = (TIMERLABELFORMAT % [minute_time_left, seconds_time_left])
	
func _back_to_lobby():
	$Control/ColorRect/AnimationPlayer.play_backwards("SceneTrans")
	$Control/ColorRect/Timer.start()

func animation_finished():
	get_tree().change_scene("res://TransistionScene/TransistionScene.tscn")
	dataTimer.stop()

func spectate():
	$Control/ColorRect/AnimationPlayer.play("FoundAnim")
