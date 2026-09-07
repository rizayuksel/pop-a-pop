extends TextureButton

@onready var lock_icon = $LockIcon
@onready var star_label = $StarLabel
@onready var number_label = $LevelNumberLabel

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
		modulate = Color(0.3, 0.3, 0.3, 1.0)
		lock_icon.visible = true
		star_label.visible = false
	else:
		disabled = false
		modulate = Color(1.0, 1.0, 1.0, 1.0)
		lock_icon.visible = false
		star_label.visible = true
		
		var star_text = ""
		for i in range(3):
			if i < earned_stars:
				star_text += "★"
			else:
				star_text += "☆"
		star_label.text = star_text
