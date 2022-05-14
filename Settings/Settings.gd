extends Node

var settingConfig = preload("res://Settings/SettingConfig.gd")

enum Resolution {
	RES_540 = 0,
	RES_720 = 1,
	RES_1080 = 2,
	RES_1440 = 3,
	RES_4k = 4,
	NATIVE = 5,
}
## Utilities
var fullscreen: bool = true

## Performance
var fps_limit: int = 0 # 0 unlimited
var vsync: bool = true
var resolution: int = Resolution.NATIVE

## Sound, ranges from -24 to 6 db, but in game it will be 0-100%,
## Conversion, (master_audio/(1/3))-24, or if its -1 it will be -80 db
var master_audio: float = 80.0
var sound_effects: float = 80.0
var music: float = 80.0


func _ready():
	load_settings()
	apply_settings()

func _input(event):
	if event.is_action_pressed("toggle_fullscreen"):
		ProjectSettings.set("display/window/size/fullscreen", !ProjectSettings.get("display/window/size/fullscreen"))
		fullscreen = ProjectSettings.get("display/window/size/fullscreen")
		get_tree().set_input_as_handled()

##
## Only the settings that could be applied emmidietly.
##
func apply_settings():
	## Utilities
	ProjectSettings.set("display/window/size/fullscreen", fullscreen)
	
	## Performance
	Engine.target_fps = fps_limit
	ProjectSettings.set("display/window/vsync/vsync_mode", 2 if vsync else 0)
	
	apply_sound_settings()

func apply_sound_settings():
	var onethird: float = 10.0/3.0
	var cur_master_audio = (master_audio/onethird)-24 if master_audio != -1 else -80
	var cur_sound_effects = (sound_effects/onethird)-24 if sound_effects != -1 else -80
	var cur_music = (music/onethird)-24 if music != -1 else -80
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"),cur_master_audio)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SoundEffects"),cur_sound_effects)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"),cur_music)


func load_settings():
	var settings = load("user://settings.tres")
	if not settings:
		return
		
	fullscreen = settings.fullscreen
	fps_limit = settings.fps_limit
	vsync = settings.vsync
	resolution = settings.resolution
	master_audio = settings.master_audio
	sound_effects = settings.sound_effects
	music = settings.music

func save_settings():
	var settings = settingConfig.new()
	
	settings.fullscreen = fullscreen
	settings.fps_limit = fps_limit
	settings.vsync = vsync
	settings.resolution = resolution
	settings.master_audio = master_audio
	settings.sound_effects = sound_effects
	settings.music = music
	
	ResourceSaver.save("user://settings.tres", settings)
