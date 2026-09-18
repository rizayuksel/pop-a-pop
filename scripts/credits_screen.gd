extends Control

const MENU_BALLOON_SCENE = preload("res://scenes/ui/menu_balloon.tscn")

@onready var home_button = $HomeButton
@onready var balloon_timer = $Timer

func _ready():
	home_button.pressed.connect(_on_home_pressed)
	balloon_timer.timeout.connect(_on_spawn_balloon)
	balloon_timer.start()

func _on_home_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")

func _on_spawn_balloon():
	var balloon = MENU_BALLOON_SCENE.instantiate()
	
	var screen_width = get_viewport_rect().size.x
	var random_x = randf_range(50.0, screen_width - 50.0)
	var spawn_y = get_viewport_rect().size.y + 50.0
	
	balloon.position = Vector2(random_x, spawn_y)
	
	var colors = [
		Color("8A9A5B"), # Green
		Color("87CEEB"), # Blue
		Color("E35335"), # Red
		Color("F4C430"), # Yellow
		Color("F8C8DC"), # Pink
		Color("DA70D6"), # Purple
		Color("F5DEB3")  # Brown
	]
	balloon.modulate = colors.pick_random()
	
	add_child(balloon)
	move_child(balloon, 0)
