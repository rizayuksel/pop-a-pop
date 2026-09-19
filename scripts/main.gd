extends Node2D

@export var level_arrows: int = 5
@export var star_targets: Array[int] = [3, 4, 5]
@export var next_level_scene: PackedScene
@export var level_id: String = "level_1"

@onready var ui = $UI
@onready var bow = $Bow

func _ready():
	setup_background()
	
	MusicManager.play_level_music()
	bow.arrow_shot.connect(_on_bow_arrow_shot)
	ui.next_level_requested.connect(_on_next_level_requested)
	ui.level_completed.connect(_on_level_completed)
	
	var balloon_count = get_tree().get_nodes_in_group("balloons").size()
	ui.setup_level(balloon_count, level_arrows, star_targets)
	
	bow.is_active = ui.arrows_left > 0
	print(level_id, " için cihazda kayıtlı yıldız: ", SaveManager.get_level_stars(level_id))

func setup_background():
	var current_level_num = level_id.trim_prefix("level_").to_int()
	var bg_texture = null

	if current_level_num <= 20:
		bg_texture = preload("res://assets/textures/BgLevel1.jpg")
		
	if bg_texture:
		var bg_canvas = CanvasLayer.new()
		bg_canvas.layer = -1
		
		var bg_rect = TextureRect.new()
		bg_rect.texture = bg_texture
		bg_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		bg_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		bg_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
		
		bg_rect.modulate = Color(0.7, 0.7, 0.7, 1.0)
		
		bg_canvas.add_child(bg_rect)
		add_child(bg_canvas)

func _on_bow_arrow_shot():
	ui.use_arrow()
	if ui.arrows_left <= 0:
		bow.is_active = false
		
		await get_tree().create_timer(5.0).timeout

		if not ui.is_level_finished:
			if ui.earned_stars > 0:
				ui.show_level_complete()
			else:
				ui.show_game_over()

func _on_next_level_requested():
	if next_level_scene != null:
		get_tree().change_scene_to_packed(next_level_scene)

func _on_level_completed():
	bow.is_active = false
	SaveManager.save_level_progress(level_id, ui.earned_stars)
