extends Node

@onready var menu_music = $MenuMusic
@onready var level_music_1 = $LevelMusic1
@onready var level_music_2 = $LevelMusic2

func play_menu_music():
	level_music_1.stop()
	level_music_2.stop()
	menu_music.volume_db = 0.0
	if not menu_music.playing:
		menu_music.play()

func play_music(theme_name: String):
	menu_music.stop()
	
	if theme_name == "theme_2":
		level_music_1.stop()
		level_music_2.volume_db = 0.0
		if not level_music_2.playing:
			level_music_2.play()
	else:
		level_music_2.stop()
		level_music_1.volume_db = 0.0
		if not level_music_1.playing:
			level_music_1.play()

func fade_out_music(duration: float = 2.0):
	var tween = create_tween()
	if level_music_1.playing:
		tween.tween_property(level_music_1, "volume_db", -80.0, duration)
	elif level_music_2.playing:
		tween.tween_property(level_music_2, "volume_db", -80.0, duration)
