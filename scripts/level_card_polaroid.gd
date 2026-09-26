extends Button

@onready var screenshot = $ColorRect/LevelScreenshot
@onready var star1 = $StarsContainer/Star1
@onready var star2 = $StarsContainer/Star2
@onready var star3 = $StarsContainer/Star3
@onready var number_label = $LevelNumberLabel
@onready var lock_icon = $LockIcon

var level_num: int = 1
var earned_stars_count: int = 0
var is_level_unlocked: bool = false

var star_empty = preload("res://assets/textures/StarEmpty.png")
var star_full = preload("res://assets/textures/Star1.png")

func setup(num: int, is_unlocked: bool, earned_stars: int, is_boss_level: bool):
	level_num = num
	is_level_unlocked = is_unlocked
	earned_stars_count = earned_stars
	
	if level_num == 1:
		is_level_unlocked = true

	if number_label:
		number_label.text = str(level_num)
		
	if lock_icon:
		lock_icon.visible = not is_level_unlocked
	
	var ss_path = "res://assets/textures/levels/thumbnails/level_" + str(level_num) + "_thumb.webp"
	if ResourceLoader.exists(ss_path):
		screenshot.texture = load(ss_path)
	
	if is_level_unlocked:
		disabled = false
		if is_boss_level:
			modulate = Color(1.4, 1.0, 1.0)
		else:
			modulate = Color(1.0, 1.0, 1.0)
	else:
		disabled = true
		modulate = Color(0.5, 0.5, 0.5)
		
		if lock_icon:
			lock_icon.modulate = Color(1.5, 1.5, 1.5)
			
	_update_stars()

func set_island(island_id: int):
	var star_path = "res://assets/textures/Star" + str(island_id) + ".png"
	if ResourceLoader.exists(star_path):
		star_full = load(star_path)
		
	if lock_icon:
		var lock_path = "res://assets/textures/LevelLock" + str(island_id) + ".png"
		var alt_lock_path = "res://assets/textures/LockIcon" + str(island_id) + ".png"
		
		if ResourceLoader.exists(lock_path):
			lock_icon.texture = load(lock_path)
		elif ResourceLoader.exists(alt_lock_path):
			lock_icon.texture = load(alt_lock_path)

	_update_stars()

func _update_stars():
	if is_level_unlocked:
		star1.texture = star_full if earned_stars_count >= 1 else star_empty
		star2.texture = star_full if earned_stars_count >= 2 else star_empty
		star3.texture = star_full if earned_stars_count >= 3 else star_empty
	else:
		star1.texture = star_empty
		star2.texture = star_empty
		star3.texture = star_empty
