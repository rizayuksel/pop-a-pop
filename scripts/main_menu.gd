extends Control

const TOTAL_LEVELS = 20

@onready var play_button = $VBoxContainer/PlayButton
@onready var level_select_button = $VBoxContainer/LevelSelectButton
@onready var quit_button = $VBoxContainer/QuitButton

func _ready():
	play_button.pressed.connect(_on_play_pressed)
	level_select_button.pressed.connect(_on_level_select_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func get_latest_level() -> int:
	var latest = 1
	for i in range(1, TOTAL_LEVELS + 1):
		if i > 1 and SaveManager.get_level_stars("level_" + str(i - 1)) > 0:
			latest = i
	return latest

func _on_play_pressed():
	var latest_level = get_latest_level()
	var level_path = "res://scenes/level_" + str(latest_level) + ".tscn"
	
	# Check if the scene file exists before loading
	if ResourceLoader.exists(level_path):
		get_tree().change_scene_to_file(level_path)
	else:
		print("Scene not found: ", level_path)

func _on_level_select_pressed():
	get_tree().change_scene_to_file("res://scenes/level_select.tscn")

func _on_quit_pressed():
	get_tree().quit()
