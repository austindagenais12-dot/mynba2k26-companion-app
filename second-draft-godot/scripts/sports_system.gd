extends RefCounted
class_name SportsSystem


static func new_state() -> Dictionary:
	return {
		"sport_id": "",
		"sport_name": "",
		"stage": "none",
		"team": "",
		"position": "",
		"skill": 0,
		"fitness": 0,
		"game_iq": 0,
		"reputation": 0,
		"seasons": 0,
		"wins": 0,
		"losses": 0,
		"championships": 0,
		"last_training_year": -1,
		"last_season_year": -1,
		"draft_result": "",
		"retired": false
	}


static func join_sport(current: Dictionary, sport_id: String, age: int, year: int, stats: Dictionary, rng: RandomNumberGenerator) -> Dictionary:
	if not str(current.get("sport_id", "")).is_empty() and not bool(current.get("retired", false)):
		return {"ok": false, "message": "You are already committed to a sport.", "state": current}
	var sport := find_sport(sport_id)
	if sport.is_empty():
		return {"ok": false, "message": "Sport not found.", "state": current}
	if age < int(sport.get("start_age", 6)):
		return {"ok": false, "message": "This program opens at age %d." % int(sport.get("start_age", 6)), "state": current}
	if age > 17:
		return {"ok": false, "message": "The competitive development pathway must begin during school or youth club years.", "state": current}
	var health := int(stats.get("health", 50))
	var discipline := int(stats.get("discipline", 50))
	var confidence := int(stats.get("confidence", 50))
	var state := new_state()
	state["sport_id"] = sport_id
	state["sport_name"] = str(sport.get("name", "Sport"))
	state["stage"] = "youth" if age < 12 else "school"
	state["team"] = generate_team_name(rng, str(sport.get("name", "Sport")), false)
	var positions: Array = sport.get("positions", ["Competitor"])
	state["position"] = str(positions[rng.randi_range(0, positions.size() - 1)])
	state["skill"] = clampi(14 + int(float(health + discipline) / 8.0) + rng.randi_range(-4, 7), 12, 46)
	state["fitness"] = clampi(int(float(health) * 0.72) + rng.randi_range(-4, 6), 15, 90)
	state["game_iq"] = clampi(14 + int(float(discipline) / 3.0) + rng.randi_range(-3, 6), 12, 60)
	state["reputation"] = clampi(int(float(confidence) / 4.0) + rng.randi_range(0, 8), 8, 45)
	state["last_training_year"] = year - 1
	state["last_season_year"] = year - 1
	return {"ok": true, "message": "You earned a development place in %s as a %s." % [state["sport_name"], state["position"]], "state": state}


static func training_action(current: Dictionary, action: String, year: int, rng: RandomNumberGenerator) -> Dictionary:
	if str(current.get("sport_id", "")).is_empty() or bool(current.get("retired", false)):
		return {"ok": false, "message": "Join a sport first.", "state": current}
	if int(current.get("last_training_year", -1)) == year:
		return {"ok": false, "message": "You already completed focused training this year.", "state": current}
	var state := current.duplicate(true)
	match action:
		"physical":
			state["fitness"] = int(state.get("fitness", 30)) + rng.randi_range(5, 9)
			state["skill"] = int(state.get("skill", 20)) + rng.randi_range(3, 6)
		"technical":
			state["skill"] = int(state.get("skill", 20)) + rng.randi_range(6, 10)
			state["game_iq"] = int(state.get("game_iq", 20)) + rng.randi_range(2, 5)
		"film":
			state["game_iq"] = int(state.get("game_iq", 20)) + rng.randi_range(6, 10)
			state["reputation"] = int(state.get("reputation", 20)) + rng.randi_range(1, 3)
		_:
			return {"ok": false, "message": "Training option not found.", "state": current}
	state["last_training_year"] = year
	clamp_state(state)
	return {"ok": true, "message": "Focused %s training improved your development profile." % action, "state": state}


static func can_play_season(state: Dictionary, year: int) -> bool:
	return not str(state.get("sport_id", "")).is_empty() and not bool(state.get("retired", false)) and int(state.get("last_season_year", -1)) != year


