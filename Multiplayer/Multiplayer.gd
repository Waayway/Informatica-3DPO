extends Node

export var websocket_url = "ws://localhost:8888/ws"

var _client = WebSocketClient.new()
var dataSendTimer = Timer.new()

var pos = Vector3.ZERO
var rot = Vector3.ZERO

var players: Array
var spawned_players: Array
var instance_players: Dictionary

var MultiplayerPlayer = preload("res://Multiplayer/MultiplayerPlayer.tscn")

func _ready():
	# Connect base signals to get notified of connection open, close, and errors.
	_client.connect("connection_closed", self, "_closed")
	_client.connect("connection_error", self, "_closed")
	_client.connect("connection_established", self, "_connected")
	# This signal is emitted when not using the Multiplayer API every time
	# a full packet is received.
	# Alternatively, you could check get_peer(1).get_available_packets() in a loop.
	_client.connect("data_received", self, "_on_data")
	dataSendTimer.wait_time = 0.01666
	dataSendTimer.autostart = true
	dataSendTimer.connect("timeout",self, "send_data")
	

	# Initiate connection to the given URL.
	var err = _client.connect_to_url(websocket_url)
	
	if err != OK:
		print("Unable to connect")
		set_process(false)
	else:
		add_child(dataSendTimer)

func _closed(was_clean = false):
	# was_clean will tell you if the disconnection was correctly notified
	# by the remote peer before closing the socket.
	print("Closed, clean: ", was_clean)
	set_process(false)

func _connected(proto = ""):
	# This is called on connection, "proto" will be the selected WebSocket
	# sub-protocol (which is optional)
	# print("Connected with protocol: ", proto)
	# You MUST always use get_peer(1).put_packet to send data to server,
	# and not put_packet directly when not using the MultiplayerAPI.
#	_client.get_peer(1).put_packet(JSON.print({"Hello": "World"}).to_utf8())
	pass

func _on_data():
	# Print the received packet, you MUST always use get_peer(1).get_packet
	# to receive data from server, and not get_packet directly when not
	# using the MultiplayerAPI.
	var data = _client.get_peer(1).get_packet().get_string_from_utf8()
	if data.begins_with("{"):
		var p = JSON.parse(data)
		if typeof(p.result) == TYPE_DICTIONARY:
			data = p.result
			for i in data:
				var pos = data[i]["pos"]
				print(pos)
				instance_players[i].transform.origin = Vector3(pos["x"],pos["y"],pos["z"])
				instance_players[i].rotation_degrees = Vector3(rot["x"],rot["y"],rot["z"])
		else:
			push_error("Unexpected results.")
	elif data.begins_with("["):
		var p = JSON.parse(data)
		if typeof(p.result) == TYPE_ARRAY:
			players = p.result
			print("Players: ", players)
			for i in players:
				if not i in spawned_players:
					spawned_players.append(i)
					var playerInstance = MultiplayerPlayer.instance()
					playerInstance.id = i
					add_child(playerInstance)
					instance_players[i] = playerInstance
		else:
			push_error("Unexpected results.")
		

func send_data():
	var data = {"pos": 
		{
			"x": pos.x,
			"y":pos.y,
			"z":pos.z
		},
		"rot": {
			"x": rot.x,
			"y": rot.y,
			"z": rot.z
		}
	}
	_client.get_peer(1).put_packet(JSON.print(data).to_utf8())

func _process(delta):
	# Call this in _process or _physics_process. Data transfer, and signals
	# emission will only happen when calling this function.
	_client.poll()

