extends Button

@onready var balloon_image = $BalloonImage
@onready var lock_icon = $LockIcon
@onready var number_label = $LevelNumberLabel
@onready var star1 = $StarsContainer/Star1
@onready var star2 = $StarsContainer/Star2
@onready var star3 = $StarsContainer/Star3

var full_star_tex = preload("res://assets/textures/Star1.png")
var empty_star_tex = preload("res://assets/textures/StarEmpty.png")


var level_id: int = 1
var is_unlocked: bool = false
var earned_stars: int = 0

func setup(id: int, unlocked: bool, stars: int):
	level_id = id
	is_unlocked = unlocked
	earned_stars = stars
	
	number_label.text = str(level_id)
	
	if not is_unlocked:
		disabled = true
		balloon_image.modulate = Color(0.3, 0.3, 0.3, 1.0)
		lock_icon.visible = true
		number_label.visible = false
		$StarsContainer.visible = false
	else:
		disabled = false

		balloon_image.modulate = Color("ee5c42")
		
		lock_icon.visible = false
		number_label.visible = true
		$StarsContainer.visible = true
		
		star1.texture = full_star_tex if earned_stars >= 1 else empty_star_tex
		star2.texture = full_star_tex if earned_stars >= 2 else empty_star_tex
		star3.texture = full_star_tex if earned_stars >= 3 else empty_star_tex
