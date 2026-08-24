extends RefCounted
class_name LifeSimulation

const SAVE_PATH := "user://second_draft_save.json"
const SAVE_VERSION := 5
const STAT_KEYS := ["health", "happiness", "smarts", "confidence", "discipline", "reputation"]
const RELATIONSHIP_KEYS := ["family", "friends"]

var data: Dictionary = {}
var pending_event: Dictionary = {}
var recent_event_ids: Array = []
var rng := RandomNumberGenerator.new()


func _init(seed_value: int = -1) -> void:
	if seed_value >= 0:
		rng.seed = seed_value
	else:
		rng.randomize()


func new_life(first_name: String = "", last_name: String = "") -> void:
	var identity := LifeGenerator.generate_identity(rng, first_name, last_name)
	data = {
		"life_seed": int(identity.get("life_seed", rng.randi())),
		"first_name": str(identity.get("first_name", "Alex")),
		"last_name": str(identity.get("last_name", "Morgan")),
		"identity": str(identity.get("identity", "Non-binary person")),
		"pronouns": str(identity.get("pronouns", "they/them")),
		"age": 0,
		"year": 2026,
		"birthplace": str(identity.get("birthplace", "Halifax, Nova Scotia")),
		"birth_month": str(identity.get("birth_month", "January")),
		"birth_day": int(identity.get("birth_day", 1)),
		"background": identity.get("background", {}).duplicate(true),
		"parents": identity.get("parents", []).duplicate(true),
		"siblings": identity.get("siblings", []).duplicate(true),
		"appearance": identity.get("appearance", {}).duplicate(true),
		"alive": true,
		"cause_of_death": "",
		"balance": 0,
		"last_income": 0,
		"last_expenses": 0,
		"job": {},
		"career_years": 0,
		"job_progress": 0,
		"retired": false,
		"part_time": false,
		"education": 0,
		"education_label": "At home",
		"education_path": "",
		"education_program": {},
		"stats": identity.get("stats", {}).duplicate(true),
		"relationships": {
			"family": {"name": "Extended Family", "value": rng.randi_range(60, 90)},
			"friends": {"name": "Friends", "value": rng.randi_range(36, 58)}
		},
		"partner": {},
		"children": [],
		"assets": [],
		"activities_used": [],
		"sports": SportsSystem.new_state(),
		"dynamic_event_count": 0,
		"life_memories": [],
		"work_shift_year": -1,
		"flags": {},
		"history": identity.get("history", []).duplicate(true)
	}
	pending_event = {}
	recent_event_ids.clear()
	save_game()


func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


func age_up() -> Dictionary:
	if data.is_empty() or not bool(data.get("alive", false)) or not pending_event.is_empty():
		return pending_event

	data["age"] = int(data.get("age", 0)) + 1
	data["year"] = int(data.get("year", 2026)) + 1
	data["activities_used"] = []
	_process_school()
	_process_sports()
	_process_career()
	_process_finances()
	_process_natural_changes()

	if _check_for_death():
		save_game()
		return {}

	var milestone := EventCatalog.milestone_for_age(int(data["age"]), data)
	if not milestone.is_empty():
		pending_event = milestone.duplicate(true)
	else:
		pending_event = _choose_random_event()

	if pending_event.is_empty():
		_add_history("A steady year", "Life moved forward through ordinary days, small routines, and quiet progress.", "neutral")
	else:
		var event_id := str(pending_event.get("id", ""))
		if not event_id.is_empty():
			recent_event_ids.push_front(event_id)
			if recent_event_ids.size() > 10:
				recent_event_ids.resize(10)

	save_game()
	return pending_event


func resolve_choice(choice_index: int) -> String:
	if pending_event.is_empty():
		return ""
	var choices: Array = pending_event.get("choices", [])
	if choice_index < 0 or choice_index >= choices.size():
		return ""
	var choice: Dictionary = choices[choice_index]
	var effects: Dictionary = choice.get("effects", {})
	_apply_effects(effects)
	var result := str(choice.get("result", "Your choice changed the course of the year."))
	_add_history(str(pending_event.get("title", "A turning point")), result, _tone_for_effects(effects))
	_record_event_memory(pending_event, choice, result, effects)
	pending_event = {}
	_clamp_all_values()
	save_game()
	return result


func perform_activity(activity_id: String) -> Dictionary:
	if not bool(data.get("alive", false)):
		return {"ok": false, "message": "This life has ended."}
	var used: Array = data.get("activities_used", [])
	if used.has(activity_id):
		return {"ok": false, "message": "You already did this activity this year."}
	for activity in EventCatalog.activities():
		if str(activity.get("id", "")) != activity_id:
			continue
		if int(data.get("age", 0)) < int(activity.get("min_age", 0)):
			return {"ok": false, "message": "This activity is not available at your age."}
		var cost := int(activity.get("cost", 0))
		if cost > 0 and int(data.get("balance", 0)) < cost:
			return {"ok": false, "message": "You do not have enough money for that."}
		var effects: Dictionary = activity.get("effects", {}).duplicate(true)
		if cost > 0:
			effects["money"] = int(effects.get("money", 0)) - cost
		_apply_effects(effects)
		used.append(activity_id)
		data["activities_used"] = used
		_clamp_all_values()
		_add_history(str(activity.get("title", "Activity")), "You made time for something intentional this year.", "teal")
		save_game()
		return {"ok": true, "message": "Activity complete."}
	return {"ok": false, "message": "Activity not found."}


