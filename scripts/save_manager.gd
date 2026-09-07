extends Node

const SAVE_PATH = "user://save_data.json"

var save_data: Dictionary = {
	"levels": {} 
}

func _ready():
	load_game()

func save_game():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(save_data)
		file.store_line(json_string)
		file.close()

func load_game():
	if not FileAccess.file_exists(SAVE_PATH):
		return
		
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var error = json.parse(json_string)
		if error == OK:
			save_data = json.data

func save_level_progress(level_id: String, stars: int):
	if not save_data["levels"].has(level_id):
		save_data["levels"][level_id] = {"stars": 0, "unlocked": true}
		
	if stars > save_data["levels"][level_id]["stars"]:
		save_data["levels"][level_id]["stars"] = stars
		
	save_game()

func get_level_stars(level_id: String) -> int:
	if save_data["levels"].has(level_id):
		return int(save_data["levels"][level_id]["stars"])
	return 0
