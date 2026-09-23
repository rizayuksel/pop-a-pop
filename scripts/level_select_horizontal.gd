extends Control

const TOTAL_LEVELS = 16
const MAX_ISLANDS = 2
const MENU_BALLOON_SCENE = preload("res://scenes/ui/menu_balloon.tscn")
var level_card_scene = preload("res://scenes/ui/level_card_polaroid.tscn")

static var target_island = 1

var current_island = 1
var is_transitioning = false
var touch_start_pos = Vector2.ZERO
var is_dragging = false
var swipe_threshold = 100.0
var fade_rect: ColorRect

@onready var level_container = $ScrollContainer/MarginContainer/LevelContainer
@onready var next_island_btn = $NextThemeButton
@onready var prev_island_btn = $PrevThemeButton
@onready var home_btn = $HomeButton
@onready var scroll_container = $ScrollContainer
@onready var parallax_bg = $ParallaxBackground

func _ready():
	current_island = target_island
	
	home_btn.pressed.connect(_on_home_pressed)
	next_island_btn.pressed.connect(_on_next_island_pressed)
	prev_island_btn.pressed.connect(_on_prev_island_pressed)
	
	_setup_fade_overlay()
	_animate_arrows()
	_update_ui_for_island()
	generate_level_map()
	
	var balloon_timer = Timer.new()
	balloon_timer.wait_time = 1.5
	balloon_timer.autostart = true
	add_child(balloon_timer)
	balloon_timer.timeout.connect(_on_spawn_balloon)

func _setup_fade_overlay():
	fade_rect = ColorRect.new()
	fade_rect.color = Color(0, 0, 0, 0)
	fade_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(fade_rect)
	move_child(fade_rect, get_child_count() - 1)

func generate_level_map():
	for child in level_container.get_children():
		child.queue_free()
		
	for i in range(TOTAL_LEVELS):
		var level_num = ((current_island - 1) * TOTAL_LEVELS) + i + 1
		
		var wrapper = VBoxContainer.new()
		wrapper.alignment = BoxContainer.ALIGNMENT_CENTER
		wrapper.mouse_filter = Control.MOUSE_FILTER_PASS 
		level_container.add_child(wrapper)
		
		var spacer = Control.new()
		spacer.custom_minimum_size = Vector2(0, 120) 
		spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE 
		
		if i % 2 == 1:
			wrapper.add_child(spacer)
			
		var card = level_card_scene.instantiate()
		wrapper.add_child(card)
		
		if i % 2 == 0:
			wrapper.add_child(spacer)
			
		var level_key = "level_" + str(level_num)
		var is_unlocked = false
		
		if level_num == 1:
			is_unlocked = true
		else:
			var prev_key = "level_" + str(level_num - 1)
			var prev_stars = int(SaveManager.get_level_stars(prev_key))
			is_unlocked = (prev_stars > 0)
			
		var earned_stars = int(SaveManager.get_level_stars(level_key))
		var is_boss_level = (i == TOTAL_LEVELS - 1)
		
		card.setup(level_num, is_unlocked, earned_stars, is_boss_level)
		if card.has_method("set_island"):
			card.set_island(current_island)
		
		if is_unlocked:
			if not card.pressed.is_connected(_on_level_pressed):
				card.pressed.connect(_on_level_pressed.bind(level_num))

func change_island(target: int, swipe_direction: int):
	if is_transitioning: return
	
	if target < 1:
		return
		
	is_transitioning = true
	
	# Önce ekran kararsın, kilitler de dahil kararması için fade ile uyumlu yapıyoruz
	var fade_tween = create_tween()
	fade_tween.tween_property(fade_rect, "color:a", 1.0, 0.2)
	
	# Kilit ikonlarını da ekranla birlikte karartalım
	for card in level_container.get_children():
		for child in card.get_children():
			if child.has_node("LockIcon"):
				var l_icon = child.get_node("LockIcon")
				var card_tween = create_tween()
				card_tween.tween_property(l_icon, "modulate:a", 0.0, 0.2)
				
	await fade_tween.finished
	
	if target > MAX_ISLANDS:
		target_island = MAX_ISLANDS
		get_tree().change_scene_to_file("res://scenes/ui/coming_soon.tscn")
		return
	
	current_island = target
	target_island = current_island
	_update_ui_for_island()
	generate_level_map()
	
	await get_tree().process_frame 
	
	var scroll_bar = scroll_container.get_h_scroll_bar()
	if swipe_direction == 1:
		scroll_bar.value = 0
	else:
		scroll_bar.value = scroll_bar.max_value
		
	var unfade_tween = create_tween()
	unfade_tween.tween_property(fade_rect, "color:a", 0.0, 0.2)
	
	for card in level_container.get_children():
		for child in card.get_children():
			if child.has_node("LockIcon"):
				var l_icon = child.get_node("LockIcon")
				l_icon.modulate.a = 0.0
				var card_tween = create_tween()
				card_tween.tween_property(l_icon, "modulate:a", 1.0, 0.2)
				
	await unfade_tween.finished
	
	is_transitioning = false

