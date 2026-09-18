extends CanvasLayer

@onready var color_rect = $ColorRect
@onready var animation_player = $AnimationPlayer
@onready var sfx_player = $AudioStreamPlayer

func transition_to_scene(target_scene_path: String):
	color_rect.mouse_filter = Control.MOUSE_FILTER_STOP

	var tween = create_tween()
	tween.tween_property(MusicManager.menu_music, "volume_db", -30.0, 0.5)

	sfx_player.play()

	animation_player.play("fade_out")
	await animation_player.animation_finished

	get_tree().change_scene_to_file(target_scene_path)

	animation_player.play("fade_in")

	var tween_in = create_tween()
	tween_in.tween_property(MusicManager.menu_music, "volume_db", 0.0, 0.5)

	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