func apply_for_job(job_id: String) -> Dictionary:
	var job := CareerCatalog.find_job(job_id)
	if job.is_empty():
		job = EventCatalog.find_job(job_id)
	if job.is_empty():
		return {"ok": false, "message": "That job is unavailable."}
	if int(data.get("age", 0)) < int(job.get("min_age", 18)):
		return {"ok": false, "message": "You are too young for this position."}
	if int(data.get("education", 0)) < int(job.get("education", 0)):
		return {"ok": false, "message": "Requires %s." % CareerCatalog.education_short_label(int(job.get("education", 0)))}
	var stats: Dictionary = data.get("stats", {})
	var stat_key := str(job.get("stat", "smarts"))
	var stat_value := int(stats.get(stat_key, 0))
	var minimum := int(job.get("minimum", 0))
	if stat_value < minimum:
		return {"ok": false, "message": "Build your %s before applying." % stat_key}

	var interview_score := 48 + (stat_value - minimum) * 2 + int(float(stats.get("confidence", 50)) / 5.0) + int(float(stats.get("reputation", 50)) / 8.0)
	if rng.randi_range(1, 100) <= clampi(interview_score, 35, 94):
		_set_job(job_id)
		data["retired"] = false
		data["part_time"] = false
		_add_history("Hired: %s" % str(job.get("title", "New job")), "You handled the interview well and accepted the offer.", "teal")
		save_game()
		return {"ok": true, "message": "You got the job!"}
	data["stats"]["confidence"] = maxi(0, int(data["stats"].get("confidence", 50)) - 2)
	_add_history("Job application", "The employer chose another candidate. You gained interview experience.", "neutral")
	save_game()
	return {"ok": false, "message": "They selected another candidate."}


func enroll_education(program_id: String) -> Dictionary:
	if not bool(data.get("alive", false)):
		return {"ok": false, "message": "This life has ended."}
	if int(data.get("age", 0)) < 18:
		return {"ok": false, "message": "Postsecondary study unlocks at age 18."}
	if not data.get("education_program", {}).is_empty():
		return {"ok": false, "message": "You are already enrolled in a program."}
	var program := CareerCatalog.find_program(program_id)
	if program.is_empty():
		return {"ok": false, "message": "Program not found."}
	var current_level := int(data.get("education", 0))
	if current_level < int(program.get("requires", 0)):
		return {"ok": false, "message": "Complete %s first." % CareerCatalog.education_short_label(int(program.get("requires", 0)))}
	if current_level >= int(program.get("target", 0)):
		return {"ok": false, "message": "You already hold an equal or higher credential."}
	program["years_left"] = int(program.get("years", 1))
	data["education_program"] = program
	data["education_label"] = "%s — %d years left" % [str(program.get("title", "Program")), int(program.get("years_left", 1))]
	_add_history("Enrolled: %s" % str(program.get("title", "Program")), "You committed to a new education path and its yearly tuition costs.", "blue")
	save_game()
	return {"ok": true, "message": "Enrollment confirmed."}


func join_sport(sport_id: String) -> Dictionary:
	if not bool(data.get("alive", false)):
		return {"ok": false, "message": "This life has ended."}
	var result := SportsSystem.join_sport(data.get("sports", {}), sport_id, int(data.get("age", 0)), int(data.get("year", 2026)), data.get("stats", {}), rng)
	if bool(result.get("ok", false)):
		data["sports"] = result.get("state", {}).duplicate(true)
		_add_history("Joined %s" % str(data["sports"].get("sport_name", "a sport")), str(result.get("message", "A new athletic pathway began.")), "blue")
		save_game()
	return result


func create_sports_tryout_session(sport_id: String) -> Dictionary:
	if not bool(data.get("alive", false)):
		return {"ok": false, "message": "This life has ended."}
	return SportsSystem.create_tryout_session(data.get("sports", {}), sport_id, int(data.get("age", 0)), int(data.get("year", 2026)), data.get("stats", {}), int(rng.randi()))


func complete_sports_tryout_session(sport_id: String, score: int, total: int) -> Dictionary:
	var result := SportsSystem.complete_tryout(data.get("sports", {}), sport_id, score, total, int(data.get("age", 0)), int(data.get("year", 2026)), data.get("stats", {}), rng)
	data["sports"] = result.get("state", data.get("sports", {})).duplicate(true)
	if bool(result.get("ok", false)):
		data["stats"]["confidence"] = int(data["stats"].get("confidence", 50)) + score + 1
		data["stats"]["discipline"] = int(data["stats"].get("discipline", 50)) + score
		_add_history("Made the %s pathway" % str(data["sports"].get("sport_name", "sports")), str(result.get("message", "The tryout opened a new pathway.")), "blue")
	else:
		data["stats"]["confidence"] = int(data["stats"].get("confidence", 50)) - 1
		_add_history("Sports tryout", str(result.get("message", "The roster was out of reach this year.")), "neutral")
	_clamp_all_values()
	save_game()
	return result


