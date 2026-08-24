extends RefCounted
class_name DynamicEventGenerator


static func generate(state: Dictionary, rng: RandomNumberGenerator, sequence: int) -> Dictionary:
	var categories := eligible_categories(state)
	if categories.is_empty():
		return {}
	var category := str(categories[rng.randi_range(0, categories.size() - 1)])
	var event: Dictionary
	match category:
		"childhood": event = childhood_event(state, rng)
		"school": event = school_event(state, rng)
		"friendship": event = friendship_event(state, rng)
		"sports": event = sports_event(state, rng)
		"education": event = education_event(state, rng)
		"work": event = work_event(state, rng)
		"family": event = family_event(state, rng)
		"money": event = money_event(state, rng)
		"health": event = health_event(state, rng)
		"community": event = community_event(state, rng)
		"travel": event = travel_event(state, rng)
		_: event = ordinary_event(state, rng)
	var seed_fragment := absi(int(state.get("life_seed", 0))) % 1000000
	event["id"] = "generated_%d_%d_%d" % [seed_fragment, sequence, rng.randi_range(1000, 999999)]
	event["generated"] = true
	event["category"] = category
	return event


static func eligible_categories(state: Dictionary) -> Array:
	var age := int(state.get("age", 0))
	var categories: Array = ["family", "health", "ordinary"]
	if age <= 5:
		categories.append_array(["childhood", "childhood", "family"])
	elif age <= 12:
		categories.append_array(["school", "school", "friendship", "childhood", "sports"])
	elif age <= 17:
		categories.append_array(["school", "friendship", "sports", "community", "education"])
	else:
		categories.append_array(["money", "community", "travel", "friendship"])
		if not state.get("job", {}).is_empty():
			categories.append_array(["work", "work"])
		if not state.get("education_program", {}).is_empty():
			categories.append("education")
		if age >= 24:
			categories.append("family")
	var sports: Dictionary = state.get("sports", {})
	if not str(sports.get("sport_id", "")).is_empty():
		categories.append_array(["sports", "sports"])
	return categories


static func childhood_event(state: Dictionary, rng: RandomNumberGenerator) -> Dictionary:
	var object_name := pick(rng, ["cardboard box", "wooden spoon", "blanket fort", "old radio", "pile of cushions", "rain puddle", "picture book", "flashlight"])
	var place := pick(rng, ["living room", "back garden", "hallway", "kitchen", "front steps", "neighborhood park"])
	return event(
		pick(rng, ["A Tiny Expedition", "The Best Toy Wasn't a Toy", "A World of Your Own", "One Long Afternoon"]),
		"In the %s, a %s becomes the centre of an elaborate game that only you completely understand." % [place, object_name],
		[
			choice("Invite everyone in", "The game grows louder, stranger, and much more memorable.", {"happiness": 7, "family": 4, "confidence": 2}),
			choice("Build it carefully alone", "You lose track of time while improving every small detail.", {"smarts": 4, "discipline": 4, "happiness": 3}),
			choice("Take it apart to see how it works", "The mystery is solved, although the toy does not survive.", {"smarts": 7, "family": -2})
		]
	)


static func school_event(_state: Dictionary, rng: RandomNumberGenerator) -> Dictionary:
	var subject := pick(rng, ["science", "history", "mathematics", "art", "music", "technology", "literature", "geography"])
	var project := pick(rng, ["a group presentation", "a surprise quiz", "a class debate", "a model-building challenge", "a research poster", "an oral report"])
	var complication := pick(rng, ["a teammate stops responding", "the instructions are unclear", "the deadline moves forward", "two classmates disagree", "your first attempt fails", "the class computer crashes"])
	return event(
		pick(rng, ["The Group Project", "Called to the Front", "A Different Kind of Test", "Deadline Tomorrow"]),
		"Your %s class begins %s, but %s." % [subject, project, complication],
		[
			choice("Organize a clear plan", "You divide the work fairly and the project finally starts moving.", {"discipline": 7, "confidence": 4, "reputation": 3}),
			choice("Try an unusual approach", "The idea is risky, but it makes the final result stand out.", {"smarts": 6, "confidence": 5, "happiness": 3}),
			choice("Do only your part", "Your work is finished, though the group never quite becomes a team.", {"discipline": 3, "friends": -3})
		]
	)


