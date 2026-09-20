extends Button

@onready var screenshot = $ColorRect/LevelScreenshot
@onready var star1 = $StarsContainer/Star1
@onready var star2 = $StarsContainer/Star2
@onready var star3 = $StarsContainer/Star3
@onready var number_label = $LevelNumberLabel

var level_num: int = 1
var star_empty = preload("res://assets/textures/StarEmpty.png")
var star_full = preload("res://assets/textures/Star1.png")

func setup(num: int, is_unlocked: bool, earned_stars: int, is_boss_level: bool):
	level_num = num
	
	if level_num == 1:
		is_unlocked = true

	if number_label:
		number_label.text = str(level_num)
	
	if is_unlocked:
		disabled = false
		var ss_path = "res://assets/textures/levels/thumbnails/level_" + str(level_num) + "_thumb.webp"
		if ResourceLoader.exists(ss_path):
			screenshot.texture = load(ss_path)
			
		star1.texture = star_full if earned_stars >= 1 else star_empty
		star2.texture = star_full if earned_stars >= 2 else star_empty
		star3.texture = star_full if earned_stars >= 3 else star_empty
		
		if is_boss_level:
			modulate = Color(1.2, 1.0, 1.0)
		else:
			modulate = Color(1.0, 1.0, 1.0)
	else:
		disabled = true
		star1.texture = star_empty
		star2.texture = star_empty
		star3.texture = star_empty
		modulate = Color(0.5, 0.5, 0.5)