func sports_train(action: String) -> Dictionary:
	var result := SportsSystem.training_action(data.get("sports", {}), action, int(data.get("year", 2026)), rng)
	if bool(result.get("ok", false)):
		data["sports"] = result.get("state", {}).duplicate(true)
		data["stats"]["health"] = int(data["stats"].get("health", 50)) + (3 if action == "physical" else 1)
		data["stats"]["discipline"] = int(data["stats"].get("discipline", 50)) + 2
		_clamp_all_values()
		_add_history("Athlete development", str(result.get("message", "Training complete.")), "teal")
		save_game()
	return result


func create_sports_training_session(action: String) -> Dictionary:
	var sports: Dictionary = data.get("sports", {})
	if str(sports.get("sport_id", "")).is_empty():
		return {"ok": false, "message": "Join a sport before training."}
	if int(sports.get("last_training_year", -1)) == int(data.get("year", 2026)):
		return {"ok": false, "message": "You already completed focused training this year."}
	if not sports.get("injury", {}).is_empty():
		return {"ok": false, "message": "Recover from your injury before training."}
	return SportsSystem.create_training_session(sports, action, int(rng.randi()))


func complete_sports_training_session(action: String, score: int, total: int) -> Dictionary:
	var result := SportsSystem.complete_training_session(data.get("sports", {}), action, score, total, int(data.get("year", 2026)), rng)
	if not bool(result.get("ok", false)):
		return result
	data["sports"] = result.get("state", {}).duplicate(true)
	data["stats"]["health"] = int(data["stats"].get("health", 50)) + (2 if action == "physical" else 1)
	data["stats"]["discipline"] = int(data["stats"].get("discipline", 50)) + 2 + score
	data["stats"]["confidence"] = int(data["stats"].get("confidence", 50)) + score
	_clamp_all_values()
	_add_history("%s training" % str(data["sports"].get("sport_name", "Athlete")), str(result.get("message", "Training complete.")), "teal")
	save_game()
	return result


func create_sports_session() -> Dictionary:
	var sports: Dictionary = data.get("sports", {})
	if str(sports.get("sport_id", "")).is_empty():
		return {"ok": false, "message": "Join a sport before playing a season."}
	if not sports.get("injury", {}).is_empty():
		return {"ok": false, "message": "You cannot play this season while recovering from %s." % str(sports.get("injury", {}).get("name", "an injury"))}
	if not SportsSystem.can_play_season(sports, int(data.get("year", 2026))):
		return {"ok": false, "message": "You already completed this season."}
	var session := SportsSystem.create_season_session(sports, int(rng.randi()))
	session["ok"] = true
	return session


func complete_sports_session(score: int, total: int) -> Dictionary:
	var result := SportsSystem.complete_season(data.get("sports", {}), score, total, int(data.get("age", 0)), int(data.get("year", 2026)), rng)
	if not bool(result.get("ok", false)):
		return result
	data["sports"] = result.get("state", {}).duplicate(true)
	var sports_job: Dictionary = result.get("job", {})
	if not sports_job.is_empty():
		data["job"] = sports_job.duplicate(true)
		data["job_progress"] = 0
		data["retired"] = false
		data["part_time"] = false
	data["stats"]["health"] = int(data["stats"].get("health", 50)) + 2
	data["stats"]["confidence"] = int(data["stats"].get("confidence", 50)) + score * 2
	data["stats"]["reputation"] = int(data["stats"].get("reputation", 50)) + score
	_clamp_all_values()
	_add_history("%s season" % str(data["sports"].get("sport_name", "Athletic")), str(result.get("message", "The season ended.")), "gold" if score == total else "teal")
	save_game()
	return result


func create_work_session() -> Dictionary:
	if not bool(data.get("alive", false)):
		return {"ok": false, "message": "This life has ended."}
	var job: Dictionary = data.get("job", {})
	if job.is_empty() or bool(data.get("retired", false)):
		return {"ok": false, "message": "Get an active job before starting a shift."}
	if int(data.get("work_shift_year", -1)) == int(data.get("year", 2026)):
		return {"ok": false, "message": "You already completed a focused work shift this year."}
	return JobMinigame.create_session(job, int(rng.randi()))


