extends RefCounted
class_name JobMinigame


static func create_session(job: Dictionary, seed_value: int) -> Dictionary:
	if job.is_empty():
		return {"ok": false, "message": "Get a job before starting a work shift."}
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var archetype := archetype_for(job)
	var rounds: Array = []
	for round_index in range(3):
		rounds.append(build_round(job, archetype, round_index, rng))
	return {
		"ok": true,
		"kind": "work",
		"archetype": archetype,
		"title": "%s SHIFT" % str(job.get("base_title", job.get("title", "WORK"))).to_upper(),
		"subtitle": "%s • %s" % [str(job.get("workplace", "Workplace")), archetype_label(archetype)],
		"rounds": rounds,
		"round_index": 0,
		"score": 0
	}


static func archetype_for(job: Dictionary) -> String:
	var sector := str(job.get("sector", ""))
	match sector:
		"Healthcare": return "clinical"
		"Mental Health & Social Services": return "care"
		"Education": return "teaching"
		"Science & Research": return "research"
		"Engineering", "Construction & Architecture", "Energy & Utilities": return "engineering"
		"Software & IT": return "technical"
		"Data & Artificial Intelligence", "Finance & Accounting": return "analysis"
		"Cybersecurity": return "security"
		"Business & Management", "Entrepreneurship & Gig Economy": return "operations"
		"Law & Legal Services", "Government & Public Administration": return "public_duty"
		"Skilled Trades", "Manufacturing & Industrial", "Automotive & Mobility": return "hands_on"
		"Transportation & Logistics", "Aviation & Aerospace", "Maritime & Fisheries": return "logistics"
		"Agriculture & Forestry", "Environment & Conservation", "Animal Care & Veterinary": return "fieldwork"
		"Media & Journalism", "Marketing & Communications": return "communications"
		"Arts & Design", "Film & Television", "Music & Performing Arts": return "creative"
		"Sports & Fitness": return "performance"
		"Hospitality & Tourism", "Retail & Sales", "Real Estate & Property": return "service"
		"Food & Culinary": return "culinary"
		"Beauty & Personal Care": return "personal_care"
		"Childcare & Family Services": return "childcare"
		"Emergency Services", "Military & Defence": return "response"
		"Funeral & Memorial Services", "Religion & Spiritual Care": return "support"
		_: return "operations"


static func archetype_label(archetype: String) -> String:
	return str({
		"clinical": "Clinical judgement",
		"care": "Client care",
		"teaching": "Learning support",
		"research": "Evidence and method",
		"engineering": "Safety and design",
		"technical": "Systems troubleshooting",
		"analysis": "Data and decisions",
		"security": "Threat response",
		"operations": "Operations management",
		"public_duty": "Policy and procedure",
		"hands_on": "Practical execution",
		"logistics": "Safe coordination",
		"fieldwork": "Field assessment",
		"communications": "Audience and accuracy",
		"creative": "Creative production",
		"performance": "Performance coaching",
		"service": "Customer experience",
		"culinary": "Kitchen service",
		"personal_care": "Consultation and technique",
		"childcare": "Child development",
		"response": "Emergency response",
		"support": "Compassionate support"
	}.get(archetype, "Professional judgement"))


static func build_round(job: Dictionary, archetype: String, round_index: int, rng: RandomNumberGenerator) -> Dictionary:
	var role := str(job.get("base_title", job.get("title", "professional")))
	var workplace := str(job.get("workplace", "the workplace"))
	var scenario: Dictionary
	match archetype:
		"clinical": scenario = clinical_round(role, workplace, round_index)
		"care": scenario = care_round(role, workplace, round_index)
		"teaching": scenario = teaching_round(role, workplace, round_index)
		"research": scenario = research_round(role, workplace, round_index)
		"engineering": scenario = engineering_round(role, workplace, round_index)
		"technical": scenario = technical_round(role, workplace, round_index)
		"analysis": scenario = analysis_round(role, workplace, round_index)
		"security": scenario = security_round(role, workplace, round_index)
		"public_duty": scenario = public_duty_round(role, workplace, round_index)
		"hands_on": scenario = hands_on_round(role, workplace, round_index)
		"logistics": scenario = logistics_round(role, workplace, round_index)
		"fieldwork": scenario = fieldwork_round(role, workplace, round_index)
		"communications": scenario = communications_round(role, workplace, round_index)
		"creative": scenario = creative_round(role, workplace, round_index)
		"performance": scenario = performance_round(role, workplace, round_index)
		"service": scenario = service_round(role, workplace, round_index)
		"culinary": scenario = culinary_round(role, workplace, round_index)
		"personal_care": scenario = personal_care_round(role, workplace, round_index)
		"childcare": scenario = childcare_round(role, workplace, round_index)
		"response": scenario = response_round(role, workplace, round_index)
		"support": scenario = support_round(role, workplace, round_index)
		_: scenario = operations_round(role, workplace, round_index)
	var correct := str(scenario.get("correct", "Follow the documented procedure and communicate clearly"))
	var options: Array = [correct, str(scenario.get("wrong_one", "Rush without checking the facts")), str(scenario.get("wrong_two", "Ignore it and hope someone else handles it"))]
	shuffle_with_rng(options, rng)
	return {
		"prompt": "ROUND %d • %s" % [round_index + 1, str(scenario.get("prompt", "A work decision needs your attention."))],
		"options": options,
		"correct_index": options.find(correct)
	}


