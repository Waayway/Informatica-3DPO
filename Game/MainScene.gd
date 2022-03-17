extends Spatial

onready var MultiplayerNode = get_node("/root/Multiplayer")


var TIMERLABELFORMAT = "%02d:%02d"

var gameTimer: Timer

func _ready():
	MultiplayerNode.send_lobbyloaded_message()
	MultiplayerNode.create_data_timer()
	gameTimer = MultiplayerNode.create_game_timer()
	print(gameTimer)

func _process(_delta):
	if gameTimer:
		var time_left = round(gameTimer.time_left)
		var minute_time_left = round(time_left/60)
		var seconds_time_left = round(time_left-(minute_time_left*60)) 
		
		$Control/Label.text = (TIMERLABELFORMAT % [minute_time_left, seconds_time_left])
