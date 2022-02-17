extends Node

signal lobby_new_player(players, data)

#default websocket_url
export var websocket_url = "ws://localhost:8888/ws"

#WebsocketClients and if it is connected so you can check before sending any data
var _client = WebSocketClient.new()
var isClientConnected: bool = false
#Timer for sending data 30 times a second see _ready() for connecting and setting data
var dataSendTimer: Timer = Timer.new()

#player data, will get inserted via the Player.gd
var pos = Vector3.ZERO
var rot = Vector3.ZERO
var vel = Vector3.ZERO

#Basic data only username will be changed via a different script
var username: String = ""
var id: String = ""

#LobbyData is the player ready or not.
var isReady: bool = false

#Data for moving players around.
var players: Array
var spawned_players: Array
var instance_players: Dictionary

# To be able to get the id from the firstMessage
var firstMessage: bool = true

# Thing for spawning multiplayer players.
var MultiplayerPlayer = preload("res://Multiplayer/MultiplayerPlayer.tscn")

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
	
	# Set a timer for sending date 30 times a second
	dataSendTimer.wait_time = 1.0/30.0
	dataSendTimer.autostart = true
	dataSendTimer.connect("timeout",self, "send_data")

func start_connection(url: String = ""):
	# Initiate connection to the given URL.
	if url == "":
		url = websocket_url
	var err = _client.connect_to_url(url)
	
	if err != OK:
		print("Unable to connect")
		set_process(false)
	else:
		isClientConnected = true
		set_process(true)

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
		print(id)
		firstMessage = false
	if data.begins_with("0"):
		get_lobby_data(JSON.parse(data.substr(1)).result)

func get_lobby_data(data: Dictionary):
	var list = data.keys()
	emit_signal("lobby_new_player", list, data)

func send_lobby_message():
	print(isReady)
	_client.get_peer(1).put_packet(('0{"'+id+'": '+str(isReady).to_lower()+'}').to_utf8())

func send_first_message():
	var data = {
		"name": username
	}
	_client.get_peer(1).put_packet(JSON.print(data).to_utf8())

func send_velocityData():
	var data = {
		"pos": {
			"x": pos.x,
			"y":pos.y,
			"z":pos.z
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
		}
	}
	_client.get_peer(1).put_packet(("1"+JSON.print(data)).to_utf8())

func _process(_delta):
	# Call this in _process or _physics_process. Data transfer, and signals
	# emission will only happen when calling this function.
	_client.poll()