static func clinical_round(role: String, workplace: String, index: int) -> Dictionary:
	var rounds := [
		s("As the %s at %s, a patient's condition changes unexpectedly. What comes first?" % [role, workplace], "Reassess immediate risks, stabilize, and escalate through the care team", "Continue the original plan without reassessing", "Discuss the case publicly before acting"),
		s("Two records contain conflicting information before treatment. What is the safe response?", "Pause and verify identity, history, orders, and allergies", "Choose whichever record was opened first", "Ask the patient to guess which record is correct"),
		s("The shift is busy and a handoff is approaching. How do you protect continuity?", "Give a structured handoff with changes, risks, and pending actions", "Mention only the easiest cases", "Leave undocumented details for the next shift to discover")
	]
	return rounds[index]


static func care_round(role: String, workplace: String, index: int) -> Dictionary:
	var rounds := [
		s("A client at %s tells the %s something sensitive and asks for help." % [workplace, role], "Listen without judgement, clarify safety, explain confidentiality limits, and plan together", "Promise absolute secrecy before hearing the concern", "Tell unrelated coworkers to get their opinions"),
		s("A client repeatedly misses agreed appointments. What is the useful next step?", "Explore barriers and build a realistic, documented support plan", "Close the file without contacting them", "Lecture them about responsibility"),
		s("Two services disagree about who should respond to an urgent need. What do you do?", "Keep the client safe while coordinating a clear owner and follow-up", "Wait until the agencies settle it themselves", "Send the client back and forth without explanation")
	]
	return rounds[index]


static func teaching_round(role: String, workplace: String, index: int) -> Dictionary:
	var rounds := [
		s("As the %s at %s, assessment results show several learners missed the same concept." % [role, workplace], "Reteach with a different approach and check understanding again", "Move on because the lesson was already delivered", "Lower every grade without feedback"),
		s("One learner is disengaged while the rest begin an activity. What is the best first move?", "Check in privately, identify the barrier, and offer a clear entry point", "Call them out in front of everyone", "Complete the work for them"),
		s("A family questions how an evaluation was made. How do you respond?", "Explain the criteria with evidence and invite a constructive next step", "Refuse to discuss any part of the evaluation", "Change the result immediately to avoid conflict")
	]
	return rounds[index]


static func research_round(role: String, workplace: String, index: int) -> Dictionary:
	var rounds := [
		s("The %s at %s sees a result that strongly supports the team's hypothesis." % [role, workplace], "Verify the method, uncertainty, and reproducibility before interpreting it", "Publish the most exciting number immediately", "Delete observations that weaken the pattern"),
		s("A sample label is unclear during collection. What protects the study?", "Quarantine it, document the uncertainty, and follow the protocol", "Relabel it from memory", "Mix it with the nearest sample"),
		s("A colleague cannot reproduce one part of the analysis. What is the productive response?", "Share the complete method, inputs, and assumptions and investigate together", "Hide the working files", "Claim their equipment must be wrong")
	]
	return rounds[index]


