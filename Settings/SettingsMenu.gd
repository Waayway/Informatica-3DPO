extends Control

signal exit_settings

## Utilities
@onready var fullscreenToggle: Button = $Container/Utilities/Fullscreen/FullscreenToggle

## FPS Lock
@onready var FpsLimitLabel = $Container/Performance/FpsLimitLabel
@onready var FpsLimitSlider = $Container/Performance/FpsLimit/FpsLimitSlider

## Vsync
@onready var VsyncToggle = $Container/Performance/Vsync/VsyncToggle

## Resolution
@onready var Resolution540P = $"Container/Performance/Resolution/540P"
@onready var Resolution720P = $"Container/Performance/Resolution/720P"
@onready var Resolution1080P = $"Container/Performance/Resolution/1080P"
@onready var Resolution1440P = $"Container/Performance/Resolution/1440P"
@onready var Resolution4K = $"Container/Performance/Resolution/4K"
@onready var ResolutionNative = $"Container/Performance/Resolution/Native"


## Sound
@onready var MasterAudioSlider = $Container/Sound/MasterAudioHBox/MasterAudioSlider
@onready var MusicAudioSlider = $Container/Sound/MusicAudioHbox/MusicAudioSlider
@onready var SoundfxSlider = $Container/Sound/SoundfxHbox/SoundfxSlider

## SoundFX
@onready var SliderSoundFX = $Audio/SliderSoundChange

func _ready():
	fullscreenToggle.button_pressed = Settings.fullscreen
	FpsLimitSlider.value = Settings.fps_limit
	_on_FpsLimitSlider_value_changed(Settings.fps_limit)
	VsyncToggle.button_pressed = Settings.vsync
	if Settings.resolution == Settings.Resolution.RES_540:
		Resolution540P.button_pressed = true
	elif Settings.resolution == Settings.Resolution.RES_720:
		Resolution720P.button_pressed = true
	elif Settings.resolution == Settings.Resolution.RES_1080:
		Resolution1080P.button_pressed = true
	elif Settings.resolution == Settings.Resolution.RES_1440:
		Resolution1440P.button_pressed = true
	elif Settings.resolution == Settings.Resolution.RES_4k:
		Resolution4K.button_pressed = true
	elif Settings.resolution == Settings.Resolution.NATIVE:
		ResolutionNative.button_pressed = true
	
	## Sound
	MasterAudioSlider.value = Settings.master_audio
	MusicAudioSlider.value = Settings.music
	SoundfxSlider.value = Settings.sound_effects

func _on_Settings_visibility_changed():
	_ready()

func _on_ExitButton_pressed():
	self.hide()
	emit_signal("exit_settings")
	Settings.save_settings()

func _on_ApplyButton_pressed():
	var res_button_pressed = $Container/Performance/Resolution/Native.group.get_pressed_button().text
	if res_button_pressed == "540P":
		Settings.resolution = Settings.Resolution.RES_540
	elif res_button_pressed == "720P":
		Settings.resolution = Settings.Resolution.RES_720
	elif res_button_pressed == "1080P":
		Settings.resolution = Settings.Resolution.RES_1080
	elif res_button_pressed == "1440P":
		Settings.resolution = Settings.Resolution.RES_1440
	elif res_button_pressed == "4K":
		Settings.resolution = Settings.Resolution.RES_4k
	elif res_button_pressed == "Native":
		Settings.resolution = Settings.Resolution.NATIVE
	Settings.apply_settings()

func _on_FullscreenToggle_toggled(button_pressed):
	ProjectSettings.set("display/window/size/fullscreen", button_pressed)
	Settings.fullscreen = button_pressed

func _on_VsyncToggle_toggled(button_pressed):
	Settings.vsync = button_pressed

func _on_FpsLimitSlider_value_changed(value):
	var textToAdd = str(value)
	if value == 0:
		textToAdd = "Display Limit"
	FpsLimitLabel.text = "Fps Limit: "+ textToAdd
	Settings.fps_limit = value

func set_text_on_value(node: Label, value):
	node.text = (str(value)+"%") if value != -1 else "Muted"

func _on_MasterAudioSlider_value_changed(value):
	set_text_on_value($Container/Sound/MasterAudioHBox/PercentageNumberLabel,value)
	Settings.master_audio = value
	Settings.apply_sound_settings()
	if !SliderSoundFX.playing:
		SliderSoundFX.play()

func _on_MusicAudioSlider_value_changed(value):
	set_text_on_value($Container/Sound/MusicAudioHbox/PercentageNumberLabel,value)
	Settings.music = value
	Settings.apply_sound_settings()
	if !SliderSoundFX.playing:
		SliderSoundFX.play()
	
func _on_SoundfxSlider_value_changed(value):
	set_text_on_value($Container/Sound/SoundfxHbox/PercentageNumberLabel,value)
	Settings.sound_effects = value
	Settings.apply_sound_settings()
	if !SliderSoundFX.playing:
		SliderSoundFX.play()
