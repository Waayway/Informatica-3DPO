extends Control

signal exit_settings

func _ready():
	$VBoxContainer/Fullscreen/FullscreenToggle.pressed = OS.window_fullscreen

func _on_Button_pressed():
	self.hide()
	emit_signal("exit_settings")

func _on_FullscreenToggle_toggled(button_pressed):
	OS.window_fullscreen = button_pressed