static func engineering_round(role: String, workplace: String, index: int) -> Dictionary:
	var rounds := [
		s("The %s at %s notices a safety margin is based on an outdated assumption." % [role, workplace], "Stop the affected decision, verify loads and standards, and document the revision", "Leave it because changing plans costs money", "Increase one dimension without recalculating anything"),
		s("A field condition differs from the approved drawing. What comes next?", "Record the condition and obtain a reviewed, traceable design response", "Tell the crew to improvise", "Alter the drawing after the work is hidden"),
		s("A deadline conflicts with required testing. What is the professional response?", "Explain the risk and sequence critical tests before release", "Skip every test that takes longer than an hour", "Sign the work without reviewing it")
	]
	return rounds[index]


static func technical_round(role: String, workplace: String, index: int) -> Dictionary:
	var rounds := [
		s("As the %s at %s, a production system begins failing after a deployment." % [role, workplace], "Stabilize service, compare changes and telemetry, then isolate the cause", "Randomly restart every component", "Delete the logs to save space"),
		s("A reported bug cannot be reproduced. What is the strongest next step?", "Capture exact conditions, inputs, versions, and expected versus actual behaviour", "Close it because it works on your device", "Rewrite the whole system immediately"),
		s("A fix works but touches a shared dependency. How do you release it safely?", "Add targeted tests, review impact, stage rollout, and monitor", "Push directly to everyone without review", "Disable alerts so the rollout looks quiet")
	]
	return rounds[index]


static func analysis_round(role: String, workplace: String, index: int) -> Dictionary:
	var rounds := [
		s("The %s at %s finds a metric that changed sharply this month." % [role, workplace], "Validate the definition and data quality before explaining the change", "Assume the first correlation is the cause", "Remove the month from the report"),
		s("A decision-maker asks for one simple forecast despite major uncertainty. What do you provide?", "A central estimate with assumptions, range, and key sensitivities", "A precise number with no caveats", "The largest possible value to appear ambitious"),
		s("Two reports disagree because they use different denominators. What is the fix?", "Reconcile definitions and present a consistent comparison", "Average the two percentages", "Use whichever report supports the preferred answer")
	]
	return rounds[index]


static func security_round(role: String, workplace: String, index: int) -> Dictionary:
	var rounds := [
		s("As the %s at %s, you receive a credible alert for unusual privileged access." % [role, workplace], "Preserve evidence, contain access proportionately, and begin the incident process", "Post the account name publicly", "Delete the alert after changing one password"),
		s("A colleague asks for a temporary policy bypass to meet a deadline. What do you do?", "Use the approved exception process with scope, owner, expiry, and controls", "Share your credentials for the afternoon", "Disable the policy for everyone"),
		s("A scanner reports a critical issue on an internet-facing service. What is first?", "Confirm exposure and exploitability, then prioritize containment and remediation", "Ignore it until the next quarterly review", "Shut down unrelated systems")
	]
	return rounds[index]


static func operations_round(role: String, workplace: String, index: int) -> Dictionary:
	var rounds := [
		s("The %s at %s begins a shift with two urgent requests and limited staff." % [role, workplace], "Prioritize by impact and deadline, assign owners, and communicate the plan", "Start whichever request arrived last", "Promise both will be finished immediately without checking capacity"),
		s("A repeated process failure is delaying the team. What is the best response?", "Map the process, find the constraint, test an improvement, and measure it", "Blame the newest employee", "Add more approvals without learning the cause"),
		s("A key deliverable is at risk before a stakeholder update. What do you say?", "Share the current facts, impact, recovery plan, and next decision point", "Report it as complete", "Cancel the update without explanation")
	]
	return rounds[index]


static func public_duty_round(role: String, workplace: String, index: int) -> Dictionary:
	var rounds := [
		s("The %s at %s receives a request that conflicts with written policy." % [role, workplace], "Check authority and evidence, document the decision, and explain review options", "Create a private exception for a friend", "Reject it without reading the facts"),
		s("A file contains personal information not needed for the decision. What do you do?", "Limit access and use only the information authorized for the purpose", "Copy it into every related email", "Discuss it in a public waiting area"),
		s("Two interpretations of a rule could affect someone substantially. What is responsible?", "Research controlling guidance, record the reasoning, and seek review when required", "Choose the harsher result automatically", "Flip a coin to avoid bias")
	]
	return rounds[index]


static func hands_on_round(role: String, workplace: String, index: int) -> Dictionary:
	var rounds := [
		s("Before the %s at %s begins a task, the equipment condition is uncertain." % [role, workplace], "Isolate hazards, inspect the equipment, and verify the safe procedure", "Try it briefly to see whether it fails", "Ask someone else to stand nearby"),
		s("A measurement does not match the specification. What is the best next step?", "Stop, verify the reference and tool, then correct before continuing", "Force the part into place", "Hide the difference with finishing material"),
		s("A coworker removes a guard to work faster. How do you respond?", "Stop the unsafe work and restore controls before restarting", "Look away because the deadline is close", "Remove another guard so both sides match")
	]
	return rounds[index]