static func create_season_session(state: Dictionary, seed_value: int) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var sport := find_sport(str(state.get("sport_id", "")))
	var sport_name := str(sport.get("name", state.get("sport_name", "Sport")))
	var position := str(state.get("position", "competitor"))
	var category := str(sport.get("category", "team"))
	var rounds: Array = []
	for round_index in range(3):
		rounds.append(sports_round(rng, category, sport_name, position, round_index))
	return {
		"kind": "sports",
		"title": "%s SEASON" % sport_name.to_upper(),
		"subtitle": "%s • %s" % [str(state.get("team", "Development team")), position],
		"rounds": rounds,
		"round_index": 0,
		"score": 0
	}


static func complete_season(current: Dictionary, score: int, total: int, age: int, year: int, rng: RandomNumberGenerator) -> Dictionary:
	if not can_play_season(current, year):
		return {"ok": false, "message": "This season is already complete.", "state": current, "job": {}}
	var state := current.duplicate(true)
	var rating := int(round(float(score) / float(maxi(1, total)) * 100.0))
	state["last_season_year"] = year
	state["seasons"] = int(state.get("seasons", 0)) + 1
	state["skill"] = int(state.get("skill", 20)) + 2 + int(float(rating) / 18.0)
	state["game_iq"] = int(state.get("game_iq", 20)) + 1 + int(float(rating) / 28.0)
	state["reputation"] = int(state.get("reputation", 15)) + int(float(rating) / 14.0)
	var wins := clampi(3 + int(float(rating) / 10.0) + rng.randi_range(-2, 3), 1, 15)
	var losses := clampi(13 - wins + rng.randi_range(-1, 2), 0, 14)
	state["wins"] = int(state.get("wins", 0)) + wins
	state["losses"] = int(state.get("losses", 0)) + losses
	var championship := rating >= 88 and rng.randf() < 0.38
	if championship:
		state["championships"] = int(state.get("championships", 0)) + 1
		state["reputation"] = int(state.get("reputation", 20)) + 8
	clamp_state(state)
	var transition := process_stage_transition(state, age, rng)
	state = transition.get("state", state)
	var message := "%d–%d season, %d%% performance." % [wins, losses, rating]
	if championship:
		message += " Your team won a championship."
	if not str(transition.get("message", "")).is_empty():
		message += " " + str(transition.get("message", ""))
	return {"ok": true, "message": message, "state": state, "job": transition.get("job", {})}


static func process_year(current: Dictionary, age: int, year: int, rng: RandomNumberGenerator) -> Dictionary:
	if str(current.get("sport_id", "")).is_empty() or bool(current.get("retired", false)):
		return {"state": current, "message": "", "job": {}}
	var state := current.duplicate(true)
	if int(state.get("last_training_year", -1)) < year - 1:
		state["fitness"] = int(state.get("fitness", 40)) - 2
	if int(state.get("last_season_year", -1)) < year - 1:
		state["reputation"] = int(state.get("reputation", 20)) - 2
	var sport := find_sport(str(state.get("sport_id", "")))
	var retire_age := int(sport.get("retire_age", 36))
	if str(state.get("stage", "")) == "pro" and age >= retire_age:
		state["stage"] = "retired"
		state["retired"] = true
		return {"state": state, "message": "You retired from professional %s after %d seasons." % [state.get("sport_name", "sport"), state.get("seasons", 0)], "job": {}}
	var transition := process_stage_transition(state, age, rng)
	var transitioned_state: Dictionary = transition.get("state", state)
	clamp_state(transitioned_state)
	transition["state"] = transitioned_state
	return transition


static func process_stage_transition(current: Dictionary, age: int, rng: RandomNumberGenerator) -> Dictionary:
	var state := current.duplicate(true)
	var stage := str(state.get("stage", "none"))
	var rating := athlete_rating(state)
	var message := ""
	var job: Dictionary = {}
	if age >= 12 and stage == "youth":
		state["stage"] = "school"
		message = "You advanced into the school/academy competition level."
	elif age >= 18 and stage == "school":
		if rating >= 52:
			state["stage"] = "college"
			state["team"] = generate_team_name(rng, str(state.get("sport_name", "Sport")), false)
			message = "A college or elite development program offered you a roster place."
		else:
			state["stage"] = "amateur"
			message = "No major scholarship arrived, so you continued at the amateur level."
	elif age >= 21 and stage in ["college", "amateur"]:
		if rating >= 70:
			state["stage"] = "pro"
			state["team"] = generate_team_name(rng, str(state.get("sport_name", "Sport")), true)
			state["draft_result"] = "Selected for a professional roster at age %d" % age
			job = pro_job(state)
			message = "You earned a professional contract with %s." % state["team"]
		elif rating >= 56:
			state["stage"] = "developmental"
			message = "You entered a semi-professional development league and kept the dream alive."
		else:
			state["stage"] = "amateur"
	elif age >= 23 and stage == "developmental" and rating >= 74:
		state["stage"] = "pro"
		state["team"] = generate_team_name(rng, str(state.get("sport_name", "Sport")), true)
		state["draft_result"] = "Signed from a developmental league at age %d" % age
		job = pro_job(state)
		message = "A professional organization signed you after your developmental breakthrough."
	return {"state": state, "message": message, "job": job}


