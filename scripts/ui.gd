extends CanvasLayer

signal next_level_requested
signal level_completed

enum ArrowType { NORMAL, GHOST, CANNONBALL }
var current_arrow_type: ArrowType = ArrowType.NORMAL

@onready var next_arrow_icon = $BaseControl/TopBarContainer/NextArrowIcon
@onready var arrows_label = $BaseControl/TopBarContainer/ArrowsLabel
@onready var level_progress_label = $BaseControl/TopBarContainer/LevelProgressLabel
@onready var pause_button = $BaseControl/TopBarContainer/PauseButton

@onready var star1_icon = $BaseControl/TopBarContainer/StarsContainer/Star1
@onready var star2_icon = $BaseControl/TopBarContainer/StarsContainer/Star2
@onready var star3_icon = $BaseControl/TopBarContainer/StarsContainer/Star3

@onready var star1_label = $BaseControl/TopBarContainer/StarsContainer/Star1/Label
@onready var star2_label = $BaseControl/TopBarContainer/StarsContainer/Star2/Label
@onready var star3_label = $BaseControl/TopBarContainer/StarsContainer/Star3/Label

@onready var pause_background = $BaseControl/PauseBackground
@onready var resume_button = $BaseControl/PauseBackground/PausePanel/HBoxContainer/ResumeButton
@onready var pause_restart_button = $BaseControl/PauseBackground/PausePanel/HBoxContainer/RestartButton
@onready var pause_home_button = $BaseControl/PauseBackground/PausePanel/HBoxContainer/HomeButton

@onready var game_over_background = $BaseControl/GameOverBackground
@onready var game_over_panel = $BaseControl/GameOverBackground/GameOverPanel
@onready var restart_button = $BaseControl/GameOverBackground/GameOverPanel/HBoxContainer/RestartButton
@onready var game_over_home_button = $BaseControl/GameOverBackground/GameOverPanel/HBoxContainer/HomeButton

@onready var game_over_next_btn = $BaseControl/GameOverBackground/GameOverPanel/HBoxContainer/NextButton
@onready var game_over_star1 = $BaseControl/GameOverBackground/GameOverPanel/HBoxContainer/NextButton/BestStarsContainer/Star1
@onready var game_over_star2 = $BaseControl/GameOverBackground/GameOverPanel/HBoxContainer/NextButton/BestStarsContainer/Star2
@onready var game_over_star3 = $BaseControl/GameOverBackground/GameOverPanel/HBoxContainer/NextButton/BestStarsContainer/Star3

@onready var level_complete_background = $BaseControl/LevelCompleteBackground
@onready var level_complete_panel = $BaseControl/LevelCompleteBackground/LevelCompletePanel
@onready var home_button = $BaseControl/LevelCompleteBackground/LevelCompletePanel/HBoxContainer/HomeButton
@onready var success_restart_button = $BaseControl/LevelCompleteBackground/LevelCompletePanel/HBoxContainer/SuccessRestartButton
@onready var next_level_button = $BaseControl/LevelCompleteBackground/LevelCompletePanel/HBoxContainer/NextLevelButton

@onready var final_star1 = $BaseControl/LevelCompleteBackground/LevelCompletePanel/FinalStarsContainer/FinalStar1
@onready var final_star2 = $BaseControl/LevelCompleteBackground/LevelCompletePanel/FinalStarsContainer/FinalStar2
@onready var final_star3 = $BaseControl/LevelCompleteBackground/LevelCompletePanel/FinalStarsContainer/FinalStar3

var full_star_tex = preload("res://assets/textures/Star1.png")
var empty_star_tex = preload("res://assets/textures/StarEmpty.png")

var tex_arrow_normal = preload("res://assets/textures/UiArrow.png")
var tex_arrow_ghost = preload("res://assets/textures/UiGhostArrow.png")
var tex_arrow_cannon = preload("res://assets/textures/UiCannonBall.png")

var arrows_left = 0
var popped_balloons = 0
var total_balloons = 0
var star_targets: Array[int] = []
var earned_stars = 0
var is_level_finished = false
var shake_tween: Tween

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	var current_scene = get_tree().current_scene
	if current_scene and current_scene.get("level_id") != null:
		var current_level_num = current_scene.level_id.trim_prefix("level_").to_int()
		if current_level_num >= 17:
			full_star_tex = preload("res://assets/textures/Star2.png")
		else:
			full_star_tex = preload("res://assets/textures/Star1.png")
			
	pause_background.visible = false
	game_over_background.visible = false
	level_complete_background.visible = false
	
	restart_button.pressed.connect(_on_restart_pressed)
	next_level_button.pressed.connect(_on_next_level_pressed)
	game_over_next_btn.pressed.connect(_on_next_level_pressed)
	success_restart_button.pressed.connect(_on_restart_pressed)
	home_button.pressed.connect(_on_home_pressed)
	game_over_home_button.pressed.connect(_on_home_pressed)
	
	pause_button.pressed.connect(_on_pause_pressed)
	resume_button.pressed.connect(_on_resume_pressed)
	pause_restart_button.pressed.connect(_on_restart_pressed)
	pause_home_button.pressed.connect(_on_home_pressed)