static func logistics_round(role: String, workplace: String, index: int) -> Dictionary:
	var rounds := [
		s("The %s at %s learns a route or movement plan is no longer safe." % [role, workplace], "Pause dispatch, verify constraints, reroute, and notify affected people", "Continue and hope conditions improve", "Change the destination without telling anyone"),
		s("A manifest and physical count disagree before departure. What do you do?", "Reconcile the load and documentation before release", "Use the larger number", "Sign both versions"),
		s("A delay will break a promised connection. What is the strongest response?", "Protect safety, evaluate alternatives, and communicate a realistic update", "Make up lost time by ignoring limits", "Stop answering messages")
	]
	return rounds[index]


static func fieldwork_round(role: String, workplace: String, index: int) -> Dictionary:
	var rounds := [
		s("Conditions in the field differ from the plan prepared by the %s at %s." % [role, workplace], "Reassess hazards and welfare, adapt the method, and record the change", "Proceed without protective equipment", "Collect only the easiest observations"),
		s("A living subject, animal, or habitat shows signs of stress. What comes first?", "Reduce harm, follow welfare protocol, and seek appropriate expertise", "Continue until every measurement is complete", "Move it without documenting the intervention"),
		s("Weather threatens the quality of a sample or task. What is responsible?", "Protect people first, preserve valid work, and reschedule if conditions exceed limits", "Rush the procedure during the worst conditions", "Invent values for anything missed")
	]
	return rounds[index]


static func communications_round(role: String, workplace: String, index: int) -> Dictionary:
	var rounds := [
		s("The %s at %s receives a compelling claim from a single source." % [role, workplace], "Verify it independently and distinguish fact, context, and uncertainty", "Publish immediately because it may trend", "Add details that make the story stronger"),
		s("Audience feedback shows the message is being misunderstood. What do you change?", "Clarify the core point, evidence, audience need, and call to action", "Repeat the same wording more loudly", "Blame the audience"),
		s("A correction is needed after publication. What protects trust?", "Correct it promptly and transparently, with the accurate information", "Quietly remove the entire item", "Argue that the error was too small to matter")
	]
	return rounds[index]


static func creative_round(role: String, workplace: String, index: int) -> Dictionary:
	var rounds := [
		s("The %s at %s receives a vague brief with a firm deadline." % [role, workplace], "Clarify audience, purpose, constraints, references, and approval points", "Start the final version based on one guess", "Copy a competitor's work"),
		s("A review note conflicts with the central creative goal. What is the best response?", "Ask what problem the note should solve and offer aligned alternatives", "Ignore all feedback", "Change every element without preserving a version"),
		s("A production asset may not be licensed for the intended use. What do you do?", "Verify rights or replace it with original or properly licensed material", "Use it and remove the credit", "Claim it was generated in-house")
	]
	return rounds[index]


static func performance_round(role: String, workplace: String, index: int) -> Dictionary:
	var rounds := [
		s("The %s at %s sees performance fall while fatigue indicators rise." % [role, workplace], "Adjust load, protect recovery, and use objective feedback", "Double the workload as punishment", "Ignore fatigue until an injury occurs"),
		s("A competitor struggles with a repeated tactical situation. What helps?", "Break down the read, rehearse it progressively, and review the result", "Tell them to want it more", "Change their entire role during competition"),
		s("A high-stakes event is approaching. What creates reliable readiness?", "Use a rehearsed plan for preparation, decisions, recovery, and contingencies", "Add unfamiliar training at the last minute", "Measure success only by social media attention")
	]
	return rounds[index]


static func service_round(role: String, workplace: String, index: int) -> Dictionary:
	var rounds := [
		s("A customer tells the %s at %s that the service did not match what was promised." % [role, workplace], "Listen, verify the gap, explain options, and take ownership of the next step", "Interrupt to defend the business", "Offer something the team cannot deliver"),
		s("Demand suddenly exceeds capacity. How do you protect the experience?", "Set accurate expectations, prioritize fairly, and keep people updated", "Hide the wait time", "Serve only the loudest customers"),
		s("A customer requests an exception that could disadvantage others. What is best?", "Apply policy consistently while exploring a fair alternative", "Make the exception secretly", "Embarrass the customer for asking")
	]
	return rounds[index]


