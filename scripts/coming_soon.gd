extends Control

@onready var home_btn = $HomeButton
@onready var prev_theme_btn = $PrevThemeButton

func _ready():
	home_btn.pressed.connect(_on_home_pressed)
	
	if prev_theme_btn:
		prev_theme_btn.pressed.connect(_on_prev_theme_pressed)
		_animate_arrow()

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

	await tween.finished
	get_tree().change_scene_to_file("res://scenes/ui/level_select_horizontal.tscn")
