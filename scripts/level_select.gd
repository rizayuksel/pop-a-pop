extends Control

const TOTAL_LEVELS = 20
const LEVELS_PER_PAGE = 10
const COLUMNS = 2
const MENU_BALLOON_SCENE = preload("res://scenes/ui/menu_balloon.tscn")

var current_page = 0
var total_pages = 0
var pages: Array = []
var touch_start_pos = Vector2.ZERO
var left_btn_start_pos = Vector2.ZERO
var right_btn_start_pos = Vector2.ZERO

@onready var pages_container = $PagesContainer
@onready var left_btn = $LeftButton
@onready var right_btn = $RightButton
@onready var home_btn = $HomeButton
@onready var balloon_timer = $Timer

var level_btn_scene = preload("res://scenes/ui/level_button.tscn")

func _ready():
	MusicManager.play_menu_music()
	
	left_btn.pressed.connect(prev_page)
	right_btn.pressed.connect(next_page)
	home_btn.pressed.connect(_on_home_pressed)
	balloon_timer.timeout.connect(_on_spawn_balloon)
	balloon_timer.start()

	left_btn_start_pos = left_btn.position
	right_btn_start_pos = right_btn.position
	
	total_pages = ceil(float(TOTAL_LEVELS) / LEVELS_PER_PAGE)
	generate_pages()
	auto_focus_page()
	
	if current_page == 0:
		left_btn.position = left_btn_start_pos + Vector2(-200, 0)
	if current_page == total_pages - 1:
		right_btn.position = right_btn_start_pos + Vector2(200, 0)
		
	update_ui()

func generate_pages():
	var highest_unlocked = 1

	for p in range(total_pages):
		var grid = GridContainer.new()
		grid.columns = COLUMNS
		grid.add_theme_constant_override("h_separation", 30)
		grid.add_theme_constant_override("v_separation", 30)
		grid.visible = false
		pages_container.add_child(grid)
		pages.append(grid)
		
		for i in range(LEVELS_PER_PAGE):
			var level_num = (p * LEVELS_PER_PAGE) + i + 1
			if level_num > TOTAL_LEVELS:
				break
				
			var btn = level_btn_scene.instantiate()
			
			grid.add_child(btn)
			
			var is_unlocked = (level_num == 1)
			if level_num > 1:
				var prev_stars = SaveManager.get_level_stars("level_" + str(level_num - 1))
				is_unlocked = (prev_stars > 0)
				if is_unlocked:
					highest_unlocked = level_num
			
			var stars = SaveManager.get_level_stars("level_" + str(level_num))
			
			btn.setup(level_num, is_unlocked, stars)
			
			if is_unlocked:
				btn.pressed.connect(_on_level_pressed.bind(level_num))

func auto_focus_page():
	var highest_unlocked = 1
	for i in range(1, TOTAL_LEVELS + 1):
		if i > 1 and SaveManager.get_level_stars("level_" + str(i - 1)) > 0:
			highest_unlocked = i

	current_page = floor((highest_unlocked - 1) / LEVELS_PER_PAGE)

func update_ui():
	for i in range(pages.size()):
		pages[i].visible = (i == current_page)
		
	var left_tween = create_tween()
	if current_page == 0:
		left_tween.tween_property(left_btn, "position", left_btn_start_pos + Vector2(-200, 0), 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	else:
		left_tween.tween_property(left_btn, "position", left_btn_start_pos, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		
	var right_tween = create_tween()
	if current_page == total_pages - 1:
		right_tween.tween_property(right_btn, "position", right_btn_start_pos + Vector2(200, 0), 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	else:
		right_tween.tween_property(right_btn, "position", right_btn_start_pos, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func next_page():
	if current_page < total_pages - 1:
		var tween = create_tween()
		tween.tween_property(right_btn, "position", right_btn_start_pos + Vector2(15, 0), 0.1)
		tween.tween_property(right_btn, "position", right_btn_start_pos, 0.1)
		
		await tween.finished 
		
		current_page += 1
		update_ui()

func prev_page():
	if current_page > 0:
		var tween = create_tween()
		tween.tween_property(left_btn, "position", left_btn_start_pos + Vector2(-15, 0), 0.1)
		tween.tween_property(left_btn, "position", left_btn_start_pos, 0.1)
		
		await tween.finished 
		
		current_page -= 1
		update_ui()

func _input(event):
	if event is InputEventScreenTouch or event is InputEventMouseButton:
		if event.pressed:
			touch_start_pos = event.position
		else:
			var swipe_dist = event.position.x - touch_start_pos.x
			if swipe_dist > 100:
				prev_page()
			elif swipe_dist < -100:
				next_page()

func _on_level_pressed(level_num: int):
	TransitionManager.transition_to_scene("res://scenes/levels/level_" + str(level_num) + ".tscn")

func _on_home_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")

func _on_spawn_balloon():
	var balloon = MENU_BALLOON_SCENE.instantiate()
	
	var screen_width = get_viewport_rect().size.x
	var random_x = randf_range(50.0, screen_width - 50.0)
	var screen_height = get_viewport_rect().size.y
	var spawn_y = screen_height + 50.0
	
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
	move_child(balloon, 1)
