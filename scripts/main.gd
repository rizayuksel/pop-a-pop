extends Node2D

@onready var ui = $UI
@onready var bow = $Bow

func _ready():
	bow.arrow_shot.connect(_on_bow_arrow_shot)
	bow.is_active = ui.arrows_left > 0

func _on_bow_arrow_shot():
	ui.use_arrow()
	if ui.arrows_left <= 0:
		bow.is_active = false