func complete_work_session(score: int, total: int) -> Dictionary:
	var job: Dictionary = data.get("job", {})
	if job.is_empty() or bool(data.get("retired", false)):
		return {"ok": false, "message": "There is no active job shift to complete."}
	if int(data.get("work_shift_year", -1)) == int(data.get("year", 2026)):
		return {"ok": false, "message": "This year's focused shift is already complete."}
	var rating := int(round(float(score) / float(maxi(1, total)) * 100.0))
	var progress_gain := 7 + score * 7
	var bonus := int(round(float(job.get("salary", 0)) * (0.0025 + float(score) * 0.0015)))
	data["work_shift_year"] = int(data.get("year", 2026))
	data["job_progress"] = int(data.get("job_progress", 0)) + progress_gain
	data["balance"] = int(data.get("balance", 0)) + bonus
	data["stats"]["discipline"] = int(data["stats"].get("discipline", 50)) + 2 + score
	data["stats"]["confidence"] = int(data["stats"].get("confidence", 50)) + score
	data["stats"]["reputation"] = int(data["stats"].get("reputation", 50)) + maxi(0, score - 1)
	_clamp_all_values()
	var message := "%d%% shift performance. You earned a %s performance bonus and %d career progress." % [rating, format_money(bonus), progress_gain]
	_add_history("Work shift: %s" % str(job.get("base_title", job.get("title", "Career"))), message, "gold" if score == total else "teal")
	save_game()
	return {"ok": true, "message": message, "rating": rating, "bonus": bonus}


func relationship_action(key: String, action: String) -> Dictionary:
	var relationship := _get_relationship(key)
	if relationship.is_empty():
		return {"ok": false, "message": "Relationship not found."}
	var delta := 0
	var cost := 0
	var message := ""
	match action:
		"talk":
			delta = rng.randi_range(3, 7)
			message = "A genuine conversation brought you closer."
		"spend_time":
			delta = rng.randi_range(6, 11)
			cost = 60
			message = "You made a good memory together."
		"gift":
			delta = rng.randi_range(8, 14)
			cost = 220
			message = "The thoughtful gift was warmly received."
		"apologize":
			delta = rng.randi_range(4, 9)
			data["stats"]["reputation"] = clampi(int(data["stats"].get("reputation", 50)) + 2, 0, 100)
			message = "Owning your mistake changed the tone."
		_:
			return {"ok": false, "message": "Unknown action."}
	if int(data.get("balance", 0)) < cost:
		return {"ok": false, "message": "You cannot afford that right now."}
	data["balance"] = int(data.get("balance", 0)) - cost
	_set_relationship_value(key, int(relationship.get("value", 50)) + delta)
	data["stats"]["happiness"] = clampi(int(data["stats"].get("happiness", 50)) + 2, 0, 100)
	_add_history(str(relationship.get("name", "Relationship")), message, "rose")
	save_game()
	return {"ok": true, "message": message}


func purchase_asset(asset_id: String) -> Dictionary:
	var asset := EventCatalog.find_asset(asset_id)
	if asset.is_empty():
		return {"ok": false, "message": "Asset not found."}
	if owns_asset(asset_id):
		return {"ok": false, "message": "You already own this."}
	if int(data.get("age", 0)) < int(asset.get("min_age", 18)):
		return {"ok": false, "message": "This purchase is not available at your age."}
	var price := int(asset.get("price", 0))
	if int(data.get("balance", 0)) < price:
		return {"ok": false, "message": "You need %s more." % format_money(price - int(data.get("balance", 0)))}
	data["balance"] = int(data.get("balance", 0)) - price
	var owned: Array = data.get("assets", [])
	owned.append(asset_id)
	data["assets"] = owned
	data["stats"]["happiness"] = clampi(int(data["stats"].get("happiness", 50)) + 7, 0, 100)
	_add_history("Purchased %s" % str(asset.get("title", "an asset")), "A major purchase became part of your life.", "gold")
	save_game()
	return {"ok": true, "message": "Purchase complete."}


func owns_asset(asset_id: String) -> bool:
	var owned: Array = data.get("assets", [])
	return owned.has(asset_id)


func relationship_entries() -> Array:
	var entries: Array = []
	var parents: Array = data.get("parents", [])
	for index in range(parents.size()):
		var parent: Dictionary = parents[index].duplicate(true)
		parent["key"] = "parent_%d" % index
		entries.append(parent)
	var siblings: Array = data.get("siblings", [])
	for index in range(siblings.size()):
		var sibling: Dictionary = siblings[index].duplicate(true)
		sibling["key"] = "sibling_%d" % index
		entries.append(sibling)
	var relations: Dictionary = data.get("relationships", {})
	for key in RELATIONSHIP_KEYS:
		if relations.has(key):
			var item: Dictionary = relations[key].duplicate(true)
			item["key"] = key
			entries.append(item)
	var partner: Dictionary = data.get("partner", {})
	if not partner.is_empty():
		var partner_item := partner.duplicate(true)
		partner_item["key"] = "partner"
		entries.append(partner_item)
	var children: Array = data.get("children", [])
	for index in range(children.size()):
		var child: Dictionary = children[index].duplicate(true)
		child["key"] = "child_%d" % index
		entries.append(child)
	return entries


func net_worth() -> int:
	var total := int(data.get("balance", 0))
	for asset_id in data.get("assets", []):
		var asset := EventCatalog.find_asset(str(asset_id))
		total += int(round(float(asset.get("price", 0)) * 0.72))
	return total


