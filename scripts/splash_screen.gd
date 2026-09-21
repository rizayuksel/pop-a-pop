extends Control

@onready var logo = $TextureRect

func _ready():
	logo.modulate.a = 0.0
	
	var tween = create_tween()
	
	tween.tween_property(logo, "modulate:a", 1.0, 1.5)
	tween.tween_interval(1.5)
	tween.tween_property(logo, "modulate:a", 0.0, 1.5)
	
	await tween.finished
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