static func pro_job(state: Dictionary) -> Dictionary:
	var sport := find_sport(str(state.get("sport_id", "")))
	var base_salary := int(sport.get("base_salary", 65000))
	var rating := athlete_rating(state)
	var salary := int(round(float(base_salary) * (0.65 + float(rating) / 85.0)))
	return {
		"id": "professional_%s" % str(state.get("sport_id", "athlete")),
		"title": "Professional %s Athlete — %s" % [state.get("sport_name", "Sport"), state.get("team", "Pro Team")],
		"base_title": "Professional %s Athlete" % state.get("sport_name", "Sport"),
		"workplace": str(state.get("team", "Professional organization")),
		"sector": "Sports & Fitness",
		"salary": salary,
		"min_age": 18,
		"education": 0,
		"stat": "health",
		"minimum": 70,
		"level": 1,
		"rank": "Rookie",
		"sports_job": true
	}


static func athlete_rating(state: Dictionary) -> int:
	return clampi(int(round(float(int(state.get("skill", 0)) * 5 + int(state.get("fitness", 0)) * 2 + int(state.get("game_iq", 0)) * 2 + int(state.get("reputation", 0))) / 10.0)), 0, 100)


static func stage_label(stage: String) -> String:
	return str({"none": "Not competing", "youth": "Youth development", "school": "School / academy", "college": "College / elite development", "amateur": "Amateur", "developmental": "Semi-professional development", "pro": "Professional", "retired": "Retired athlete"}.get(stage, stage.capitalize()))


static func clamp_state(state: Dictionary) -> void:
	for key in ["skill", "fitness", "game_iq", "reputation"]:
		state[key] = clampi(int(state.get(key, 0)), 0, 100)


static func sports_round(rng: RandomNumberGenerator, category: String, sport_name: String, position: String, round_index: int) -> Dictionary:
	var prompt := ""
	var correct := ""
	var wrong_one := ""
	var wrong_two := ""
	match category:
		"combat":
			prompt = pick(rng, ["Your opponent keeps entering behind the same feint. What is the safest adjustment?", "You are ahead late but breathing heavily. What protects the result?", "The opponent changes stance and range. What do you read first?"])
			correct = pick(rng, ["Control distance, defend first, then counter", "Use efficient movement and choose clean openings", "Reset the guard and read the lead side"])
			wrong_one = "Trade recklessly to prove toughness"
			wrong_two = "Ignore the corner and repeat the same attack"
		"precision":
			prompt = pick(rng, ["Conditions change moments before your attempt. What should you adjust first?", "Your warm-up result drifts consistently to one side. What is the smart response?", "Pressure rises on the final attempt. What anchors the routine?"])
			correct = pick(rng, ["Recheck conditions and make one measured adjustment", "Trust the pre-shot routine and commit", "Confirm alignment before changing technique"])
			wrong_one = "Change every part of the technique at once"
			wrong_two = "Rush before the conditions change again"
		"race":
			prompt = pick(rng, ["The pace starts faster than planned. How do you respond?", "A competitor attacks before the decisive section. What is the best read?", "Fatigue appears earlier than expected. What preserves performance?"])
			correct = pick(rng, ["Hold the sustainable target and reassess at the split", "Protect technique and manage the effort", "Use the planned energy system before chasing"])
			wrong_one = "Sprint immediately and hope to hold on"
			wrong_two = "Abandon the plan without checking the gap"
		"artistic":
			prompt = pick(rng, ["A difficult element felt unstable in warm-up. What belongs in the routine?", "The previous competitor scores highly. How should that affect your performance?", "Music timing slips early. What restores the program?"])
			correct = pick(rng, ["Choose the version you can execute cleanly", "Stay inside your own performance plan", "Use the next choreographic landmark to resynchronize"])
			wrong_one = "Add an unpractised element for difficulty"
			wrong_two = "Stop performing and show the mistake"
		"bat_ball":
			prompt = pick(rng, ["The defense shifts toward your usual tendency. What is the productive response?", "With runners moving, what comes before the throw?", "The pitcher or bowler repeats a pattern. What should you track?"])
			correct = pick(rng, ["Read the situation and use the available space", "Secure the ball, set the feet, then make the play", "Track release, movement, and count before committing"])
			wrong_one = "Force the hardest possible play immediately"
			wrong_two = "Ignore the game situation and chase personal stats"
		"net":
			prompt = pick(rng, ["Your opponent attacks the same channel repeatedly. What adjustment helps?", "A long rally changes the spacing. What do you protect first?", "The serve or return pattern becomes predictable. What is the best response?"])
			correct = pick(rng, ["Change positioning while keeping coverage behind you", "Recover balance before attacking the next ball", "Vary placement without abandoning reliable technique"])
			wrong_one = "Stand closer and react later"
			wrong_two = "Attempt a winner from every contact"
		_:
			prompt = pick(rng, ["As the %s, you see pressure building away from the play. What do you do?" % position, "Your team loses its structure midway through the contest. What comes first?", "The opponent finds space behind one teammate. How do you solve it?"])
			correct = pick(rng, ["Communicate early and restore team shape", "Make the simple read that keeps possession", "Cover the dangerous space, then organize the next action"])
			wrong_one = "Leave your role and chase the highlight play"
			wrong_two = "Wait silently for someone else to fix it"
	var options: Array = [correct, wrong_one, wrong_two]
	shuffle_with_rng(options, rng)
	return {"prompt": "%s • Round %d: %s" % [sport_name, round_index + 1, prompt], "options": options, "correct_index": options.find(correct)}


