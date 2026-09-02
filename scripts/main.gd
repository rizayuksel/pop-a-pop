extends Node2D

@export var level_arrows: int = 5
@export var first_star_target: int = 3
@export var next_level_scene: PackedScene

@onready var ui = $UI
@onready var bow = $Bow

func _ready():
	bow.arrow_shot.connect(_on_bow_arrow_shot)
	ui.next_level_requested.connect(_on_next_level_requested)
	ui.level_completed.connect(_on_level_completed) # Yeni sinyali bağladık
	
	var balloon_count = get_tree().get_nodes_in_group("balloons").size()
	ui.setup_level(balloon_count, level_arrows, first_star_target)
	
	bow.is_active = ui.arrows_left > 0

func _on_bow_arrow_shot():
	ui.use_arrow()
	if ui.arrows_left <= 0:
		bow.is_active = false
		
		# Wait 5 seconds for high-angle shots to land
		await get_tree().create_timer(5.0).timeout
		
		ui.show_game_over()

func _on_next_level_requested():
	if next_level_scene != null:
		get_tree().change_scene_to_packed(next_level_scene)

func _on_level_completed():
	bow.is_active = false
