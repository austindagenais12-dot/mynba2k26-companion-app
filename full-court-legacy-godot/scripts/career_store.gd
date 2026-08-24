extends RefCounted

const SAVE_PATH := "user://full_court_legacy_career.json"

static func default_profile() -> Dictionary:
	return {
		"player_name": "ROOKIE",
		"position": "PG",
		"team": "Lakeshore Raptors",
		"jersey_number": 7,
		"overall": 60,
		"xp": 0,
		"sessions_played": 0,
		"career_points": 0,
		"field_goals_made": 0,
		"field_goals_attempted": 0
	}

static func load_profile() -> Dictionary:
	var profile := default_profile()
	if not FileAccess.file_exists(SAVE_PATH):
		return profile

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return profile

	var parsed = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		for key in profile.keys():
			if parsed.has(key):
				profile[key] = parsed[key]
	return profile

static func save_profile(profile: Dictionary) -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_warning("Career save could not be opened for writing.")
		return
	file.store_string(JSON.stringify(profile, "\t"))