static func generate_team_name(rng: RandomNumberGenerator, _sport_name: String, professional: bool) -> String:
	var places := ["Halifax", "Dartmouth", "Sydney", "Moncton", "Saint John", "Charlottetown", "St. John's", "Montreal", "Ottawa", "Toronto", "Hamilton", "Winnipeg", "Regina", "Saskatoon", "Calgary", "Edmonton", "Vancouver", "Victoria", "Kelowna", "Whitehorse"]
	var names := ["Harbour", "Northside", "Central", "West Ridge", "Lakeshore", "Coastal", "Valley", "Riverside"] if not professional else places
	var mascots := ["Wolves", "Ravens", "Storm", "Falcons", "Foxes", "Titans", "Bears", "Lynx", "Voyagers", "Ospreys", "Breakers", "Northern Lights"]
	return "%s %s" % [pick(rng, names), pick(rng, mascots)]


static func find_sport(sport_id: String) -> Dictionary:
	for sport in sports():
		if str(sport.get("id", "")) == sport_id:
			return sport.duplicate(true)
	return {}


static func sports() -> Array:
	return [
		sport("basketball", "Basketball", "team", 6, 36, 950000, ["Point Guard", "Shooting Guard", "Wing", "Forward", "Centre"]),
		sport("ice_hockey", "Ice Hockey", "team", 5, 37, 800000, ["Centre", "Winger", "Defenceman", "Goaltender"]),
		sport("soccer", "Soccer", "team", 5, 36, 420000, ["Goalkeeper", "Defender", "Midfielder", "Winger", "Forward"]),
		sport("baseball", "Baseball", "bat_ball", 6, 39, 720000, ["Pitcher", "Catcher", "Infielder", "Outfielder", "Designated Hitter"]),
		sport("football", "American Football", "team", 8, 33, 880000, ["Quarterback", "Running Back", "Receiver", "Lineman", "Linebacker", "Defensive Back", "Kicker"]),
		sport("volleyball", "Volleyball", "net", 8, 35, 110000, ["Setter", "Outside Hitter", "Middle Blocker", "Opposite", "Libero"]),
		sport("tennis", "Tennis", "net", 5, 36, 180000, ["Singles Player", "Doubles Player"]),
		sport("golf", "Golf", "precision", 6, 49, 240000, ["Tour Player"]),
		sport("track_field", "Track & Field", "race", 8, 34, 95000, ["Sprinter", "Distance Runner", "Hurdler", "Jumper", "Thrower", "Combined Events Athlete"]),
		sport("cross_country", "Cross-Country Running", "race", 8, 35, 70000, ["Distance Runner"]),
		sport("swimming", "Swimming", "race", 5, 32, 85000, ["Freestyle Specialist", "Backstroke Specialist", "Breaststroke Specialist", "Butterfly Specialist", "Medley Swimmer"]),
		sport("diving", "Diving", "artistic", 6, 31, 78000, ["Springboard Diver", "Platform Diver"]),
		sport("boxing", "Boxing", "combat", 10, 35, 160000, ["Amateur Boxer", "Professional Boxer"]),
		sport("mma", "Mixed Martial Arts", "combat", 12, 37, 190000, ["Mixed Martial Artist"]),
		sport("wrestling", "Wrestling", "combat", 7, 34, 90000, ["Freestyle Wrestler", "Greco-Roman Wrestler"]),
		sport("rugby", "Rugby", "team", 8, 35, 140000, ["Prop", "Hooker", "Lock", "Flanker", "Scrum-Half", "Fly-Half", "Centre", "Wing", "Fullback"]),
		sport("lacrosse", "Lacrosse", "team", 6, 34, 115000, ["Attack", "Midfield", "Defence", "Goaltender"]),
		sport("cricket", "Cricket", "bat_ball", 7, 39, 190000, ["Batter", "Bowler", "All-Rounder", "Wicketkeeper"]),
		sport("curling", "Curling", "precision", 8, 50, 65000, ["Lead", "Second", "Vice-Skip", "Skip"]),
		sport("figure_skating", "Figure Skating", "artistic", 5, 29, 105000, ["Singles Skater", "Pairs Skater", "Ice Dancer"]),
		sport("speed_skating", "Speed Skating", "race", 6, 34, 78000, ["Short Track Skater", "Long Track Skater"]),
		sport("alpine_skiing", "Alpine Skiing", "race", 5, 34, 120000, ["Slalom Skier", "Giant Slalom Skier", "Downhill Skier", "Super-G Skier"]),
		sport("snowboarding", "Snowboarding", "artistic", 6, 33, 115000, ["Halfpipe Rider", "Slopestyle Rider", "Snowboard Cross Racer"]),
		sport("gymnastics", "Gymnastics", "artistic", 5, 27, 92000, ["Artistic Gymnast", "Rhythmic Gymnast", "Trampoline Gymnast"]),
		sport("cycling", "Cycling", "race", 8, 38, 135000, ["Road Cyclist", "Track Cyclist", "Mountain Biker", "BMX Racer"]),
		sport("rowing", "Rowing", "race", 10, 38, 72000, ["Single Sculler", "Sweep Rower", "Coxswain"]),
		sport("badminton", "Badminton", "net", 7, 35, 90000, ["Singles Player", "Doubles Player"]),
		sport("table_tennis", "Table Tennis", "net", 6, 38, 88000, ["Singles Player", "Doubles Player"]),
		sport("field_hockey", "Field Hockey", "team", 7, 35, 92000, ["Forward", "Midfielder", "Defender", "Goalkeeper"]),
		sport("softball", "Softball", "bat_ball", 7, 36, 78000, ["Pitcher", "Catcher", "Infielder", "Outfielder"]),
		sport("handball", "Team Handball", "team", 8, 35, 95000, ["Goalkeeper", "Wing", "Back", "Centre", "Pivot"]),
		sport("water_polo", "Water Polo", "team", 9, 34, 82000, ["Goalkeeper", "Driver", "Centre Forward", "Centre Back"]),
		sport("skateboarding", "Skateboarding", "artistic", 7, 34, 110000, ["Street Skater", "Park Skater"]),
		sport("surfing", "Surfing", "artistic", 7, 37, 125000, ["Shortboard Surfer", "Longboard Surfer"]),
		sport("motorsport", "Motorsport", "race", 7, 42, 480000, ["Circuit Driver", "Rally Driver", "Karting Driver", "Endurance Driver"]),
		sport("esports", "Esports", "team", 10, 31, 165000, ["In-Game Leader", "Support", "Strategist", "Mechanical Specialist"])
	]


static func sport(id_value: String, name_value: String, category: String, start_age: int, retire_age: int, base_salary: int, positions: Array) -> Dictionary:
	return {"id": id_value, "name": name_value, "category": category, "start_age": start_age, "retire_age": retire_age, "base_salary": base_salary, "positions": positions}


static func shuffle_with_rng(values: Array, rng: RandomNumberGenerator) -> void:
	for index in range(values.size() - 1, 0, -1):
		var swap_index := rng.randi_range(0, index)
		var temporary = values[index]
		values[index] = values[swap_index]
		values[swap_index] = temporary


static func pick(rng: RandomNumberGenerator, values: Array) -> String:
	return str(values[rng.randi_range(0, values.size() - 1)])
