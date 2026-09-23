extends Control

@onready var home_btn = $HomeButton
@onready var prev_theme_btn = $PrevThemeButton

var fade_rect: ColorRect
var touch_start_pos = Vector2.ZERO
var is_dragging = false
var swipe_threshold = 100.0

func _ready():
	home_btn.pressed.connect(_on_home_pressed)
	_setup_fade_overlay()
	
	if prev_theme_btn:
		prev_theme_btn.pressed.connect(_on_prev_theme_pressed)
		_animate_arrow()

func _setup_fade_overlay():
	fade_rect = ColorRect.new()
	fade_rect.color = Color(0, 0, 0, 0)
	fade_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(fade_rect)
	move_child(fade_rect, get_child_count() - 1)

func _animate_arrow():
	var tween = create_tween().set_loops()
	tween.tween_property(prev_theme_btn, "position:x", prev_theme_btn.position.x - 15, 0.6).set_trans(Tween.TRANS_SINE)
	tween.tween_property(prev_theme_btn, "position:x", prev_theme_btn.position.x, 0.6).set_trans(Tween.TRANS_SINE)

func _on_home_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")

func _on_prev_theme_pressed():
	prev_theme_btn.disabled = true

	var tween = create_tween()
	tween.tween_property(prev_theme_btn, "position:x", prev_theme_btn.position.x - 300, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)

	var fade_tween = create_tween()
	fade_tween.tween_property(fade_rect, "color:a", 1.0, 0.25)

	await tween.finished
	
	# Global veya dosya yolu üzerinden yükleyerek target_island değerini ayarlıyoruz
	var level_select_scene = load("res://scenes/ui/level_select_horizontal.tscn").instantiate()
	level_select_scene.current_island = 2
	get_tree().root.add_child(level_select_scene)
	get_tree().current_scene.queue_free()
	get_tree().current_scene = level_select_scene

func _input(event):
	if event is InputEventScreenTouch or (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT):
		if event.pressed:
			touch_start_pos = event.position
			is_dragging = true
		else:
			if is_dragging:
				is_dragging = false
				_check_swipe(event.position)

func _check_swipe(touch_end_pos: Vector2):
	var drag_dist = touch_end_pos.x - touch_start_pos.x
	if drag_dist > swipe_threshold:
		_on_prev_theme_pressed()