func life_score() -> int:
	var stats: Dictionary = data.get("stats", {})
	var score := 0
	for key in STAT_KEYS:
		score += int(stats.get(key, 0))
	score += int(data.get("age", 0)) * 2
	score += int(data.get("education", 0)) * 35
	score += data.get("history", []).size()
	score += clampi(int(float(net_worth()) / 5000.0), -50, 200)
	return maxi(0, score)


func save_game() -> bool:
	if data.is_empty():
		return false
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return false
	var payload := {
		"version": SAVE_VERSION,
		"data": data,
		"pending_event": pending_event,
		"recent_event_ids": recent_event_ids,
		"rng_state": rng.state
	}
	file.store_string(JSON.stringify(payload))
	return true


func load_game() -> bool:
	if not has_save():
		return false
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return false
	var parsed = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		return false
	var payload: Dictionary = parsed
	if not payload.get("data", {}) is Dictionary:
		return false
	data = payload.get("data", {}).duplicate(true)
	_migrate_loaded_data()
	pending_event = payload.get("pending_event", {}).duplicate(true)
	recent_event_ids = payload.get("recent_event_ids", []).duplicate()
	if payload.has("rng_state"):
		rng.state = int(payload["rng_state"])
	_clamp_all_values()
	return not data.is_empty()


func _migrate_loaded_data() -> void:
	var migration_rng := RandomNumberGenerator.new()
	var migration_key := "%s|%s|%s|%s" % [data.get("first_name", "Alex"), data.get("last_name", "Morgan"), data.get("birthplace", ""), data.get("year", 2026)]
	migration_rng.seed = CareerCatalog.stable_number(migration_key)
	var generated := LifeGenerator.generate_identity(migration_rng, str(data.get("first_name", "Alex")), str(data.get("last_name", "Morgan")))
	for key in ["life_seed", "identity", "pronouns", "birthplace", "birth_month", "birth_day", "background", "parents", "siblings", "appearance"]:
		if not data.has(key):
			var fallback = generated.get(key)
			data[key] = fallback.duplicate(true) if fallback is Array or fallback is Dictionary else fallback
	if not data.has("education_program"):
		data["education_program"] = {}
	if not data.has("sports"):
		data["sports"] = SportsSystem.new_state()
	else:
		data["sports"] = SportsSystem.migrate_state(data.get("sports", {}))
	if not data.has("dynamic_event_count"):
		data["dynamic_event_count"] = 0
	if not data.has("life_memories"):
		data["life_memories"] = []
	if not data.has("work_shift_year"):
		data["work_shift_year"] = -1
	if not data.has("history"):
		data["history"] = generated.get("history", []).duplicate(true)


func format_money(value: int) -> String:
	var negative := value < 0
	var digits := str(absi(value))
	var formatted := ""
	while digits.length() > 3:
		formatted = "," + digits.right(3) + formatted
		digits = digits.left(digits.length() - 3)
	formatted = "$" + digits + formatted
	return "-" + formatted if negative else formatted


func _process_school() -> void:
	var age := int(data.get("age", 0))
	if age == 5:
		data["education_label"] = "Primary School"
	elif age == 12:
		data["education_label"] = "Secondary School"
	elif age == 18:
		data["education"] = 1
		data["education_label"] = "High School Diploma"
	elif str(data.get("education_path", "")) == "university":
		if age >= 19 and age <= 21:
			data["education_label"] = "University — Year %d" % (age - 18)
			data["stats"]["smarts"] = clampi(int(data["stats"].get("smarts", 50)) + 3, 0, 100)
			data["balance"] = int(data.get("balance", 0)) - 6500
		elif age == 22:
			data["education"] = 2
			data["education_label"] = "Bachelor's Degree"
			_add_history("University graduation", "You completed your degree and stepped into a wider job market.", "gold")
	elif str(data.get("education_path", "")) == "trade" and age == 21:
		data["education"] = 2
		data["education_label"] = "Electrical Trade Certificate"
		data["job"] = {"id": "electrician", "title": "Electrician", "salary": 73000, "level": 1}
		_add_history("Trade certification", "You completed your apprenticeship and qualified as an electrician.", "gold")
	_process_active_education_program()


func _process_active_education_program() -> void:
	var program: Dictionary = data.get("education_program", {})
	if program.is_empty():
		return
	var tuition := int(program.get("annual_cost", 0))
	var scholarship: Dictionary = data.get("sports", {}).get("scholarship", {})
	if not scholarship.is_empty() and str(data.get("sports", {}).get("stage", "")) == "college":
		tuition = maxi(0, tuition - int(scholarship.get("annual_value", 0)))
	data["balance"] = int(data.get("balance", 0)) - tuition
	data["stats"]["smarts"] = clampi(int(data["stats"].get("smarts", 50)) + 4, 0, 100)
	data["stats"]["discipline"] = clampi(int(data["stats"].get("discipline", 50)) + 2, 0, 100)
	program["years_left"] = int(program.get("years_left", 1)) - 1
	if int(program.get("years_left", 0)) <= 0:
		var target := int(program.get("target", int(data.get("education", 0))))
		data["education"] = maxi(int(data.get("education", 0)), target)
		data["education_label"] = str(program.get("title", CareerCatalog.education_label(target)))
		_add_history("Graduated: %s" % str(program.get("title", "Advanced program")), "Years of study opened an entirely new level of career opportunities.", "gold")
		data["education_program"] = {}
	else:
		data["education_label"] = "%s — %d years left" % [str(program.get("title", "Program")), int(program.get("years_left", 1))]
		data["education_program"] = program


