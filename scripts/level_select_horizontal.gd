extends Control

const TOTAL_LEVELS = 16
var level_card_scene = preload("res://scenes/ui/level_card_polaroid.tscn")

@onready var level_container = $ScrollContainer/MarginContainer/LevelContainer
@onready var next_theme_btn = $NextThemeButton
@onready var prev_theme_btn = $PrevThemeButton
@onready var home_btn = $HomeButton
@onready var scroll_container = $ScrollContainer
@onready var parallax_bg = $ParallaxBackground

func _ready():
	prev_theme_btn.hide()
	
	home_btn.pressed.connect(_on_home_pressed)
	next_theme_btn.pressed.connect(_on_next_theme_pressed)
	prev_theme_btn.pressed.connect(_on_prev_theme_pressed)
	
	_animate_arrows()
	generate_level_map()

func generate_level_map():
	for i in range(TOTAL_LEVELS):
		var level_num = i + 1
		
		var wrapper = VBoxContainer.new()
		wrapper.alignment = BoxContainer.ALIGNMENT_CENTER
		wrapper.mouse_filter = Control.MOUSE_FILTER_PASS 
		level_container.add_child(wrapper)
		
		var spacer = Control.new()
		spacer.custom_minimum_size = Vector2(0, 120) 
		spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE 
		
		if level_num % 2 == 1:
			wrapper.add_child(spacer)
			
		var card = level_card_scene.instantiate()
		wrapper.add_child(card)
		
		if level_num % 2 == 0:
			wrapper.add_child(spacer)
			
		var level_key = "level_" + str(level_num)
		var is_unlocked = SaveManager.is_level_unlocked(level_key)
		var earned_stars = SaveManager.get_level_stars(level_key)
		
		var is_boss_level = (level_num == TOTAL_LEVELS)
		card.setup(level_num, is_unlocked, earned_stars, is_boss_level)
		
		if is_unlocked:
			card.pressed.connect(_on_level_pressed.bind(level_num))

func _animate_arrows():
	var tween = create_tween().set_loops()
	tween.tween_property(next_theme_btn, "position:x", next_theme_btn.position.x + 15, 0.6).set_trans(Tween.TRANS_SINE)
	tween.tween_property(next_theme_btn, "position:x", next_theme_btn.position.x, 0.6).set_trans(Tween.TRANS_SINE)
	
	var tween2 = create_tween().set_loops()
	tween2.tween_property(prev_theme_btn, "position:x", prev_theme_btn.position.x - 15, 0.6).set_trans(Tween.TRANS_SINE)
	tween2.tween_property(prev_theme_btn, "position:x", prev_theme_btn.position.x, 0.6).set_trans(Tween.TRANS_SINE)

func _on_next_theme_pressed():
	next_theme_btn.disabled = true

	var tween = create_tween()
	tween.tween_property(next_theme_btn, "position:x", next_theme_btn.position.x + 300, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)

	await tween.finished
	get_tree().change_scene_to_file("res://scenes/ui/coming_soon.tscn")

func _on_prev_theme_pressed():
	pass

func _on_home_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")

func _on_level_pressed(level_num: int):
	TransitionManager.transition_to_scene("res://scenes/levels/level_" + str(level_num) + ".tscn")

func _process(_delta):
	if scroll_container and parallax_bg:
		parallax_bg.scroll_offset.x = -scroll_container.scroll_horizontal * 0.9172
