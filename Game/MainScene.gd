extends Spatial

onready var MultiplayerNode = get_node("/root/Multiplayer")
onready var world_enviroment: WorldEnvironment = $Map/WorldEnvironment

var TIMERLABELFORMAT = "%02d:%02d"

var gameTimer: Timer
var dataTimer: Timer

func _ready():
	MultiplayerNode.send_lobbyloaded_message()
	dataTimer = MultiplayerNode.create_data_timer()
	gameTimer = MultiplayerNode.create_game_timer()
	print(gameTimer)
	MultiplayerNode.connect("back_to_lobby",self,"_back_to_lobby")
	$Control/ColorRect/Timer.connect("timeout",self,"animation_finished")
	if MultiplayerNode.id == MultiplayerNode.seeker:
		$Control/SeekerLabel.text = "You are the Seeker"
	else:
		$Control/SeekerLabel.text = MultiplayerNode.playerNames[MultiplayerNode.seeker]+" is the Seeker"
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
