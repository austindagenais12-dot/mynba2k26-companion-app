extends SceneTree


func _initialize() -> void:
	var failures: Array[String] = []
	test_seeded_lives(failures)
	test_dynamic_events(failures)
	test_job_minigames(failures)
	test_sports_pathways(failures)
	finish(failures)


func test_seeded_lives(failures: Array[String]) -> void:
	var names: Dictionary = {}
	var portraits: Dictionary = {}
	var origins: Dictionary = {}
	for seed_value in range(1000, 1060):
		var simulation := LifeSimulation.new(seed_value)
		simulation.new_life()
		var full_name := "%s %s" % [simulation.data.get("first_name", ""), simulation.data.get("last_name", "")]
		names[full_name] = true
		var appearance: Dictionary = simulation.data.get("appearance", {})
		var portrait_signature := "%s|%s|%s|%s|%s|%s|%s|%s" % [appearance.get("skin", ""), appearance.get("hair_color", ""), appearance.get("eye_color", ""), appearance.get("face_shape", 0), appearance.get("hair_style", 0), appearance.get("eye_style", 0), appearance.get("beard_style", 0), appearance.get("background_style", 0)]
		portraits[portrait_signature] = true
		origins[str(simulation.data.get("birthplace", ""))] = true
		if simulation.data.get("parents", []).is_empty():
			failures.append("Seed %d generated no parent or guardian." % seed_value)
		if simulation.data.get("history", []).size() < 3:
			failures.append("Seed %d generated too little past history." % seed_value)
		if simulation.data.get("background", {}).is_empty():
			failures.append("Seed %d generated no background." % seed_value)
	var first_copy := LifeSimulation.new(884422)
	first_copy.new_life()
	var second_copy := LifeSimulation.new(884422)
	second_copy.new_life()
	if first_copy.data.get("first_name") != second_copy.data.get("first_name") or first_copy.data.get("parents") != second_copy.data.get("parents") or first_copy.data.get("appearance") != second_copy.data.get("appearance"):
		failures.append("The same seed did not reproduce the same generated life.")
	if names.size() < 52:
		failures.append("Only %d unique names appeared across 60 generated lives." % names.size())
	if portraits.size() < 58:
		failures.append("Only %d unique portrait DNA combinations appeared across 60 lives." % portraits.size())
	if origins.size() < 20:
		failures.append("Only %d birthplaces appeared across 60 generated lives." % origins.size())


func test_dynamic_events(failures: Array[String]) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 44332211
	var state: Dictionary = LifeGenerator.generate_identity(rng)
	state["age"] = 28
	state["year"] = 2054
	state["balance"] = 18000
	state["job"] = CareerCatalog.all_jobs()[400].duplicate(true)
	state["education_program"] = CareerCatalog.find_program("masters_degree")
	state["partner"] = {"name": "Jordan Vale", "value": 77}
	state["sports"] = SportsSystem.new_state()
	state["sports"]["sport_id"] = "basketball"
	state["sports"]["sport_name"] = "Basketball"
	var ids: Dictionary = {}
	var stories: Dictionary = {}
	var categories: Dictionary = {}
	for sequence in range(1, 1001):
		state["age"] = 2 + sequence % 68
		var generated := DynamicEventGenerator.generate(state, rng, sequence)
		ids[str(generated.get("id", ""))] = true
		stories["%s|%s" % [generated.get("title", ""), generated.get("body", "")]] = true
		categories[str(generated.get("category", ""))] = true
		var choices: Array = generated.get("choices", [])
		if choices.size() != 3:
			failures.append("Generated event %d did not provide three choices." % sequence)
			break
	if ids.size() != 1000:
		failures.append("Dynamic event IDs were not unique across 1,000 generations.")
	if stories.size() < 175:
		failures.append("Dynamic event composition produced only %d distinct story combinations." % stories.size())
	if categories.size() < 10:
		failures.append("Dynamic events reached only %d life contexts." % categories.size())


func test_job_minigames(failures: Array[String]) -> void:
	var jobs := CareerCatalog.all_jobs()
	var archetypes: Dictionary = {}
	if jobs.size() != 5120:
		failures.append("Expected 5,120 careers before testing work shifts.")
	for index in range(jobs.size()):
		var job: Dictionary = jobs[index]
		var session := JobMinigame.create_session(job, 700000 + index)
		if not bool(session.get("ok", false)):
			failures.append("Career %s received no playable shift." % job.get("id", "unknown"))
			break
		archetypes[str(session.get("archetype", ""))] = true
		var rounds: Array = session.get("rounds", [])
		if rounds.size() != 3:
			failures.append("Career %s did not receive a three-round work minigame." % job.get("id", "unknown"))
			break
		for round_data in rounds:
			var options: Array = round_data.get("options", [])
			var correct_index := int(round_data.get("correct_index", -1))
			if options.size() != 3 or correct_index < 0 or correct_index >= options.size():
				failures.append("Career %s generated an invalid work decision." % job.get("id", "unknown"))
				return
	if archetypes.size() < 20:
		failures.append("Career minigames covered only %d professional gameplay archetypes." % archetypes.size())


func test_sports_pathways(failures: Array[String]) -> void:
	var sports := SportsSystem.sports()
	var sport_ids: Dictionary = {}
	for sport in sports:
		sport_ids[str(sport.get("id", ""))] = true
		if sport.get("positions", []).is_empty():
			failures.append("%s has no playable positions." % sport.get("name", "A sport"))
	if sports.size() != 36 or sport_ids.size() != 36:
		failures.append("Expected 36 distinct school-to-pro sports, found %d." % sport_ids.size())

	var rng := RandomNumberGenerator.new()
	rng.seed = 129988
	var stats := {"health": 100, "discipline": 100, "confidence": 100}
	var joined := SportsSystem.join_sport(SportsSystem.new_state(), "basketball", 10, 2036, stats, rng)
	if not bool(joined.get("ok", false)):
		failures.append("A school-age character could not join basketball.")
		return
	var athlete: Dictionary = joined.get("state", {})
	athlete["skill"] = 92
	athlete["fitness"] = 94
	athlete["game_iq"] = 91
	athlete["reputation"] = 88
	var school_transition := SportsSystem.process_stage_transition(athlete, 12, rng)
	athlete = school_transition.get("state", athlete)
	var college_transition := SportsSystem.process_stage_transition(athlete, 18, rng)
	athlete = college_transition.get("state", athlete)
	var pro_transition := SportsSystem.process_stage_transition(athlete, 21, rng)
	athlete = pro_transition.get("state", athlete)
	if str(athlete.get("stage", "")) != "pro" or pro_transition.get("job", {}).is_empty():
		failures.append("Elite school performance did not produce a professional sports contract.")
	var season := SportsSystem.create_season_session(athlete, 99871)
	if season.get("rounds", []).size() != 3:
		failures.append("Sports season minigame did not create three realistic decisions.")


func finish(failures: Array[String]) -> void:
	if failures.is_empty():
		print("PASS: seeded lives, 1,000 dynamic events, 5,120 career shifts, and all 36 school-to-pro sports pathways are valid.")
		quit(0)
		return
	for failure in failures:
		push_error(failure)
	quit(1)
