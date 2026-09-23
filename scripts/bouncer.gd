extends StaticBody2D

@onready var sprite = $Sprite2D
@onready var hit_detector = $HitDetector

var original_scale: Vector2

func _ready():
	original_scale = sprite.scale
	hit_detector.body_entered.connect(_on_hit_detector_body_entered)

func _on_hit_detector_body_entered(body):
	if body is RigidBody2D:
		if body.name.begins_with("Ghost") or body.scene_file_path.contains("ghost_arrow"):
			return
			
		play_bounce_effect()

func play_bounce_effect():
	var tween = create_tween()
	tween.tween_property(sprite, "scale", original_scale * Vector2(1.1, 0.5), 0.05)
	tween.tween_property(sprite, "scale", original_scale, 0.3).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

	var main_scene = get_tree().current_scene
	if main_scene.has_node("UI") and main_scene.get_node("UI").has_method("play_bouncer_sound"):
		main_scene.get_node("UI").play_bouncer_sound()
