extends Node

@onready var menu_music = $MenuMusic
@onready var level_music = $LevelMusic1

func play_menu_music():
	if not menu_music.playing:
		level_music.stop()
		menu_music.play()

func play_level_music():
	if not level_music.playing:
		menu_music.stop()
		level_music.play()