func _process_sports() -> void:
	var sports: Dictionary = data.get("sports", {})
	if str(sports.get("sport_id", "")).is_empty():
		return
	var result := SportsSystem.process_year(sports, int(data.get("age", 0)), int(data.get("year", 2026)), rng)
	data["sports"] = result.get("state", sports).duplicate(true)
	var sports_job: Dictionary = result.get("job", {})
	if not sports_job.is_empty():
		data["job"] = sports_job.duplicate(true)
		data["job_progress"] = 0
		data["retired"] = false
		data["part_time"] = false
	var message := str(result.get("message", ""))
	if not message.is_empty():
		if bool(data["sports"].get("retired", false)):
			var current_job: Dictionary = data.get("job", {})
			if bool(current_job.get("sports_job", false)):
				data["job"] = {}
				data["job_progress"] = 0
		if not data["sports"].get("scholarship", {}).is_empty() and str(data["sports"].get("stage", "")) == "college":
			data["education_label"] = "College athlete — %d%% scholarship" % int(data["sports"].get("scholarship", {}).get("percent", 0))
		_add_history("Athletic pathway", message, "gold")


func _process_career() -> void:
	var job: Dictionary = data.get("job", {})
	if job.is_empty() or bool(data.get("retired", false)):
		return
	data["career_years"] = int(data.get("career_years", 0)) + 1
	data["job_progress"] = int(data.get("job_progress", 0)) + rng.randi_range(2, 6) + int(float(data["stats"].get("discipline", 50)) / 25.0)
	if int(data.get("job_progress", 0)) >= 100:
		data["job_progress"] = int(data.get("job_progress", 0)) - 100
		job = CareerCatalog.promote(job)
		data["job"] = job
		_add_history("Career progress", "Consistent work earned you a raise and greater responsibility.", "teal")


func _process_finances() -> void:
	var age := int(data.get("age", 0))
	var income := 0
	var job: Dictionary = data.get("job", {})
	if not job.is_empty() and not bool(data.get("retired", false)):
		income = int(job.get("salary", 0))
		if bool(data.get("part_time", false)):
			income = int(round(float(income) * 0.55))
	elif bool(data.get("retired", false)):
		income = 22000

	var expenses := 0
	if age >= 18:
		expenses = 14500
		if bool(data.get("flags", {}).get("moved_out", false)):
			expenses += 7200
		if not data.get("partner", {}).is_empty():
			expenses += 3500
		expenses += data.get("children", []).size() * 7200
	for asset_id in data.get("assets", []):
		var asset := EventCatalog.find_asset(str(asset_id))
		expenses += int(asset.get("yearly_cost", 0))
	data["last_income"] = income
	data["last_expenses"] = expenses
	data["balance"] = int(data.get("balance", 0)) + income - expenses


func _process_natural_changes() -> void:
	var age := int(data.get("age", 0))
	var stats: Dictionary = data.get("stats", {})
	stats["happiness"] = int(stats.get("happiness", 50)) + rng.randi_range(-3, 3)
	if age < 18:
		stats["health"] = int(stats.get("health", 80)) + rng.randi_range(-1, 2)
	elif age < 45:
		stats["health"] = int(stats.get("health", 80)) + rng.randi_range(-2, 1)
	elif age < 70:
		stats["health"] = int(stats.get("health", 75)) + rng.randi_range(-3, 0)
	else:
		stats["health"] = int(stats.get("health", 65)) + rng.randi_range(-5, -1)
	stats["confidence"] = int(stats.get("confidence", 50)) + (1 if age >= 14 and age <= 40 else 0)
	data["stats"] = stats

	var relations: Dictionary = data.get("relationships", {})
	for key in RELATIONSHIP_KEYS:
		if relations.has(key):
			relations[key]["value"] = int(relations[key].get("value", 50)) - rng.randi_range(0, 2)
	data["relationships"] = relations
	var partner: Dictionary = data.get("partner", {})
	if not partner.is_empty():
		partner["value"] = int(partner.get("value", 60)) - rng.randi_range(0, 2)
		data["partner"] = partner
	var children: Array = data.get("children", [])
	for child in children:
		child["age"] = int(child.get("age", 0)) + 1
		child["value"] = int(child.get("value", 70)) - rng.randi_range(0, 1)
	data["children"] = children
	var parents: Array = data.get("parents", [])
	for parent in parents:
		parent["age"] = int(parent.get("age", 30)) + 1
		parent["value"] = int(parent.get("value", 70)) - rng.randi_range(0, 1)
	data["parents"] = parents
	var siblings: Array = data.get("siblings", [])
	for sibling in siblings:
		sibling["age"] = int(sibling.get("age", 0)) + 1
		sibling["value"] = int(sibling.get("value", 65)) - rng.randi_range(0, 1)
	data["siblings"] = siblings
	_clamp_all_values()


