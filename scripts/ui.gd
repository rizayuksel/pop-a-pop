extends CanvasLayer

@onready var arrows_label = $BaseControl/ArrowsLabel
@onready var level_progress_label = $BaseControl/LevelProgressLabel
@onready var star_progress_label = $BaseControl/StarProgressLabel
@onready var next_arrow_icon = $BaseControl/NextArrowIcon

var arrows_left = 10
var popped_balloons = 0
var total_balloons = 20
var next_star_target = 5

func _ready():
	update_ui()

func setup_level(total, arrows, first_star_target):
	total_balloons = total
	arrows_left = arrows
	next_star_target = first_star_target
	popped_balloons = 0
	update_ui()

func add_popped_balloon():
	popped_balloons += 1
	update_ui()

func use_arrow():
	if arrows_left > 0:
		arrows_left -= 1
		update_ui()
		return true
	return false

func update_ui():
	arrows_label.text = "Arrows: " + str(arrows_left)
	level_progress_label.text = "Balloons: " + str(popped_balloons) + "/" + str(total_balloons)
	
	var to_next_star = next_star_target - popped_balloons
	if to_next_star > 0:
		star_progress_label.text = "Next Star: " + str(to_next_star)
	else:
		star_progress_label.text = "Max Stars!"
