extends Control

signal exit_settings

onready var settings = get_node("/root/Settings")

## Utilities
onready var fullscreenToggle = $Container/Utilities/Fullscreen/FullscreenToggle

## FPS Lock
onready var FpsLimitLabel = $Container/Performance/FpsLimitLabel
onready var FpsLimitSlider = $Container/Performance/FpsLimit/FpsLimitSlider

## Vsync
onready var VsyncToggle = $Container/Performance/Vsync/VsyncToggle

## Resolution
onready var Resolution540P = $"Container/Performance/Resolution/540P"
onready var Resolution720P = $"Container/Performance/Resolution/720P"
onready var Resolution1080P = $"Container/Performance/Resolution/1080P"
onready var Resolution1440P = $"Container/Performance/Resolution/1440P"
onready var Resolution4K = $"Container/Performance/Resolution/4K"
onready var ResolutionNative = $"Container/Performance/Resolution/Native"


## Sound
onready var MasterAudioSlider = $Container/Sound/MasterAudioHBox/MasterAudioSlider
onready var MusicAudioSlider = $Container/Sound/MusicAudioHbox/MusicAudioSlider
onready var SoundfxSlider = $Container/Sound/SoundfxHbox/SoundfxSlider

## SoundFX
onready var SliderSoundFX = $Audio/SliderSoundChange

func _ready():
	fullscreenToggle.pressed = settings.fullscreen
	FpsLimitSlider.value = settings.fps_limit
	_on_FpsLimitSlider_value_changed(settings.fps_limit)
	VsyncToggle.pressed = settings.vsync
	if settings.resolution == settings.Resolution.RES_540:
		Resolution540P.pressed = true
	elif settings.resolution == settings.Resolution.RES_720:
		Resolution720P.pressed = true
	elif settings.resolution == settings.Resolution.RES_1080:
		Resolution1080P.pressed = true
	elif settings.resolution == settings.Resolution.RES_1440:
		Resolution1440P.pressed = true
	elif settings.resolution == settings.Resolution.RES_4k:
		Resolution4K.pressed = true
	elif settings.resolution == settings.Resolution.NATIVE:
		ResolutionNative.pressed = true
	
	## Sound
	MasterAudioSlider.value = settings.master_audio
	MusicAudioSlider.value = settings.music
	SoundfxSlider.value = settings.sound_effects

func _on_Settings_visibility_changed():
	_ready()

func _on_ExitButton_pressed():
	self.hide()
	emit_signal("exit_settings")
	settings.save_settings()

func _on_ApplyButton_pressed():
	var res_button_pressed = $Container/Performance/Resolution/Native.group.get_pressed_button().text
	if res_button_pressed == "540P":
		settings.resolution = settings.Resolution.RES_540
	elif res_button_pressed == "720P":
		settings.resolution = settings.Resolution.RES_720
	elif res_button_pressed == "1080P":
		settings.resolution = settings.Resolution.RES_1080
	elif res_button_pressed == "1440P":
		settings.resolution = settings.Resolution.RES_1440
	elif res_button_pressed == "4K":
		settings.resolution = settings.Resolution.RES_4k
	elif res_button_pressed == "Native":
		settings.resolution = settings.Resolution.NATIVE
	settings.apply_settings()

func _on_FullscreenToggle_toggled(button_pressed):
	OS.window_fullscreen = button_pressed
	settings.fullscreen = button_pressed

func _on_VsyncToggle_toggled(button_pressed):
	settings.vsync = button_pressed

func _on_FpsLimitSlider_value_changed(value):
	var textToAdd = str(value)
	if value == 0:
		textToAdd = "Display Limit"
	FpsLimitLabel.text = "Fps Limit: "+ textToAdd
	settings.fps_limit = value

func set_text_on_value(node: Label, value):
	node.text = (str(value)+"%") if value != -1 else "Muted"

func _on_MasterAudioSlider_value_changed(value):
	set_text_on_value($Container/Sound/MasterAudioHBox/PercentageNumberLabel,value)
	settings.master_audio = value
	settings.apply_sound_settings()
	if !SliderSoundFX.playing:
		SliderSoundFX.play()

func _on_MusicAudioSlider_value_changed(value):
	set_text_on_value($Container/Sound/MusicAudioHbox/PercentageNumberLabel,value)
	settings.music = value
	settings.apply_sound_settings()
	if !SliderSoundFX.playing:
		SliderSoundFX.play()
	
func _on_SoundfxSlider_value_changed(value):
	set_text_on_value($Container/Sound/SoundfxHbox/PercentageNumberLabel,value)
	settings.sound_effects = value
	settings.apply_sound_settings()
	if !SliderSoundFX.playing:
		SliderSoundFX.play()