func _check_for_death() -> bool:
	var age := int(data.get("age", 0))
	var health := int(data.get("stats", {}).get("health", 0))
	var chance := 0
	if health <= 0:
		chance = 100
	elif age >= 105:
		chance = 70
	elif age >= 95:
		chance = 24 + (age - 95) * 3
	elif age >= 85:
		chance = 5 + (age - 85) * 2
	elif age >= 75:
		chance = 1 + int(float(age - 75) / 3.0)
	if health < 25:
		chance += 12
	if chance > 0 and rng.randi_range(1, 100) <= chance:
		data["alive"] = false
		data["cause_of_death"] = "natural causes" if health >= 25 else "complications from poor health"
		_add_history("A life completed", "%s died at age %d after a life shaped by thousands of choices." % [str(data.get("first_name", "Your character")), age], "rose")
		pending_event = {}
		return true
	return false


func _choose_random_event() -> Dictionary:
	if rng.randf() < 0.72:
		data["dynamic_event_count"] = int(data.get("dynamic_event_count", 0)) + 1
		var generated := DynamicEventGenerator.generate(data, rng, int(data["dynamic_event_count"]))
		if not generated.is_empty():
			return generated
	var eligible: Array = []
	var total_weight := 0
	for event in EventCatalog.events():
		if not _event_is_eligible(event):
			continue
		var weight := maxi(1, int(event.get("weight", 1)))
		eligible.append({"event": event, "weight": weight})
		total_weight += weight
	if eligible.is_empty():
		return {}
	var roll := rng.randi_range(1, total_weight)
	for entry in eligible:
		roll -= int(entry.get("weight", 1))
		if roll <= 0:
			return entry.get("event", {}).duplicate(true)
	return eligible.back().get("event", {}).duplicate(true)


func _event_is_eligible(event: Dictionary) -> bool:
	var age := int(data.get("age", 0))
	if age < int(event.get("min_age", 0)) or age > int(event.get("max_age", 120)):
		return false
	if recent_event_ids.has(str(event.get("id", ""))):
		return false
	if bool(event.get("requires_job", false)) and data.get("job", {}).is_empty():
		return false
	if bool(event.get("requires_single", false)) and not data.get("partner", {}).is_empty():
		return false
	if bool(event.get("requires_partner", false)) and data.get("partner", {}).is_empty():
		return false
	if int(data.get("balance", 0)) < int(event.get("requires_balance", -999999999)):
		return false
	if event.has("max_children") and data.get("children", []).size() >= int(event.get("max_children", 99)):
		return false
	if event.has("missing_asset") and owns_asset(str(event.get("missing_asset", ""))):
		return false
	return true


func _apply_effects(effects: Dictionary) -> void:
	var stats: Dictionary = data.get("stats", {})
	for key in STAT_KEYS:
		if effects.has(key):
			stats[key] = int(stats.get(key, 50)) + int(effects[key])
	data["stats"] = stats
	if effects.has("money"):
		data["balance"] = int(data.get("balance", 0)) + int(effects["money"])
	for key in RELATIONSHIP_KEYS:
		if effects.has(key):
			var current := _get_relationship(key)
			_set_relationship_value(key, int(current.get("value", 50)) + int(effects[key]))
	if effects.has("partner") and not data.get("partner", {}).is_empty():
		var partner: Dictionary = data["partner"]
		partner["value"] = int(partner.get("value", 60)) + int(effects["partner"])
		data["partner"] = partner
	if bool(effects.get("set_partner", false)):
		_create_partner()
	if bool(effects.get("new_child", false)):
		_create_child()
	if effects.has("education_path"):
		data["education_path"] = str(effects["education_path"])
	if effects.has("set_job"):
		_set_job(str(effects["set_job"]))
	if bool(effects.get("lose_job", false)):
		data["job"] = {}
		data["job_progress"] = 0
	if bool(effects.get("promotion", false)) and not data.get("job", {}).is_empty():
		var job: Dictionary = data["job"]
		job["level"] = int(job.get("level", 1)) + 1
		job["salary"] = int(round(float(job.get("salary", 0)) * 1.12))
		data["job"] = job
	if effects.has("job_progress"):
		data["job_progress"] = int(data.get("job_progress", 0)) + int(effects["job_progress"])
	if bool(effects.get("retire", false)):
		data["retired"] = true
		data["part_time"] = false
	if bool(effects.get("part_time", false)):
		data["retired"] = false
		data["part_time"] = true
	if effects.has("set_flag"):
		var flags: Dictionary = data.get("flags", {})
		for flag_key in effects["set_flag"]:
			flags[flag_key] = effects["set_flag"][flag_key]
		data["flags"] = flags
	if effects.has("add_asset") and not owns_asset(str(effects["add_asset"])):
		var assets: Array = data.get("assets", [])
		assets.append(str(effects["add_asset"]))
		data["assets"] = assets


