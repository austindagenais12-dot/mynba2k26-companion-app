extends SceneTree


func _initialize() -> void:
	var failures: Array[String] = []
	var simulation := LifeSimulation.new(20260824)
	simulation.new_life("Austin", "Dagenais")
	if str(simulation.data.get("first_name", "")) != "Austin" or str(simulation.data.get("birthplace", "")).is_empty():
		failures.append("New life did not preserve the chosen name and generate an origin.")
	if simulation.data.get("parents", []).is_empty() or simulation.data.get("appearance", {}).is_empty():
		failures.append("New life did not generate family and portrait DNA.")

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

	var enrollment := simulation.enroll_education("masters_degree")
	if not bool(enrollment.get("ok", false)):
		failures.append("Eligible graduate enrollment failed.")
	for target_age in range(31, 33):
		var study_event := simulation.age_up()
		if not study_event.is_empty():
			simulation.resolve_choice(0)
	if int(simulation.data.get("education", 0)) < 3:
		failures.append("Master's program did not complete after two years.")

	var software_jobs := CareerCatalog.filter_jobs("Software Developer", "Software & IT", 3)
	if software_jobs.is_empty():
		failures.append("Could not find a real-world software career for application testing.")
	else:
		for key in LifeSimulation.STAT_KEYS:
			simulation.data["stats"][key] = 100
		var hired := false
		for attempt in range(8):
			var application := simulation.apply_for_job(str(software_jobs[0].get("id", "")))
			if bool(application.get("ok", false)):
				hired = true
				break
		if not hired or str(simulation.data.get("job", {}).get("sector", "")) != "Software & IT":
			failures.append("Career catalog job application did not integrate with the life save.")

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
	elif int(loaded.data.get("age", -1)) != 32 or str(loaded.data.get("first_name", "")) != "Austin":
		failures.append("Loaded data did not match the saved life.")

	finish(failures, simulation)


func finish(failures: Array[String], simulation: LifeSimulation) -> void:
	if failures.is_empty():
		print("PASS: simulated 32 years with milestones, graduate education, catalog hiring, bounded stats, activities, timeline, and save/load. Score=%d" % simulation.life_score())
		quit(0)
		return
	for failure in failures:
		push_error(failure)
	quit(1)
