extends Node

signal lobby_new_player(players, data)
signal change_to_game
signal back_to_lobby

signal death # will emit when someone was found
signal spectate # will emit when u are found

#default websocket_url
export var websocket_url = "ws://localhost:8888/ws"
var default_url = ""

#WebsocketClients and if it is connected so you can check before sending any data
var _client = WebSocketClient.new()
var isClientConnected: bool = false
#Timer for sending data 30 times a second see _ready() for connecting and setting data
var dataSendTimer: Timer = Timer.new()

#player data, will get inserted via the Player.gd
var pos = Vector3.ZERO
var rot = Vector3.ZERO
var vel = Vector3.ZERO
var anim: int = 0
var anim_reversed: bool = false

#Basic data only username will be changed via a different script
var username: String = ""
var id: String = ""

#LobbyData is the player ready or not.
var isReady: bool = false

#Data for moving players around.
var players: Array
var playerNames: Dictionary
var spawned_players: Array
var instance_players: Dictionary

var players_done_loading: int

#Timer Data for ingame timer so you can load timer after the fact
var timerStartTime: int = 0
var timerTotalTime: int = 0

# To be able to get the id from the firstMessage
var firstMessage: bool = true

# Thing for spawning multiplayer players.
var MultiplayerPlayer = preload("res://Multiplayer/MultiplayerPlayer.tscn")

var gameOverData = {}
var seeker = ""
var self_seeker = false
var players_found = []

var map_used = 0

func reset():
	isReady = false
	seeker = ""
	dataSendTimer.queue_free()
	dataSendTimer = Timer.new()
	for i in instance_players.keys():
		instance_players[i].queue_free()
	instance_players.clear()
	spawned_players.clear()
	
func _ready():
	set_process(false)
	# Connect base signals to get notified of connection open, close, and errors.
	_client.connect("connection_closed", self, "_closed")
	_client.connect("connection_error", self, "_closed")
	_client.connect("connection_established", self, "_connected")
	# This signal is emitted when not using the Multiplayer API every time
	# a full packet is received.
	# Alternatively, you could check get_peer(1).get_available_packets() in a loop.
	_client.connect("data_received", self, "_on_data")


func start_connection(url: String = ""):
	# Initiate connection to the given URL.
	if url == "" and default_url == "":
		url = websocket_url
	elif default_url != "":
		url = default_url
	else:
		default_url = url
	var err = _client.connect_to_url(url)
	
	if err != OK:
		print("Unable to connect")
		set_process(false)
	else:
		isClientConnected = true
		set_process(true)

func stop_connection():
	_client.disconnect_from_host()

func _closed(was_clean = false):
	# was_clean will tell you if the disconnection was correctly notified
	# by the remote peer before closing the socket.
	print("Closed, clean: ", was_clean)
	isClientConnected = false
	set_process(false)

func _connected(_proto = ""):
	pass

func _on_data():
	var data = _client.get_peer(1).get_packet().get_string_from_utf8()
	if firstMessage:
		id = data
		firstMessage = false
		send_first_message()
	elif data.begins_with("0"):
		get_lobby_data(JSON.parse(data.substr(1)).result)
	elif data.begins_with("2"):
		var message = JSON.parse(data.substr(1)).result
		players_done_loading = message["playersdoneloading"]
		players = message["players"]
		playerNames = message["playerNames"]
		timerStartTime = message["timer"]
		timerTotalTime = message["totalTime"]
		seeker = message["chosenplayer"]
		print_debug(seeker)
		self_seeker = seeker == id
		emit_signal("change_to_game")
	elif data.begins_with("3"):
		var message = JSON.parse(data.substr(1)).result
		players_done_loading = message["playersdoneloading"]
	elif data.begins_with("4"):
		var message = JSON.parse(data.substr(1)).result
		process_vel_data(message)
	elif data.begins_with("5"):
		var message = JSON.parse(data.substr(1)).result
		gameOverData = message
		emit_signal("back_to_lobby")
	elif data.begins_with("6"):
		players_found.append(data.substr(1))
		if data.substr(1) == id:
			emit_signal("spectate")
		else:
			emit_signal("death")
			instance_players[data.substr(1)].queue_free()
			instance_players.erase(data.substr(1))

func process_vel_data(data: Dictionary):
	var keys = data.keys()
	var notYetSpawnedPlayers: Array = []
	for i in keys:
		if not i in spawned_players:
			notYetSpawnedPlayers.append(i)
	for i in notYetSpawnedPlayers:
		var instance = MultiplayerPlayer.instance()
		instance.id = i
		instance.username = playerNames[i]
		if instance.id == seeker:
			instance.isSeeker = true
			print(instance.isSeeker)
		self.add_child(instance)
		instance_players[i] = instance
		spawned_players.append(i)
	
	for i in keys:
		if i in instance_players:
			instance_players[i].apply_data(data[i])

func get_lobby_data(data: Dictionary):
	var list = data["players"].keys()
	emit_signal("lobby_new_player", list, data)

func send_lobby_message():
	_client.get_peer(1).put_packet(('0{"'+id+'": '+str(isReady).to_lower()+'}').to_utf8())

func send_lobbyloaded_message():
	_client.get_peer(1).put_packet(("2true").to_utf8())

func send_timer_timeout():
	_client.get_peer(1).put_packet("1timer".to_utf8())

func send_first_message():
	var data = {
		"name": username,
		"prefered_map": map_used
	}
	_client.get_peer(1).put_packet(JSON.print(data).to_utf8())

func send_velocityData():
	var data = {
		"pos": {
			"x": pos.x,
			"y": pos.y,
			"z": pos.z
		},
		"rot": {
			"x": rot.x,
			"y": rot.y,
			"z": rot.z
		},
		"vel": {
			"x": vel.x,
			"y": vel.y,
			"z": vel.z
		},
		"anim": {
			"num": anim,
			"reversed": anim_reversed
		},
	}
	_client.get_peer(1).put_packet(("4"+JSON.print(data)).to_utf8())


func _send_timer_timeout():
	_client.get_peer(1).put_packet("1gametimer".to_utf8())

func send_player_found(id):
	var data = {"playerFound": id}
	_client.get_peer(1).put_packet(("5"+JSON.print(data)).to_utf8())

func create_data_timer():
	dataSendTimer.wait_time = 1.0/30
	dataSendTimer.autostart = true
	dataSendTimer.one_shot = false
	dataSendTimer.connect("timeout", self, "send_velocityData")
	self.add_child(dataSendTimer)
	return dataSendTimer

func create_game_timer():
	var timer: Timer = Timer.new()
	timer.wait_time = timerTotalTime-timerStartTime
	timer.autostart = true
	timer.one_shot = true
	timer.connect("timeout",self,"_send_timer_timeout")
	self.add_child(timer)
	return timer

func _process(_delta):
	# Call this in _process or _physics_process. Data transfer, and signals
	# emission will only happen when calling this function.
	_client.poll()
