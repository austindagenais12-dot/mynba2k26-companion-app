extends SceneTree


func _initialize() -> void:
	var failures: Array[String] = []
	var jobs := CareerCatalog.all_jobs()
	var expected_count := 5120
	if jobs.size() != expected_count:
		failures.append("Expected %d careers, found %d." % [expected_count, jobs.size()])
	if CareerCatalog.sectors().size() != 40:
		failures.append("Expected 40 career sectors.")

	var ids: Dictionary = {}
	var sector_counts: Dictionary = {}
	for job in jobs:
		var job_id := str(job.get("id", ""))
		if job_id.is_empty() or ids.has(job_id):
			failures.append("Missing or duplicate career id: %s" % job_id)
			break
		ids[job_id] = true
		var sector := str(job.get("sector", ""))
		sector_counts[sector] = int(sector_counts.get(sector, 0)) + 1
		if str(job.get("title", "")).is_empty() or str(job.get("workplace", "")).is_empty():
			failures.append("Career %s is missing player-facing details." % job_id)
			break
		if int(job.get("salary", 0)) < 20000:
			failures.append("Career %s has an invalid salary." % job_id)
			break
		if int(job.get("education", -1)) < 0 or int(job.get("education", 99)) > 4:
			failures.append("Career %s has an invalid education level." % job_id)
			break

	for sector in CareerCatalog.sectors():
		if int(sector_counts.get(sector, 0)) != 128:
			failures.append("Sector %s did not generate 128 careers." % sector)

	var nurse_results := CareerCatalog.filter_jobs("nurse")
	if nurse_results.is_empty():
		failures.append("Career search did not find nurses.")
	var healthcare_results := CareerCatalog.filter_jobs("", "Healthcare")
	if healthcare_results.size() != 128:
		failures.append("Healthcare filter returned %d results." % healthcare_results.size())
	var entry_results := CareerCatalog.filter_jobs("", "All sectors", 0)
	if entry_results.size() != 1280:
		failures.append("Education eligibility filter returned %d entry careers." % entry_results.size())
	if CareerCatalog.education_programs().size() != 6:
		failures.append("Advanced education catalog is incomplete.")

	finish(failures, jobs.size())


func finish(failures: Array[String], job_count: int) -> void:
	if failures.is_empty():
		print("PASS: %d careers across 40 sectors with unique IDs, salaries, education requirements, search, filters, and study paths." % job_count)
		quit(0)
		return
	for failure in failures:
		push_error(failure)
	quit(1)

