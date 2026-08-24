extends SceneTree


func _initialize() -> void:
	var failures: Array[String] = []
	var seen_ids: Dictionary = {}
	var events := EventCatalog.events()
	if events.size() < 35:
		failures.append("Expected at least 35 original random events, found %d." % events.size())
	for event in events:
		var event_id := str(event.get("id", ""))
		if event_id.is_empty():
			failures.append("An event is missing its id.")
		elif seen_ids.has(event_id):
			failures.append("Duplicate event id: %s" % event_id)
		seen_ids[event_id] = true
		if str(event.get("title", "")).is_empty() or str(event.get("body", "")).is_empty():
			failures.append("Event %s is missing player-facing writing." % event_id)
		var choices: Array = event.get("choices", [])
		if choices.size() < 2:
			failures.append("Event %s needs at least two choices." % event_id)
		for choice in choices:
			if str(choice.get("text", "")).is_empty() or str(choice.get("result", "")).is_empty():
				failures.append("Event %s has an incomplete choice." % event_id)
			if not choice.get("effects", {}) is Dictionary:
				failures.append("Event %s has invalid effects." % event_id)
	if EventCatalog.jobs().size() < 12:
		failures.append("The job catalog is too small.")
	if EventCatalog.activities().size() < 8:
		failures.append("The activity catalog is too small.")
	if EventCatalog.assets().size() < 5:
		failures.append("The asset catalog is too small.")
	finish(failures)


func finish(failures: Array[String]) -> void:
	if failures.is_empty():
		print("PASS: catalog contains %d events, %d jobs, %d activities, and %d assets." % [EventCatalog.events().size(), EventCatalog.jobs().size(), EventCatalog.activities().size(), EventCatalog.assets().size()])
		quit(0)
		return
	for failure in failures:
		push_error(failure)
	quit(1)

