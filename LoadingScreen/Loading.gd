extends Control

onready var loading_progress: ProgressBar = $VBoxContainer/ProgressBar

func _ready():
	pass
	
func _process(delta):
	if Multiplayer.players_done_loading != 0:
		loading_progress.value = 100/len(Multiplayer.players)*Multiplayer.players_done_loading
	if loading_progress.value == 100:
		self.hide()
		set_process(false)
		
