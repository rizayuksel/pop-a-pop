extends Node2D

@onready var anim_player = $AnimationPlayer

func _ready():
	MusicManager.fade_out_music(2.0)
	anim_player.play("travel")
	anim_player.animation_finished.connect(_on_animation_finished)

func _on_animation_finished(anim_name):
	if anim_name == "travel":
		get_tree().change_scene_to_file("res://scenes/levels/level_17.tscn")