static func friendship_event(state: Dictionary, rng: RandomNumberGenerator) -> Dictionary:
	var person := social_person(state, rng)
	var invitation := pick(rng, ["a late-night conversation", "a last-minute road trip", "tickets to a small concert", "a weekend hike", "a competitive game night", "a community festival"])
	var tension := pick(rng, ["you already made other plans", "money is tight", "the two of you recently argued", "you have an important morning ahead", "another friend was not invited"])
	return event(
		pick(rng, ["An Unexpected Invitation", "The Message at 9:47", "Plans Within Plans", "A Friend at the Door"]),
		"%s invites you to %s, but %s." % [person, invitation, tension],
		[
			choice("Go and be present", "The imperfect night turns into a story you will both retell.", {"friends": 8, "happiness": 7, "money": -120}),
			choice("Explain and reschedule", "Honesty prevents disappointment from becoming resentment.", {"friends": 5, "discipline": 3}),
			choice("Ignore the message", "The invitation expires, and the silence says more than intended.", {"friends": -7, "happiness": -3})
		]
	)


static func sports_event(state: Dictionary, rng: RandomNumberGenerator) -> Dictionary:
	var sports: Dictionary = state.get("sports", {})
	var sport_name := str(sports.get("sport_name", pick(rng, ["school team", "local club", "recreation league"])))
	var situation := pick(rng, ["the regular starter is unavailable", "a scout appears near the sideline", "bad weather changes the conditions", "the team falls behind early", "a rival begins targeting your weakness", "the coach changes the game plan"])
	return event(
		pick(rng, ["Pressure Possession", "The Coach Looks Your Way", "A Scout in the Stands", "The Rivalry Game"]),
		"During an important %s session, %s." % [sport_name, situation],
		[
			choice("Trust the fundamentals", "Simple execution settles everyone and gives the team a chance.", {"discipline": 6, "confidence": 4, "health": -2}),
			choice("Take the decisive risk", "The bold play works just well enough to be remembered.", {"confidence": 8, "reputation": 6, "health": -4}),
			choice("Protect yourself", "You avoid injury, but the opportunity passes to someone else.", {"health": 3, "confidence": -3, "reputation": -2})
		]
	)


static func education_event(state: Dictionary, rng: RandomNumberGenerator) -> Dictionary:
	var program: Dictionary = state.get("education_program", {})
	var program_name := str(program.get("title", pick(rng, ["training program", "course", "degree path"])))
	var challenge := pick(rng, ["a major assignment overlaps with work", "your research reaches a dead end", "a professor challenges your assumptions", "your group loses a key member", "an exam covers unexpected material", "a placement becomes available far from home"])
	return event(
		pick(rng, ["Office Hours", "The Hardest Assignment", "A New Direction", "One More Revision"]),
		"Halfway through your %s, %s." % [program_name, challenge],
		[
			choice("Ask for expert feedback", "Specific advice saves days of frustration and strengthens the final work.", {"smarts": 7, "confidence": 3, "reputation": 2}),
			choice("Put in a focused late night", "The work gets done, though your body notices the tradeoff.", {"discipline": 8, "health": -5, "smarts": 4}),
			choice("Request more time", "The extension helps, but the unfinished work follows you into next week.", {"health": 2, "discipline": -3, "happiness": -2})
		]
	)


