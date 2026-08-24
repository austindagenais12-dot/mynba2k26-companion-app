extends SceneTree


func _initialize() -> void:
	var failures: Array[String] = []
	var simulation := LifeSimulation.new(20260824)
	simulation.new_life("Austin", "Dagenais")
	if str(simulation.data.get("birthplace", "")) != "Kelowna, British Columbia":
		failures.append("New life did not initialize the expected original profile.")

	for target_age in range(1, 31):
		var event := simulation.age_up()
		if int(simulation.data.get("age", -1)) != target_age:
			failures.append("Age progression failed at year %d." % target_age)
			break
		if not event.is_empty():
			var result := simulation.resolve_choice(0)
			if result.is_empty():
				failures.append("Event at age %d did not resolve." % target_age)

	if int(simulation.data.get("education", 0)) < 2:
		failures.append("University milestone path did not award a degree by age 22.")
	if not simulation.pending_event.is_empty():
		failures.append("Resolved events left a pending choice behind.")
	if simulation.data.get("history", []).size() < 25:
		failures.append("Life timeline did not record enough moments.")

	var stats: Dictionary = simulation.data.get("stats", {})
	for key in LifeSimulation.STAT_KEYS:
		var value := int(stats.get(key, -1))
		if value < 0 or value > 100:
			failures.append("Stat %s escaped its 0–100 range." % key)

	var activity_result := simulation.perform_activity("meditate")
	if not bool(activity_result.get("ok", false)):
		failures.append("An eligible activity failed.")
	var repeated_result := simulation.perform_activity("meditate")
	if bool(repeated_result.get("ok", true)):
		failures.append("An activity was allowed twice in one year.")

	if not simulation.save_game():
		failures.append("Save operation failed.")
	var loaded := LifeSimulation.new(1)
	if not loaded.load_game():
		failures.append("Load operation failed.")
	elif int(loaded.data.get("age", -1)) != 30 or str(loaded.data.get("first_name", "")) != "Austin":
		failures.append("Loaded data did not match the saved life.")

	finish(failures, simulation)


func finish(failures: Array[String], simulation: LifeSimulation) -> void:
	if failures.is_empty():
		print("PASS: simulated 30 years with milestones, events, bounded stats, activities, timeline, and save/load. Score=%d" % simulation.life_score())
		quit(0)
		return
	for failure in failures:
		push_error(failure)
	quit(1)