func setup_level(total: int, arrows: int, targets: Array[int]):
	total_balloons = total
	arrows_left = arrows
	star_targets = targets
	popped_balloons = 0
	earned_stars = 0
	is_level_finished = false

	equip_normal_arrow()
	update_ui()

func add_popped_balloon():
	if is_level_finished:
		return
		
	popped_balloons += 1
	update_ui()
	
	if popped_balloons >= total_balloons:
		if earned_stars > 0:
			show_level_complete()
		else:
			show_game_over()

func use_arrow() -> bool:
	if arrows_left > 0:
		arrows_left -= 1
		update_ui()

		if current_arrow_type != ArrowType.NORMAL:
			equip_normal_arrow()
			
		return true
	return false

func equip_normal_arrow():
	current_arrow_type = ArrowType.NORMAL
	_update_arrow_icon()

func equip_ghost_arrow():
	current_arrow_type = ArrowType.GHOST
	_update_arrow_icon()

func equip_cannonball():
	current_arrow_type = ArrowType.CANNONBALL
	_update_arrow_icon()

func _update_arrow_icon():
	if not next_arrow_icon:
		return
		
	match current_arrow_type:
		ArrowType.NORMAL:
			next_arrow_icon.texture = tex_arrow_normal
		ArrowType.GHOST:
			next_arrow_icon.texture = tex_arrow_ghost
		ArrowType.CANNONBALL:
			next_arrow_icon.texture = tex_arrow_cannon

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
	
	star1_icon.texture = full_star_tex if earned_stars >= 1 else empty_star_tex
	star2_icon.texture = full_star_tex if earned_stars >= 2 else empty_star_tex
	star3_icon.texture = full_star_tex if earned_stars >= 3 else empty_star_tex
	
	star1_label.text = ""
	star2_label.text = ""
	star3_label.text = ""
	
	if earned_stars == 0 and star_targets.size() > 0:
		star1_label.text = str(star_targets[0] - popped_balloons)
	elif earned_stars == 1 and star_targets.size() > 1:
		star2_label.text = str(star_targets[1] - popped_balloons)
	elif earned_stars == 2 and star_targets.size() > 2:
		star3_label.text = str(star_targets[2] - popped_balloons)

func _on_pause_pressed():
	if not is_level_finished:
		get_tree().paused = true
		pause_background.visible = true

func _on_resume_pressed():
	get_tree().paused = false
	pause_background.visible = false

func show_game_over():
	if not is_level_finished:
		is_level_finished = true
		
		var save_key = "level_1"
		var current_scene = get_tree().current_scene
		
		if current_scene.get("level_id") != null:
			save_key = current_scene.level_id
		else:
			var path = current_scene.scene_file_path
			if path:
				save_key = path.get_file().get_basename()
		
		var previous_stars = int(SaveManager.get_level_stars(save_key))
		
		game_over_star1.texture = full_star_tex if previous_stars >= 1 else empty_star_tex
		game_over_star2.texture = full_star_tex if previous_stars >= 2 else empty_star_tex
		game_over_star3.texture = full_star_tex if previous_stars >= 3 else empty_star_tex
		
		if previous_stars == 0:
			game_over_next_btn.disabled = true
			game_over_next_btn.modulate = Color(0.4, 0.4, 0.4, 0.9)
		else:
			game_over_next_btn.disabled = false
			game_over_next_btn.modulate = Color(1.0, 1.0, 1.0, 1.0)
		
		await get_tree().create_timer(0.3).timeout
		game_over_background.visible = true

func show_level_complete():
	if not is_level_finished:
		is_level_finished = true
		
		final_star1.texture = full_star_tex if earned_stars >= 1 else empty_star_tex
		final_star2.texture = full_star_tex if earned_stars >= 2 else empty_star_tex
		final_star3.texture = full_star_tex if earned_stars >= 3 else empty_star_tex
		
		await get_tree().create_timer(1.5).timeout
		level_complete_background.visible = true
		level_completed.emit()

func _on_restart_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_next_level_pressed():
	get_tree().paused = false
	next_level_requested.emit()

func _on_home_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")

func play_laser_sound():
	if has_node("LaserSound"):
		$LaserSound.play()

func play_fire_sound():
	if has_node("FireSound"):
		$FireSound.play()

func play_ice_sound():
	if has_node("IceSound"):
		$IceSound.play()

func shake_camera(intensity: float = 12.0, duration: float = 0.25):
	var camera = get_viewport().get_camera_2d()
	if not camera:
		return
		
	if shake_tween:
		shake_tween.kill()
		
	shake_tween = create_tween()
	var step_time = duration / 5.0
	
	for i in range(4):
		var random_offset = Vector2(randf_range(-intensity, intensity), randf_range(-intensity, intensity))
		shake_tween.tween_property(camera, "offset", random_offset, step_time)
		
	shake_tween.tween_property(camera, "offset", Vector2.ZERO, step_time)

func play_ice_hit_sound():
	if has_node("IceHitSound"):
		$IceHitSound.play()

func play_pop_sound():
	if has_node("PopSound"):
		$PopSound.play()

func play_shoot_sound():
	if has_node("ShootSound"):
		$ShootSound.play()

func play_spike_sound():
	if has_node("SpikeSound"):
		$SpikeSound.play()

func play_bouncer_sound():
	if has_node("BouncerSound"):
		$BouncerSound.play()