static func work_event(state: Dictionary, rng: RandomNumberGenerator) -> Dictionary:
	var job: Dictionary = state.get("job", {})
	var title := str(job.get("base_title", job.get("title", "your role")))
	var workplace := str(job.get("workplace", "the workplace"))
	var problem := pick(rng, ["a deadline suddenly moves forward", "a client changes the requirements", "a colleague makes an expensive mistake", "a critical tool stops working", "two priorities become urgent at once", "a supervisor asks for an honest assessment"])
	return event(
		pick(rng, ["The Difficult Shift", "No Room in the Schedule", "A Decision Before Lunch", "When the Plan Changes"]),
		"While working as %s at %s, %s." % [title, workplace, problem],
		[
			choice("Clarify the priority first", "A short conversation prevents the team from solving the wrong problem.", {"job_progress": 8, "discipline": 5, "reputation": 4}),
			choice("Take ownership immediately", "You carry the difficult task through and earn visible trust.", {"job_progress": 11, "health": -4, "confidence": 5}),
			choice("Keep your head down", "The shift ends, but the unresolved problem becomes tomorrow's problem.", {"job_progress": -3, "happiness": -4})
		]
	)


static func family_event(state: Dictionary, rng: RandomNumberGenerator) -> Dictionary:
	var person := family_person(state, rng)
	var request := pick(rng, ["help moving on short notice", "company at an important appointment", "advice about a major decision", "a place to stay for several nights", "help repairing something sentimental", "someone to listen without judging"])
	var conflict := pick(rng, ["your calendar is already full", "old tension remains between you", "the request may cost money", "another relative thinks you should refuse", "you are exhausted from the week"])
	return event(
		pick(rng, ["A Call from Family", "The Favour", "Old Roles, New Problem", "Someone Needs You"]),
		"%s asks for %s, but %s." % [person, request, conflict],
		[
			choice("Show up completely", "The effort is tiring, but the relationship becomes more honest.", {"family": 10, "health": -3, "happiness": 4}),
			choice("Offer practical limits", "You find a sustainable way to help without promising everything.", {"family": 6, "discipline": 5}),
			choice("Say no", "Your time is protected, although the refusal leaves a bruise.", {"family": -7, "health": 2})
		]
	)


static func money_event(_state: Dictionary, rng: RandomNumberGenerator) -> Dictionary:
	var item := pick(rng, ["car repair", "dental bill", "broken appliance", "rent increase", "family emergency", "computer replacement", "insurance deductible", "unexpected tax balance"])
	var amount := rng.randi_range(4, 22) * 100
	return event(
		pick(rng, ["The Unplanned Bill", "Not in the Budget", "A Costly Tuesday", "The Envelope"]),
		"An unexpected %s will cost about $%d, and payment is due sooner than expected." % [item, amount],
		[
			choice("Pay it from savings", "The problem is handled cleanly, even if the balance hurts to see.", {"money": -amount, "discipline": 4}),
			choice("Negotiate a payment plan", "A patient call makes the cost manageable over time.", {"money": -int(amount * 0.45), "smarts": 4, "confidence": 3}),
			choice("Delay it", "The immediate pressure fades, but the underlying cost grows.", {"money": -int(amount * 0.2), "happiness": -6, "discipline": -4})
		]
	)


static func health_event(_state: Dictionary, rng: RandomNumberGenerator) -> Dictionary:
	var symptom := pick(rng, ["a persistent cough", "a painful knee", "weeks of poor sleep", "recurring headaches", "unexpected dizziness", "a sharp toothache", "constant lower-back pain", "a suspicious skin change"])
	return event(
		pick(rng, ["Something Feels Off", "The Appointment Question", "A Warning from Your Body", "Not Going Away"]),
		"What began as a small inconvenience has become %s that no longer feels easy to ignore." % symptom,
		[
			choice("Book a proper assessment", "Early attention leads to a clear plan and fewer unknowns.", {"money": -240, "health": 6, "discipline": 5}),
			choice("Change your routine first", "Rest, movement, and consistency help more than expected.", {"health": 4, "discipline": 4, "happiness": 2}),
			choice("Keep pushing through", "The schedule continues, but so does the warning.", {"health": -10, "happiness": -4})
		]
	)


