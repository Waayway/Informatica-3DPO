extends Spatial

onready var MultiplayerNode = get_node("/root/Multiplayer")

func _ready():
	MultiplayerNode.send_lobbyloaded_message()
	MultiplayerNode.create_data_timer()
