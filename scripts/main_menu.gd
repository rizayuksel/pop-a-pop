extends Control

const TOTAL_LEVELS = 16
const MENU_BALLOON_SCENE = preload("res://scenes/ui/menu_balloon.tscn")

@onready var play_button = $VBoxContainer/Row1/PlayButton
@onready var level_select_button = $VBoxContainer/Row1/LevelSelectButton
@onready var settings_button = $VBoxContainer/Row2/SettingsButton
@onready var credits_button = $VBoxContainer/Row2/CreditsButton
@onready var quit_button = $VBoxContainer/Row3/QuitButton
@onready var balloon_timer = $Timer

func _ready():
	MusicManager.play_menu_music()
	
	play_button.pressed.connect(_on_play_pressed)
	level_select_button.pressed.connect(_on_level_select_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	credits_button.pressed.connect(_on_credits_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	balloon_timer.timeout.connect(_on_spawn_balloon)

func get_latest_level() -> int:
	var latest = 1
	for i in range(1, TOTAL_LEVELS + 1):
		if i > 1 and SaveManager.get_level_stars("level_" + str(i - 1)) > 0:
			latest = i
	return latest

func _on_play_pressed():
	var latest_level = get_latest_level()
	var level_path = "res://scenes/levels/level_" + str(latest_level) + ".tscn"
	
	if ResourceLoader.exists(level_path):
		TransitionManager.transition_to_scene(level_path)
	else:
		print("Scene not found: ", level_path)

func _on_level_select_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/level_select_horizontal.tscn")

func _on_settings_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/settings_menu.tscn")

func _on_credits_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/credits_screen.tscn")

func _on_quit_pressed():
	get_tree().quit()

func _on_spawn_balloon():
	var balloon = MENU_BALLOON_SCENE.instantiate()
	
	var screen_width = get_viewport_rect().size.x
	var random_x = randf_range(50.0, screen_width - 50.0)
	var spawn_y = get_viewport_rect().size.y + 50.0
	
	balloon.position = Vector2(random_x, spawn_y)
	
	var colors = [
		Color("8A9A5B"),
		Color("87CEEB"),
		Color("E35335"),
		Color("F4C430"),
		Color("F8C8DC"),
		Color("DA70D6"),
		Color("F5DEB3")
	]
	balloon.modulate = colors.pick_random()
	
	add_child(balloon)
	move_child(balloon, 0)
