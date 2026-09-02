extends CanvasLayer

signal next_level_requested
signal level_completed # Yöneticimize oyunun kazanıldığını haber vermek için

@onready var arrows_label = $BaseControl/ArrowsLabel
@onready var level_progress_label = $BaseControl/LevelProgressLabel
@onready var star_progress_label = $BaseControl/StarProgressLabel

@onready var game_over_panel = $BaseControl/GameOverPanel
@onready var restart_button = $BaseControl/GameOverPanel/RestartButton

@onready var level_complete_panel = $BaseControl/LevelCompletePanel
@onready var home_button = $BaseControl/LevelCompletePanel/HBoxContainer/HomeButton
@onready var success_restart_button = $BaseControl/LevelCompletePanel/HBoxContainer/SuccessRestartButton
@onready var next_level_button = $BaseControl/LevelCompletePanel/HBoxContainer/NextLevelButton

var arrows_left = 0
var popped_balloons = 0
var total_balloons = 0
var next_star_target = 0
var is_level_finished = false # Oyunun bitip bitmediğini takip eden şalter

func _ready():
	restart_button.pressed.connect(_on_restart_pressed)
	next_level_button.pressed.connect(_on_next_level_pressed)
	success_restart_button.pressed.connect(_on_restart_pressed)
	home_button.pressed.connect(_on_home_pressed)

func setup_level(total: int, arrows: int, star_target: int):
	total_balloons = total
	arrows_left = arrows
	next_star_target = star_target
	popped_balloons = 0
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

func update_ui():
	arrows_label.text = str(arrows_left)
	level_progress_label.text = str(popped_balloons) + "/" + str(total_balloons)
	
	var to_next_star = next_star_target - popped_balloons
	if to_next_star > 0:
		star_progress_label.text = str(to_next_star)
	else:
		star_progress_label.text = "★"

func show_game_over():
	if not is_level_finished:
		is_level_finished = true
		game_over_panel.visible = true

func show_level_complete():
	if not is_level_finished:
		is_level_finished = true
		level_complete_panel.visible = true
		level_completed.emit()

func _on_restart_pressed():
	get_tree().reload_current_scene()

func _on_next_level_pressed():
	next_level_requested.emit()

func _on_home_pressed():
	print("Home menu will be loaded here!")