static func community_event(_state: Dictionary, rng: RandomNumberGenerator) -> Dictionary:
	var project := pick(rng, ["a neighborhood food drive", "a shoreline cleanup", "a youth recreation program", "a winter clothing collection", "a community garden", "a fundraiser for a local family", "an accessibility improvement project"])
	var need := pick(rng, ["volunteers are cancelling", "the budget is short", "organizers need a leader", "the venue suddenly becomes unavailable", "the public response is weaker than expected"])
	return event(
		pick(rng, ["A Local Cause", "The Sign-Up Sheet", "Your Neighbour Knocks", "Needed This Weekend"]),
		"A nearby group is organizing %s, but %s." % [project, need],
		[
			choice("Take a leadership role", "Your organization turns scattered effort into a successful day.", {"reputation": 9, "confidence": 6, "health": -2}),
			choice("Volunteer for one shift", "A few focused hours make a practical difference.", {"reputation": 5, "happiness": 4}),
			choice("Donate instead", "Your contribution buys exactly what the organizers were missing.", {"money": -300, "reputation": 4})
		]
	)


static func travel_event(_state: Dictionary, rng: RandomNumberGenerator) -> Dictionary:
	var destination := pick(rng, ["a coastal village", "a mountain town", "a major city", "a remote national park", "an island community", "a historic district", "a northern lake", "a desert coastline"])
	var surprise := pick(rng, ["the weather turns suddenly", "your reservation disappears", "a local festival fills the streets", "transportation is cancelled", "you meet another traveller with no plan", "a wrong turn reveals an unexpected place"])
	return event(
		pick(rng, ["Beyond the Itinerary", "The Wrong Turn", "One More Day Away", "Plans Change at the Station"]),
		"During a trip to %s, %s." % [destination, surprise],
		[
			choice("Adapt and explore", "The unplanned day becomes the part you remember most clearly.", {"money": -350, "happiness": 9, "confidence": 4}),
			choice("Solve the logistics", "Careful calls and backup plans put the trip back on track.", {"money": -180, "smarts": 5, "discipline": 4}),
			choice("Cut the trip short", "You return safely with money left and a little disappointment.", {"money": 120, "happiness": -3, "health": 2})
		]
	)


static func ordinary_event(_state: Dictionary, rng: RandomNumberGenerator) -> Dictionary:
	var discovery := pick(rng, ["a forgotten photograph", "a new walking route", "a tiny independent shop", "a handwritten note in an old book", "a song you have not heard in years", "a neighbor's hidden garden", "an unfinished project in a drawer"])
	return event(
		pick(rng, ["An Ordinary Discovery", "The Long Way Home", "Something Small", "A Different Afternoon"]),
		"An otherwise ordinary day changes shape when you come across %s." % discovery,
		[
			choice("Follow your curiosity", "The detour costs time and gives the day a story.", {"happiness": 6, "smarts": 3}),
			choice("Share it with someone", "A small discovery becomes a shared memory.", {"friends": 4, "family": 3, "happiness": 4}),
			choice("Continue with the day", "The moment passes quietly, leaving only a faint impression.", {"discipline": 2})
		]
	)


static func social_person(state: Dictionary, rng: RandomNumberGenerator) -> String:
	var candidates: Array[String] = ["A close friend", "A former classmate", "Someone from your neighborhood", "A teammate"]
	var partner: Dictionary = state.get("partner", {})
	if not partner.is_empty():
		candidates.append(str(partner.get("name", "Your partner")))
	return candidates[rng.randi_range(0, candidates.size() - 1)]


static func family_person(state: Dictionary, rng: RandomNumberGenerator) -> String:
	var candidates: Array[String] = ["A relative"]
	for parent in state.get("parents", []):
		candidates.append(str(parent.get("name", "A parent")))
	for sibling in state.get("siblings", []):
		candidates.append(str(sibling.get("name", "A sibling")))
	var partner: Dictionary = state.get("partner", {})
	if not partner.is_empty():
		candidates.append(str(partner.get("name", "Your partner")))
	return candidates[rng.randi_range(0, candidates.size() - 1)]


static func event(title: String, body: String, choices: Array) -> Dictionary:
	return {"title": title, "body": body, "choices": choices}


static func choice(text: String, result: String, effects: Dictionary) -> Dictionary:
	return {"text": text, "result": result, "effects": effects}


static func pick(rng: RandomNumberGenerator, values: Array) -> String:
	return str(values[rng.randi_range(0, values.size() - 1)])
