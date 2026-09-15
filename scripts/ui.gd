extends CanvasLayer

signal next_level_requested
signal level_completed

@onready var arrows_label = $BaseControl/ArrowsLabel
@onready var level_progress_label = $BaseControl/LevelProgressLabel
@onready var star_progress_label = $BaseControl/StarProgressLabel

@onready var game_over_panel = $BaseControl/GameOverPanel
@onready var restart_button = $BaseControl/GameOverPanel/RestartButton

@onready var level_complete_panel = $BaseControl/LevelCompletePanel
@onready var home_button = $BaseControl/LevelCompletePanel/HBoxContainer/HomeButton
@onready var success_restart_button = $BaseControl/LevelCompletePanel/HBoxContainer/SuccessRestartButton
@onready var next_level_button = $BaseControl/LevelCompletePanel/HBoxContainer/NextLevelButton
@onready var final_stars_label = $BaseControl/LevelCompletePanel/FinalStarsLabel

var arrows_left = 0
var popped_balloons = 0
var total_balloons = 0
var star_targets: Array[int] = []
var earned_stars = 0
var is_level_finished = false

func _ready():
	restart_button.pressed.connect(_on_restart_pressed)
	next_level_button.pressed.connect(_on_next_level_pressed)
	success_restart_button.pressed.connect(_on_restart_pressed)
	home_button.pressed.connect(_on_home_pressed)

func setup_level(total: int, arrows: int, targets: Array[int]):
	total_balloons = total
	arrows_left = arrows
	star_targets = targets
	popped_balloons = 0
	earned_stars = 0
	is_level_finished = false
	update_ui()

func add_popped_balloon():
	if is_level_finished:
		return
		
	popped_balloons += 1
	update_ui()
	
	if popped_balloons >= total_balloons:
		show_level_complete()

func use_arrow() -> bool:
	if arrows_left > 0:
		arrows_left -= 1
		update_ui()
		return true
	return false

func calculate_stars() -> int:
	var stars = 0
	for target in star_targets:
		if popped_balloons >= target:
			stars += 1
	return stars

func update_ui():
	arrows_label.text = str(arrows_left)
	level_progress_label.text = str(popped_balloons) + "/" + str(total_balloons)
	
	earned_stars = calculate_stars()
	
	var star_text = ""
	for i in range(3):
		if i < earned_stars:
			star_text += "★"
		else:
			star_text += "☆"
	star_progress_label.text = star_text

func show_game_over():
	if not is_level_finished:
		is_level_finished = true
		game_over_panel.visible = true

func show_level_complete():
	if not is_level_finished:
		is_level_finished = true
		
		# Format stars for the final panel
		var final_star_text = ""
		for i in range(3):
			if i < earned_stars:
				final_star_text += "★"
			else:
				final_star_text += "☆"
		
		final_stars_label.text = final_star_text
		level_complete_panel.visible = true
		level_completed.emit()

func _on_restart_pressed():
	get_tree().reload_current_scene()

func _on_next_level_pressed():
	next_level_requested.emit()

func _on_home_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func play_laser_sound():
	$LaserSound.play()
