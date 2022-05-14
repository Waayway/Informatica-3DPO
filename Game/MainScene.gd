extends Node3D

var TIMERLABELFORMAT = "%02d:%02d"

var gameTimer: Timer
var dataTimer: Timer

var map: Node3D

func _ready():
	if multiplayer.map_used == 0:
		var mapResource = load("res://Game/Map.tscn")
		map = mapResource.instance()
		add_child(map)
	elif multiplayer.map_used == 1:
		var mapResource = load("res://Game/Map1.tscn")
		map = mapResource.instance()
		add_child(map)
	multiplayer.send_lobbyloaded_message()
	dataTimer = multiplayer.create_data_timer()
	gameTimer = multiplayer.create_game_timer()
	multiplayer.connect("back_to_lobby", _back_to_lobby)
	multiplayer.connect("spectate", spectate)
	$Control/ColorRect/Timer.connect("timeout", animation_finished)
	if multiplayer.id == multiplayer.seeker:
		$Control/SeekerLabel.text = "You are the Seeker"
		$Control/BlackScreen.show()
		$Player.translation = map.get_node("SeekerSpawn").translation
	else:
		$Control/SeekerLabel.text = multiplayer.playerNames[multiplayer.seeker]+" is the Seeker"
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
