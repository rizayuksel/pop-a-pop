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

func is_level_unlocked(level_id: String) -> bool:
	if level_id == "1":
		return true

	var prev_level = str(int(level_id) - 1)
	if save_data["levels"].has(prev_level) and save_data["levels"][prev_level]["stars"] > 0:
		return true

	if save_data["levels"].has(level_id) and save_data["levels"][level_id].has("unlocked"):
		return save_data["levels"][level_id]["unlocked"]
		
	return false