static func culinary_round(role: String, workplace: String, index: int) -> Dictionary:
	var rounds := [
		s("The %s at %s finds a chilled ingredient outside its safe holding range." % [role, workplace], "Isolate it, verify time and temperature, and follow food-safety procedure", "Smell it and use it if it seems fine", "Mix it with a colder ingredient"),
		s("Orders surge and one station falls behind. What restores service?", "Communicate timing, rebalance prep, and protect quality and safety", "Send incomplete plates", "Stop coordinating with the front of house"),
		s("A guest reports a serious allergy. What comes first?", "Confirm the allergen, prevent cross-contact, and communicate through the full team", "Remove the visible ingredient only", "Guess which menu item is safest")
	]
	return rounds[index]


static func personal_care_round(role: String, workplace: String, index: int) -> Dictionary:
	var rounds := [
		s("Before a service, the %s at %s notices a contraindication or sensitivity." % [role, workplace], "Pause, consult, explain risks, and adapt or decline the service safely", "Continue at a lower price", "Cover the area so it cannot be seen"),
		s("A client requests a result that is unrealistic in one appointment. What do you do?", "Set honest expectations and agree on a safe staged plan", "Guarantee the result", "Use a stronger product than recommended"),
		s("Reusable tools are needed for the next client. What is required?", "Complete the correct cleaning, disinfection, or sterilization process", "Wipe them quickly with a dry towel", "Use them again because they look clean")
	]
	return rounds[index]


static func childcare_round(role: String, workplace: String, index: int) -> Dictionary:
	var rounds := [
		s("A child at %s tells the %s something that raises a safety concern." % [workplace, role], "Stay calm, listen without leading, record accurately, and follow safeguarding procedure", "Promise to keep it secret", "Question the child repeatedly for every detail"),
		s("Two children want the same resource and the conflict is escalating. What helps development?", "Name feelings, keep everyone safe, and coach a fair solution", "Take it away permanently without explanation", "Let the larger child decide"),
		s("A family asks how their child is progressing. What is useful?", "Share specific observations, strengths, needs, and agreed next steps", "Compare the child harshly with peers", "Give a vague answer with no examples")
	]
	return rounds[index]


static func response_round(role: String, workplace: String, index: int) -> Dictionary:
	var rounds := [
		s("The %s at %s arrives first to a fast-changing incident." % [role, workplace], "Assess hazards, establish priorities, communicate, and act within training", "Enter immediately without assessing the scene", "Wait for a perfect plan before helping anyone"),
		s("New information changes the risk picture during operations. What should happen?", "Update the plan, brief the team, and maintain accountability", "Keep the original plan so no one gets confused", "Let each person improvise independently"),
		s("After a difficult call, signs of strain appear across the team. What is responsible?", "Complete operational follow-up and connect people with peer and professional support", "Tell everyone to forget it", "Discuss private details in public")
	]
	return rounds[index]


static func support_round(role: String, workplace: String, index: int) -> Dictionary:
	var rounds := [
		s("A grieving person asks the %s at %s a question you cannot answer honestly." % [role, workplace], "Acknowledge the uncertainty, listen, and offer appropriate practical support", "Invent an answer to make them feel better", "Change the subject immediately"),
		s("Family members disagree during an emotionally difficult arrangement. What helps?", "Create calm space, clarify needs and authority, and document agreed decisions", "Take sides based on who called first", "Rush everyone so the schedule stays unchanged"),
		s("A person requests a tradition or practice unfamiliar to the team. What do you do?", "Ask respectfully, confirm safe accommodations, and involve trusted expertise", "Reject it because it is unfamiliar", "Pretend to understand and improvise")
	]
	return rounds[index]


static func s(prompt: String, correct: String, wrong_one: String, wrong_two: String) -> Dictionary:
	return {"prompt": prompt, "correct": correct, "wrong_one": wrong_one, "wrong_two": wrong_two}


static func shuffle_with_rng(values: Array, rng: RandomNumberGenerator) -> void:
	for index in range(values.size() - 1, 0, -1):
		var swap_index := rng.randi_range(0, index)
		var temporary = values[index]
		values[index] = values[swap_index]
		values[swap_index] = temporary