func _update_ui_for_island():
	prev_island_btn.visible = (current_island > 1)
	
	var bg_container = parallax_bg.get_node_or_null("ParallaxLayer/BgContainer")
	if bg_container:
		var tr1 = bg_container.get_node_or_null("TextureRect")
		var tr2 = bg_container.get_node_or_null("TextureRect2")
		var tr3 = bg_container.get_node_or_null("TextureRect3")
		var tr4 = bg_container.get_node_or_null("TextureRect4")
		
		if current_island == 2:
			if tr1: tr1.texture = load("res://assets/textures/LevelSelectBg2.1.webp")
			if tr2: tr2.texture = load("res://assets/textures/LevelSelectBg2.2.webp")
			if tr3: tr3.texture = load("res://assets/textures/LevelSelectBg2.3.webp")
			if tr4: tr4.texture = load("res://assets/textures/LevelSelectBg2.4.webp")
		else:
			if tr1: tr1.texture = load("res://assets/textures/LevelSelectBg1.1.webp")
			if tr2: tr2.texture = load("res://assets/textures/LevelSelectBg1.2.webp")
			if tr3: tr3.texture = load("res://assets/textures/LevelSelectBg1.3.webp")
			if tr4: tr4.texture = load("res://assets/textures/LevelSelectBg1.4.webp")

func _on_next_island_pressed():
	if is_transitioning: return
	next_island_btn.disabled = true

	var tween = create_tween()
	tween.tween_property(next_island_btn, "position:x", next_island_btn.position.x + 300, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)

	await tween.finished
	next_island_btn.position.x -= 300 
	next_island_btn.disabled = false
	
	change_island(current_island + 1, 1)

func _on_prev_island_pressed():
	if is_transitioning: return
	prev_island_btn.disabled = true

	var tween = create_tween()
	tween.tween_property(prev_island_btn, "position:x", prev_island_btn.position.x - 300, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)

	await tween.finished
	prev_island_btn.position.x += 300 
	prev_island_btn.disabled = false
	
	change_island(current_island - 1, -1)

func _input(event):
	if event is InputEventScreenTouch or (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT):
		if event.pressed:
			touch_start_pos = event.position
			is_dragging = true
		else:
			if is_dragging:
				is_dragging = false
				_check_overscroll(event.position)

func _check_overscroll(touch_end_pos: Vector2):
	if is_transitioning: return
	
	var scroll_bar = scroll_container.get_h_scroll_bar()
	var drag_dist = touch_end_pos.x - touch_start_pos.x
	
	if scroll_bar.value >= scroll_bar.max_value - scroll_bar.page and drag_dist < -swipe_threshold:
		_on_next_island_pressed()
	elif scroll_bar.value <= 0 and drag_dist > swipe_threshold:
		if current_island > 1:
			_on_prev_island_pressed()

func _animate_arrows():
	var tween = create_tween().set_loops()
	tween.tween_property(next_island_btn, "position:x", next_island_btn.position.x + 15, 0.6).set_trans(Tween.TRANS_SINE)
	tween.tween_property(next_island_btn, "position:x", next_island_btn.position.x, 0.6).set_trans(Tween.TRANS_SINE)
	
	var tween2 = create_tween().set_loops()
	tween2.tween_property(prev_island_btn, "position:x", prev_island_btn.position.x - 15, 0.6).set_trans(Tween.TRANS_SINE)
	tween2.tween_property(prev_island_btn, "position:x", prev_island_btn.position.x, 0.6).set_trans(Tween.TRANS_SINE)

func _on_home_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")

func _on_level_pressed(level_num: int):
	TransitionManager.transition_to_scene("res://scenes/levels/level_" + str(level_num) + ".tscn")

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
	
	add_child(balloon)
	move_child(balloon, 0)

func _process(_delta):
	if scroll_container and parallax_bg:
		parallax_bg.scroll_offset.x = -scroll_container.scroll_horizontal * 0.9172
