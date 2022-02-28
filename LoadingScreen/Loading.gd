extends Control

onready var loading_progress: ProgressBar = $VBoxContainer/ProgressBar

onready var MultiplayerNode = get_node("/root/Multiplayer")

func _ready():
	pass
	
func _process(delta):
	if MultiplayerNode.players_done_loading != 0:
		loading_progress.value = 100/len(MultiplayerNode.players)*MultiplayerNode.players_done_loading
	if loading_progress.value == 100:
		self.hide()
		set_process(false)
		