func _set_job(job_id: String) -> void:
	var job := CareerCatalog.find_job(job_id)
	if job.is_empty():
		job = EventCatalog.find_job(job_id)
	if job.is_empty():
		if job_id == "electrician":
			job = {"id": "electrician", "title": "Electrician", "salary": 73000}
		else:
			return
	job["level"] = maxi(1, int(job.get("level", 1)))
	data["job"] = job
	data["job_progress"] = 0


func _create_partner() -> void:
	if not data.get("partner", {}).is_empty():
		return
	data["partner"] = {"name": LifeGenerator.random_person_name(rng), "relation": "Partner", "value": rng.randi_range(64, 78), "age": maxi(18, int(data.get("age", 18)) + rng.randi_range(-3, 3))}


func _create_child() -> void:
	var children: Array = data.get("children", [])
	children.append({"name": LifeGenerator.random_person_name(rng, str(data.get("last_name", ""))), "relation": "Child", "value": 82, "age": 0})
	data["children"] = children


func _get_relationship(key: String) -> Dictionary:
	if key == "partner":
		return data.get("partner", {})
	if key.begins_with("child_"):
		var child_index := int(key.trim_prefix("child_"))
		var children: Array = data.get("children", [])
		if child_index >= 0 and child_index < children.size():
			return children[child_index]
		return {}
	if key.begins_with("parent_"):
		var parent_index := int(key.trim_prefix("parent_"))
		var parents: Array = data.get("parents", [])
		if parent_index >= 0 and parent_index < parents.size():
			return parents[parent_index]
		return {}
	if key.begins_with("sibling_"):
		var sibling_index := int(key.trim_prefix("sibling_"))
		var siblings: Array = data.get("siblings", [])
		if sibling_index >= 0 and sibling_index < siblings.size():
			return siblings[sibling_index]
		return {}
	return data.get("relationships", {}).get(key, {})


func _set_relationship_value(key: String, value: int) -> void:
	value = clampi(value, 0, 100)
	if key == "partner":
		var partner: Dictionary = data.get("partner", {})
		if not partner.is_empty():
			partner["value"] = value
			data["partner"] = partner
		return
	if key.begins_with("child_"):
		var child_index := int(key.trim_prefix("child_"))
		var children: Array = data.get("children", [])
		if child_index >= 0 and child_index < children.size():
			children[child_index]["value"] = value
			data["children"] = children
		return
	if key.begins_with("parent_"):
		var parent_index := int(key.trim_prefix("parent_"))
		var parents: Array = data.get("parents", [])
		if parent_index >= 0 and parent_index < parents.size():
			parents[parent_index]["value"] = value
			data["parents"] = parents
		return
	if key.begins_with("sibling_"):
		var sibling_index := int(key.trim_prefix("sibling_"))
		var siblings: Array = data.get("siblings", [])
		if sibling_index >= 0 and sibling_index < siblings.size():
			siblings[sibling_index]["value"] = value
			data["siblings"] = siblings
		return
	var relations: Dictionary = data.get("relationships", {})
	if relations.has(key):
		relations[key]["value"] = value
		data["relationships"] = relations


func _clamp_all_values() -> void:
	if data.is_empty():
		return
	var stats: Dictionary = data.get("stats", {})
	for key in STAT_KEYS:
		stats[key] = clampi(int(stats.get(key, 50)), 0, 100)
	data["stats"] = stats
	for entry in relationship_entries():
		_set_relationship_value(str(entry.get("key", "")), int(entry.get("value", 50)))


func _add_history(title: String, body: String, tone: String) -> void:
	var history: Array = data.get("history", [])
	history.push_front({
		"age": int(data.get("age", 0)),
		"year": int(data.get("year", 2026)),
		"title": title,
		"body": body,
		"tone": tone
	})
	if history.size() > 160:
		history.resize(160)
	data["history"] = history


func _record_event_memory(source_event: Dictionary, choice: Dictionary, result: String, effects: Dictionary) -> void:
	var memories: Array = data.get("life_memories", [])
	memories.push_front({
		"id": str(source_event.get("id", "memory_%d_%d" % [int(data.get("age", 0)), memories.size()])),
		"category": str(source_event.get("category", "milestone" if not bool(source_event.get("generated", false)) else "life")),
		"title": str(source_event.get("title", "A past decision")),
		"choice": str(choice.get("text", "A choice")),
		"result": result,
		"effects": effects.duplicate(true),
		"age": int(data.get("age", 0)),
		"year": int(data.get("year", 2026))
	})
	if memories.size() > 80:
		memories.resize(80)
	data["life_memories"] = memories


func _tone_for_effects(effects: Dictionary) -> String:
	var positive := 0
	var negative := 0
	for key in effects:
		if effects[key] is int or effects[key] is float:
			var amount := int(effects[key])
			if amount > 0:
				positive += amount
			elif amount < 0:
				negative += absi(amount)
	if positive > negative + 4:
		return "teal"
	if negative > positive + 4:
		return "rose"
	return "neutral"
