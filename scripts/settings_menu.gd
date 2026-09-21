extends Control

const MENU_BALLOON_SCENE = preload("res://scenes/ui/menu_balloon.tscn")

@onready var music_slider = $VBoxContainer/HBoxContainer/MusicSlider
@onready var sfx_slider = $VBoxContainer/HBoxContainer2/SfxSlider
@onready var home_button = $HomeButton
@onready var balloon_timer = $Timer

var music_bus: int
var sfx_bus: int

func _ready():
	music_bus = AudioServer.get_bus_index("Music")
	sfx_bus = AudioServer.get_bus_index("SFX")
	
	music_slider.value = db_to_linear(AudioServer.get_bus_volume_db(music_bus))
	sfx_slider.value = db_to_linear(AudioServer.get_bus_volume_db(sfx_bus))
	
	music_slider.value_changed.connect(_on_music_value_changed)
	sfx_slider.value_changed.connect(_on_sfx_value_changed)
	home_button.pressed.connect(_on_home_pressed)
	
	balloon_timer.timeout.connect(_on_spawn_balloon)
	balloon_timer.start()

func _on_music_value_changed(value: float):
	AudioServer.set_bus_volume_db(music_bus, linear_to_db(value))

func _on_sfx_value_changed(value: float):
	AudioServer.set_bus_volume_db(sfx_bus, linear_to_db(value))

func _on_home_pressed():
	var current_music = db_to_linear(AudioServer.get_bus_volume_db(music_bus))
	var current_sfx = db_to_linear(AudioServer.get_bus_volume_db(sfx_bus))
	
	SaveManager.save_audio_settings(current_music, current_sfx)
	
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")

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
