extends Control

const MENU_BALLOON_SCENE = preload("res://scenes/ui/menu_balloon.tscn")

@onready var home_btn = $HomeButton
@onready var prev_island_btn = $PrevThemeButton
@onready var next_island_btn = $NextThemeButton

@onready var island_texture: TextureRect = $VBoxContainer/TextureRect
@onready var progress_bar: TextureProgressBar = $VBoxContainer/CenterContainer/TextureRect/TextureProgressBar
@onready var star_icon: TextureRect = $VBoxContainer/CenterContainer/TextureRect/TextureProgressBar/CenterContainer/HBoxContainer/TextureRect
@onready var progress_label: Label = $VBoxContainer/CenterContainer/TextureRect/TextureProgressBar/CenterContainer/HBoxContainer/Label

var fade_rect: ColorRect
var touch_start_pos = Vector2.ZERO
var is_dragging = false
var swipe_threshold = 100.0

var island_data = [
	{
		"island_id": 2,
		"island_texture": preload("res://assets/textures/SilhouettePirateShip.jpeg"),
		"star_texture": preload("res://assets/textures/Star1.png"),
		"bar_color": Color("#add08d"),
		"max_stars": 25 
	}
]

var current_island_index: int = 0
var prev_original_x: float
var next_original_x: float

func _ready():
	if home_btn:
		home_btn.pressed.connect(_on_home_pressed)
	if prev_island_btn:
		prev_original_x = prev_island_btn.position.x
		prev_island_btn.pressed.connect(_on_prev_pressed)
	if next_island_btn:
		next_original_x = next_island_btn.position.x
		next_island_btn.pressed.connect(_on_next_pressed)
		
	_setup_fade_overlay()
	_animate_arrows()
	update_ui()
	
	$VBoxContainer/CenterContainer.z_index = 2
	if has_node("GameLogo"):
		$GameLogo.z_index = 2
	if home_btn:
		home_btn.z_index = 2
	if prev_island_btn:
		prev_island_btn.z_index = 2
	if next_island_btn:
		next_island_btn.z_index = 2
	
	var balloon_timer = Timer.new()
	balloon_timer.wait_time = 1.5
	add_child(balloon_timer)
	balloon_timer.timeout.connect(_on_spawn_balloon)
	balloon_timer.start()

func _setup_fade_overlay():
	fade_rect = ColorRect.new()
	fade_rect.color = Color(0, 0, 0, 0)
	fade_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade_rect.z_index = 10
	add_child(fade_rect)

func _animate_arrows():
	if next_island_btn:
		var tween1 = create_tween().set_loops()
		tween1.tween_property(next_island_btn, "position:x", next_island_btn.position.x + 15, 0.6).set_trans(Tween.TRANS_SINE)
		tween1.tween_property(next_island_btn, "position:x", next_island_btn.position.x, 0.6).set_trans(Tween.TRANS_SINE)
		
	if prev_island_btn:
		var tween2 = create_tween().set_loops()
		tween2.tween_property(prev_island_btn, "position:x", prev_island_btn.position.x - 15, 0.6).set_trans(Tween.TRANS_SINE)
		tween2.tween_property(prev_island_btn, "position:x", prev_island_btn.position.x, 0.6).set_trans(Tween.TRANS_SINE)

func update_ui() -> void:
	var data = island_data[current_island_index]
	
	var current_stars = 0
	var levels_to_check = (data["island_id"] - 1) * 16
	
	for i in range(1, levels_to_check + 1):
		current_stars += int(SaveManager.get_level_stars("level_" + str(i)))
	
	if island_texture: 
		island_texture.texture = data["island_texture"]
		
	star_icon.texture = data["star_texture"]
	progress_bar.tint_progress = data["bar_color"]
	progress_bar.max_value = data["max_stars"]
	progress_bar.value = current_stars
	progress_label.text = str(current_stars) + " / " + str(data["max_stars"])

	prev_island_btn.visible = true
	next_island_btn.visible = true

func _on_home_pressed():
	_change_scene("res://scenes/ui/main_menu.tscn")

func _on_prev_pressed():
	if prev_island_btn:
		prev_island_btn.disabled = true
		var tween = create_tween()
		tween.tween_property(prev_island_btn, "position:x", prev_island_btn.position.x - 300, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)

	if current_island_index > 0:
		current_island_index -= 1
		_play_transition_effect()
	else:
		_change_scene("res://scenes/ui/level_select_horizontal.tscn")

func _on_next_pressed():
	if next_island_btn:
		next_island_btn.disabled = true
		var tween = create_tween()
		tween.tween_property(next_island_btn, "position:x", next_island_btn.position.x + 300, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)

	if current_island_index < island_data.size() - 1:
		current_island_index += 1
		_play_transition_effect()
	else:
		_change_scene("res://scenes/ui/coming_soon.tscn")

func _play_transition_effect():
	var fade_tween = create_tween()
	fade_tween.tween_property(fade_rect, "color:a", 1.0, 0.2)
	await fade_tween.finished
	
	update_ui()
	
	if prev_island_btn:
		prev_island_btn.position.x = prev_original_x
		prev_island_btn.disabled = false
	if next_island_btn:
		next_island_btn.position.x = next_original_x
		next_island_btn.disabled = false
	
	var fade_in = create_tween()
	fade_in.tween_property(fade_rect, "color:a", 0.0, 0.2)

func _input(event):
	if event is InputEventScreenTouch or (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT):
		if event.pressed:
			touch_start_pos = event.position
			is_dragging = true
		else:
			if is_dragging:
				is_dragging = false
				_check_swipe(event.position)

func _check_swipe(touch_end_pos: Vector2):
	var drag_dist = touch_end_pos.x - touch_start_pos.x
	if abs(drag_dist) > swipe_threshold:
		if drag_dist > 0:
			_on_prev_pressed()
		else:
			_on_next_pressed()

func _change_scene(path: String):
	var fade_tween = create_tween()
	fade_tween.tween_property(fade_rect, "color:a", 1.0, 0.25)
	await fade_tween.finished
	get_tree().change_scene_to_file(path)

func _on_spawn_balloon():
	var balloon = MENU_BALLOON_SCENE.instantiate()
	
	var screen_width = get_viewport_rect().size.x
	var random_x = randf_range(50.0, screen_width - 50.0)
	var spawn_y = get_viewport_rect().size.y + 50.0
	
	balloon.position = Vector2(random_x, spawn_y)
	
	var colors = [
		Color("8A9A5B"), Color("87CEEB"), Color("E35335"),
		Color("F4C430"), Color("F8C8DC"), Color("DA70D6"), Color("F5DEB3")
	]
	balloon.modulate = colors.pick_random()
	
	balloon.z_index = 1
	add_child(balloon)
