extends SceneTree


func _initialize() -> void:
	var failures: Array[String] = []
	test_seeded_lives(failures)
	test_dynamic_events(failures)
	test_event_memory_and_migration(failures)
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
	state["life_memories"] = [{"id": "old_school_choice", "title": "The Group Project", "result": "You organized a clear plan.", "age": 15}]
	var ids: Dictionary = {}
	var stories: Dictionary = {}
	var categories: Dictionary = {}
	var valid_follow_ups := 0
	for sequence in range(1, 1001):
		state["age"] = 2 + sequence % 68
		var generated := DynamicEventGenerator.generate(state, rng, sequence)
		ids[str(generated.get("id", ""))] = true
		stories["%s|%s" % [generated.get("title", ""), generated.get("body", "")]] = true
		categories[str(generated.get("category", ""))] = true
		if str(generated.get("category", "")) == "follow_up" and str(generated.get("chain_from", "")) == "old_school_choice":
			valid_follow_ups += 1
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
	if valid_follow_ups < 100:
		failures.append("Only %d of 1,000 generated events formed valid consequences from an earlier decision." % valid_follow_ups)


func test_event_memory_and_migration(failures: Array[String]) -> void:
	var memory_simulation := LifeSimulation.new(776655)
	memory_simulation.new_life("Memory", "Tester")
	memory_simulation.pending_event = {
		"id": "memory_test_event",
		"category": "school",
		"title": "A Choice Worth Remembering",
		"generated": true,
		"choices": [{"text": "Take responsibility", "result": "You followed through on your promise.", "effects": {"discipline": 3}}]
	}
	memory_simulation.resolve_choice(0)
	var memories: Array = memory_simulation.data.get("life_memories", [])
	if memories.size() != 1 or str(memories[0].get("id", "")) != "memory_test_event":
		failures.append("Resolved decisions were not persisted as consequence-ready life memories.")

	var legacy_payload := {
		"version": 2,
		"data": {
			"first_name": "Legacy",
			"last_name": "Player",
			"age": 16,
			"year": 2042,
			"alive": true,
			"stats": {"health": 72, "happiness": 63, "smarts": 68, "confidence": 55, "discipline": 61, "reputation": 44},
			"relationships": {"family": {"name": "Family", "value": 70}, "friends": {"name": "Friends", "value": 60}},
			"sports": {"sport_id": "basketball", "sport_name": "Basketball", "stage": "school", "skill": 55, "fitness": 62, "game_iq": 53, "reputation": 45},
			"history": []
		},
		"pending_event": {},
		"recent_event_ids": [],
		"rng_state": 12345
	}
	var legacy_file := FileAccess.open(LifeSimulation.SAVE_PATH, FileAccess.WRITE)
	if legacy_file == null:
		failures.append("Could not create a legacy save fixture.")
		return
	legacy_file.store_string(JSON.stringify(legacy_payload))
	legacy_file.close()
	var migrated := LifeSimulation.new(1)
	if not migrated.load_game():
		failures.append("A legacy v0.2 save could not be loaded.")
		return
	var migrated_sports: Dictionary = migrated.data.get("sports", {})
	if not migrated.data.has("appearance") or not migrated.data.has("parents") or not migrated.data.has("life_memories"):
		failures.append("Legacy save migration did not restore procedural identity and event memory fields.")
	if not migrated_sports.has("injury") or not migrated_sports.has("contract") or not migrated_sports.has("coach_trust") or not migrated_sports.has("tryout_year"):
		failures.append("Legacy sports data did not receive the complete v0.5 state schema.")


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
			var round_format := str(round_data.get("format", "choice"))
			if round_format == "sequence":
				var correct_order: Array = round_data.get("correct_order", [])
				if options.size() != 3 or correct_order.size() != 3 or not options.has(correct_order[0]) or not options.has(correct_order[1]) or not options.has(correct_order[2]):
					failures.append("Career %s generated an invalid ordering challenge." % job.get("id", "unknown"))
					return
			else:
				var correct_index := int(round_data.get("correct_index", -1))
				if options.size() != 3 or correct_index < 0 or correct_index >= options.size():
					failures.append("Career %s generated an invalid work decision." % job.get("id", "unknown"))
					return
		if str(rounds[1].get("format", "")) != "sequence":
			failures.append("Career %s did not receive the new interactive ordering format." % job.get("id", "unknown"))
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
	var tryout := SportsSystem.create_tryout_session(SportsSystem.new_state(), "basketball", 10, 2036, stats, 88331)
	if not bool(tryout.get("ok", false)) or tryout.get("rounds", []).size() != 3:
		failures.append("Basketball did not create a complete three-stage school tryout.")
	var tryout_result := SportsSystem.complete_tryout(SportsSystem.new_state(), "basketball", 2, 3, 10, 2036, stats, rng)
	if not bool(tryout_result.get("ok", false)) or str(tryout_result.get("state", {}).get("sport_id", "")) != "basketball":
		failures.append("A successful school tryout did not award a development roster place.")
	var joined := SportsSystem.join_sport(SportsSystem.new_state(), "basketball", 10, 2036, stats, rng)
	if not bool(joined.get("ok", false)):
		failures.append("A school-age character could not join basketball.")
		return
	var athlete: Dictionary = joined.get("state", {})
	athlete["skill"] = 92
	athlete["fitness"] = 94
	athlete["game_iq"] = 91
	athlete["reputation"] = 88
	var training := SportsSystem.create_training_session(athlete, "technical", 77119)
	if training.get("rounds", []).size() != 3 or str(training.get("kind", "")) != "sports_training":
		failures.append("Sports training did not create three position-aware interactive drills.")
	var trained := SportsSystem.complete_training_session(athlete, "technical", 3, 3, 2036, rng)
	if not bool(trained.get("ok", false)) or int(trained.get("state", {}).get("skill", 0)) <= int(athlete.get("skill", 0)):
		failures.append("Sports drill performance did not update athlete development.")
	var school_transition := SportsSystem.process_stage_transition(athlete, 12, rng)
	athlete = school_transition.get("state", athlete)
	var college_transition := SportsSystem.process_stage_transition(athlete, 18, rng)
	athlete = college_transition.get("state", athlete)
	if str(athlete.get("stage", "")) != "college" or athlete.get("scholarship", {}).is_empty():
		failures.append("Elite school performance did not produce a college athletic scholarship.")
	var pro_transition := SportsSystem.process_stage_transition(athlete, 21, rng)
	athlete = pro_transition.get("state", athlete)
	if str(athlete.get("stage", "")) != "pro" or pro_transition.get("job", {}).is_empty() or athlete.get("contract", {}).is_empty():
		failures.append("Elite school performance did not produce a professional sports contract.")
	var expiring_pro: Dictionary = athlete.duplicate(true)
	expiring_pro["contract"]["years_left"] = 1
	var renewed := SportsSystem.process_year(expiring_pro, 25, 2051, rng)
	if renewed.get("job", {}).is_empty() or int(renewed.get("state", {}).get("contract", {}).get("years_left", 0)) < 2:
		failures.append("An expiring professional contract did not generate a salary-linked extension.")
	var season := SportsSystem.create_season_session(athlete, 99871)
	if season.get("rounds", []).size() != 3:
		failures.append("Sports season minigame did not create three realistic decisions.")

	var injury_base: Dictionary = joined.get("state", {}).duplicate(true)
	injury_base["fitness"] = 0
	var injured_state: Dictionary = {}
	for attempt in range(240):
		var injury_rng := RandomNumberGenerator.new()
		injury_rng.seed = 910000 + attempt
		var injury_result := SportsSystem.complete_season(injury_base, 0, 3, 16, 3000 + attempt, injury_rng)
		var candidate: Dictionary = injury_result.get("state", {})
		if not candidate.get("injury", {}).is_empty():
			injured_state = candidate
			break
	if injured_state.is_empty() or int(injured_state.get("games_missed", 0)) <= 0 or injured_state.get("injury_history", []).is_empty():
		failures.append("Repeated low-fitness season simulations never produced a tracked injury.")
	else:
		var recovery_rng := RandomNumberGenerator.new()
		recovery_rng.seed = 65001
		for recovery_year in range(3):
			injured_state = SportsSystem.process_year(injured_state, 17 + recovery_year, 4000 + recovery_year, recovery_rng).get("state", injured_state)
		if not injured_state.get("injury", {}).is_empty():
			failures.append("Sports rehabilitation did not clear a finite-duration injury.")


func finish(failures: Array[String]) -> void:
	if failures.is_empty():
		print("PASS: seeded lives, chained events, legacy migration, multi-format career shifts, tryouts, training, injuries, scholarships, contracts, and all 36 sports paths are valid.")
		quit(0)
		return
	for failure in failures:
		push_error(failure)
	quit(1)
