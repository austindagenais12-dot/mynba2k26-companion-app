extends RefCounted
class_name LifeGenerator


static func generate_identity(rng: RandomNumberGenerator, first_override: String = "", last_override: String = "") -> Dictionary:
	var sets: Array = name_sets()
	var selected_set: Dictionary = sets[rng.randi_range(0, sets.size() - 1)]
	var first_name := first_override.strip_edges()
	var last_name := last_override.strip_edges()
	if first_name.is_empty():
		first_name = random_first_name(rng, selected_set)
	if last_name.is_empty():
		last_name = random_last_name(rng, selected_set)
	var birthplace := random_item(rng, birthplaces())
	var background := random_item(rng, economic_backgrounds())
	var household := random_item(rng, household_types())
	var home := random_item(rng, childhood_homes())
	var trait := random_item(rng, childhood_traits())
	var challenge := random_item(rng, early_challenges())
	var life_seed := int(rng.randi()) * 65537 + int(rng.randi())
	var identity := random_item(rng, ["Woman", "Man", "Non-binary person"])
	var pronouns: String = str({"Woman": "she/her", "Man": "he/him", "Non-binary person": "they/them"}.get(identity, "they/them"))
	var parents: Array = generate_parents(rng, last_name, selected_set, household)
	var siblings: Array = generate_siblings(rng, last_name, selected_set)
	var stats: Dictionary = generate_starting_stats(rng, background, trait, challenge)
	var appearance: Dictionary = generate_appearance(rng, life_seed)
	var history: Array = generate_origin_history(rng, first_name, last_name, birthplace, parents, siblings, background, home, challenge)
	return {
		"life_seed": life_seed,
		"first_name": first_name,
		"last_name": last_name,
		"identity": identity,
		"pronouns": pronouns,
		"birthplace": birthplace,
		"birth_month": random_item(rng, ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]),
		"birth_day": rng.randi_range(1, 28),
		"background": {
			"economic": background,
			"household": household,
			"home": home,
			"childhood_trait": trait,
			"early_challenge": challenge,
			"family_tradition": random_item(rng, family_traditions())
		},
		"parents": parents,
		"siblings": siblings,
		"stats": stats,
		"appearance": appearance,
		"history": history
	}


static func random_identity_preview() -> Dictionary:
	var preview_rng := RandomNumberGenerator.new()
	preview_rng.randomize()
	return generate_identity(preview_rng)


static func random_person_name(rng: RandomNumberGenerator, preferred_last_name: String = "") -> String:
	var sets: Array = name_sets()
	var selected_set: Dictionary = sets[rng.randi_range(0, sets.size() - 1)]
	var family_name := preferred_last_name.strip_edges()
	if family_name.is_empty() or rng.randf() < 0.34:
		family_name = random_last_name(rng, selected_set)
	return "%s %s" % [random_first_name(rng, selected_set), family_name]


static func random_first_name(rng: RandomNumberGenerator, selected_set: Dictionary = {}) -> String:
	var source: Dictionary = selected_set
	if source.is_empty():
		var available_sets: Array = name_sets()
		source = available_sets[rng.randi_range(0, available_sets.size() - 1)]
	var first_values: Array = source.get("first", ["Alex"])
	return random_item(rng, first_values)


static func random_last_name(rng: RandomNumberGenerator, selected_set: Dictionary = {}) -> String:
	var source: Dictionary = selected_set
	if source.is_empty():
		var available_sets: Array = name_sets()
		source = available_sets[rng.randi_range(0, available_sets.size() - 1)]
	var last_values: Array = source.get("last", ["Morgan"])
	var primary := random_item(rng, last_values)
	if rng.randf() < 0.16:
		var secondary_sets: Array = name_sets()
		var second_set: Dictionary = secondary_sets[rng.randi_range(0, secondary_sets.size() - 1)]
		var secondary_values: Array = second_set.get("last", ["Lee"])
		var secondary := random_item(rng, secondary_values)
		if secondary != primary:
			return "%s-%s" % [primary, secondary]
	return primary


static func generate_parents(rng: RandomNumberGenerator, family_name: String, selected_set: Dictionary, household: String) -> Array:
	var parents: Array = []
	var parent_count := 1 if household in ["Single-parent household", "Raised by one devoted guardian"] else 2
	if household == "Multigenerational household" and rng.randf() < 0.35:
		parent_count = 3
	var relation_pool := ["Mother", "Father", "Parent", "Guardian"]
	for index in range(parent_count):
		var relation := str(relation_pool[index % relation_pool.size()])
		if parent_count == 1 and household == "Raised by one devoted guardian":
			relation = "Guardian"
		var parent_last := family_name if rng.randf() < 0.72 else random_last_name(rng, selected_set)
		parents.append({
			"name": "%s %s" % [random_first_name(rng, selected_set), parent_last],
			"relation": relation,
			"age": rng.randi_range(20, 44),
			"value": rng.randi_range(62, 94),
			"job": random_item(rng, parent_jobs()),
			"personality": random_item(rng, parent_traits()),
			"alive": true
		})
	return parents


static func generate_siblings(rng: RandomNumberGenerator, family_name: String, selected_set: Dictionary) -> Array:
	var roll := rng.randi_range(1, 100)
	var count := 0
	if roll > 42 and roll <= 76:
		count = 1
	elif roll > 76 and roll <= 93:
		count = 2
	elif roll > 93:
		count = 3
	var siblings: Array = []
	for _index in range(count):
		var relation := random_item(rng, ["Older sibling", "Older stepsibling", "Older half-sibling"])
		var sibling_age := rng.randi_range(1, 12)
		if rng.randf() < 0.08:
			relation = "Twin sibling"
			sibling_age = 0
		siblings.append({
			"name": "%s %s" % [random_first_name(rng, selected_set), family_name],
			"relation": relation,
			"age": sibling_age,
			"value": rng.randi_range(55, 88),
			"personality": random_item(rng, childhood_traits())
		})
	return siblings


static func generate_starting_stats(rng: RandomNumberGenerator, background: String, trait: String, challenge: String) -> Dictionary:
	var stats := {
		"health": rng.randi_range(68, 96),
		"happiness": rng.randi_range(56, 92),
		"smarts": rng.randi_range(35, 74),
		"confidence": rng.randi_range(30, 72),
		"discipline": rng.randi_range(30, 72),
		"reputation": rng.randi_range(42, 62)
	}
	if "wealth" in background.to_lower() or "affluent" in background.to_lower():
		stats["happiness"] = int(stats["happiness"]) + 4
		stats["confidence"] = int(stats["confidence"]) + 4
	if "uncertain" in background.to_lower() or "struggling" in background.to_lower():
		stats["discipline"] = int(stats["discipline"]) + 5
		stats["happiness"] = int(stats["happiness"]) - 5
	match trait:
		"Curious": stats["smarts"] = int(stats["smarts"]) + 9
		"Fearless": stats["confidence"] = int(stats["confidence"]) + 9
		"Patient": stats["discipline"] = int(stats["discipline"]) + 9
		"Empathetic": stats["reputation"] = int(stats["reputation"]) + 7
		"Energetic": stats["health"] = int(stats["health"]) + 7
	if challenge == "A difficult first year of health":
		stats["health"] = int(stats["health"]) - 12
	for key in stats:
		stats[key] = clampi(int(stats[key]), 15, 100)
	return stats


static func generate_appearance(rng: RandomNumberGenerator, life_seed: int) -> Dictionary:
	var skin_index := rng.randi_range(0, skin_palettes().size() - 1)
	var skin_pair: Array = skin_palettes()[skin_index]
	return {
		"portrait_seed": life_seed,
		"skin": str(skin_pair[0]),
		"skin_shadow": str(skin_pair[1]),
		"hair_color": random_item(rng, ["16131a", "2a1d19", "4b3024", "6f4a2b", "a56d35", "d6b16b", "813b32", "343239", "c4c6cc"]),
		"eye_color": random_item(rng, ["293849", "4a2f26", "5b7048", "386b79", "6c5635", "2e2525", "708396"]),
		"outfit_color": random_item(rng, ["173a5e", "284d3f", "5a284b", "493c78", "7a3d2b", "2b5263", "3f4654", "6b552b"]),
		"accent_color": random_item(rng, ["46c2a6", "ffb65b", "ef7184", "5ea9dd", "b68cff", "75d6e8"]),
		"face_shape": rng.randi_range(0, 4),
		"hair_style": rng.randi_range(0, 7),
		"eye_style": rng.randi_range(0, 3),
		"brow_style": rng.randi_range(0, 3),
		"nose_style": rng.randi_range(0, 3),
		"beard_style": rng.randi_range(0, 4),
		"glasses": rng.randf() < 0.24,
		"freckles": rng.randf() < 0.22,
		"earrings": rng.randf() < 0.18,
		"hair_texture": rng.randi_range(0, 3),
		"background_style": rng.randi_range(0, 5)
	}


static func generate_origin_history(rng: RandomNumberGenerator, first_name: String, last_name: String, birthplace: String, parents: Array, siblings: Array, background: String, home: String, challenge: String) -> Array:
	var weather := random_item(rng, ["under a clear morning sky", "during a hard spring rain", "on a quiet winter night", "as the first snow arrived", "during a humid summer afternoon", "just before sunrise", "while a thunderstorm rolled past"])
	var parent_names: Array[String] = []
	for parent in parents:
		parent_names.append(str(parent.get("name", "a guardian")))
	var family_text := "The household began with %s" % ", ".join(PackedStringArray(parent_names))
	if not siblings.is_empty():
		family_text += " and %d sibling%s nearby" % [siblings.size(), "" if siblings.size() == 1 else "s"]
	return [
		{"age": 0, "year": 2026, "title": "Born in %s" % birthplace, "body": "%s %s arrived %s. No other life will begin in exactly the same way." % [first_name, last_name, weather], "tone": "gold"},
		{"age": 0, "year": 2026, "title": "The first circle", "body": "%s. Their personalities, work, and choices will shape the years ahead." % family_text, "tone": "rose"},
		{"age": 0, "year": 2026, "title": "Starting circumstances", "body": "The family lived in %s with %s. Early life was marked by %s." % [home, background.to_lower(), challenge.to_lower()], "tone": "blue"}
	]


static func random_item(rng: RandomNumberGenerator, values: Array) -> String:
	if values.is_empty():
		return ""
	return str(values[rng.randi_range(0, values.size() - 1)])


static func name_sets() -> Array:
	return [
		{"first": ["Alex", "Avery", "Blake", "Cameron", "Casey", "Charlie", "Dakota", "Drew", "Elliot", "Emerson", "Finley", "Hayden", "Jamie", "Jordan", "Kai", "Logan", "Morgan", "Parker", "Quinn", "Reese", "Riley", "Rowan", "Sam", "Skyler"], "last": ["Anderson", "Bennett", "Brooks", "Campbell", "Carter", "Clark", "Collins", "Foster", "Fraser", "Grant", "Hall", "Hayes", "Morgan", "Parker", "Reid", "Scott", "Taylor", "Walker"]},
		{"first": ["Adrian", "Amelia", "Arthur", "Beatrice", "Clara", "Daniel", "Elena", "Felix", "Gabriel", "Isabelle", "Julian", "Leo", "Lucas", "Maya", "Nora", "Oliver", "Sofia", "Theo", "Valerie", "Victor"], "last": ["Bernard", "Dubois", "Fournier", "Gagnon", "Girard", "Lambert", "Laurent", "Leclerc", "Lefebvre", "Marchand", "Mercier", "Moreau", "Roy", "Tremblay", "Villeneuve"]},
		{"first": ["Aarav", "Aisha", "Amara", "Anaya", "Arjun", "Dev", "Diya", "Ishaan", "Kabir", "Kiran", "Maya", "Meera", "Naveen", "Nisha", "Priya", "Rohan", "Saanvi", "Samir", "Tara", "Zoya"], "last": ["Bains", "Chandra", "Gill", "Kapoor", "Kaur", "Khan", "Malik", "Mehta", "Patel", "Rai", "Rao", "Sandhu", "Shah", "Sharma", "Singh"]},
		{"first": ["Akira", "Ari", "Bo", "Chen", "Hana", "Haruto", "Hyejin", "Jia", "Jin", "Jun", "Kenji", "Lian", "Mei", "Min", "Ren", "Riku", "Sora", "Tao", "Yuna", "Yuto"], "last": ["Chen", "Choi", "Fujimoto", "Ito", "Kim", "Lee", "Li", "Lin", "Liu", "Mori", "Nakamura", "Park", "Sato", "Tanaka", "Wang", "Wu", "Zhang"]},
		{"first": ["Alejandro", "Alma", "Camila", "Carlos", "Diego", "Eliana", "Emilio", "Eva", "Gabriela", "Ines", "Javier", "Lola", "Lucia", "Mateo", "Nico", "Rafael", "Santiago", "Valentina", "Ximena", "Zoe"], "last": ["Alvarez", "Castillo", "Cruz", "Diaz", "Flores", "Garcia", "Gomez", "Herrera", "Lopez", "Martinez", "Morales", "Navarro", "Ramirez", "Reyes", "Rivera", "Santos", "Torres"]},
		{"first": ["Amari", "Ayana", "Chidi", "Dalia", "Elijah", "Eshe", "Idris", "Imani", "Jabari", "Kofi", "Layla", "Malik", "Nia", "Noah", "Omar", "Sade", "Samira", "Tariq", "Zara", "Zuri"], "last": ["Abebe", "Adeyemi", "Diallo", "Hassan", "Ibrahim", "Kamara", "Mensah", "Ndlovu", "Okafor", "Saleh", "Sow", "Tesfaye", "Traore", "Yusuf"]},
		{"first": ["Aiden", "Aoife", "Callum", "Ciara", "Declan", "Eamon", "Erin", "Fiona", "Kieran", "Maeve", "Niamh", "Orla", "Ronan", "Rory", "Sean", "Siobhan"], "last": ["Byrne", "Doyle", "Gallagher", "Kelly", "Kennedy", "McCarthy", "McLeod", "Murphy", "O'Brien", "O'Connor", "O'Neill", "Sullivan", "Walsh"]}
	]


static func birthplaces() -> Array:
	return ["Halifax, Nova Scotia", "Dartmouth, Nova Scotia", "Sydney, Nova Scotia", "Moncton, New Brunswick", "Saint John, New Brunswick", "Charlottetown, Prince Edward Island", "St. John's, Newfoundland and Labrador", "Montreal, Quebec", "Quebec City, Quebec", "Sherbrooke, Quebec", "Ottawa, Ontario", "Toronto, Ontario", "Hamilton, Ontario", "London, Ontario", "Kingston, Ontario", "Thunder Bay, Ontario", "Winnipeg, Manitoba", "Regina, Saskatchewan", "Saskatoon, Saskatchewan", "Calgary, Alberta", "Edmonton, Alberta", "Red Deer, Alberta", "Vancouver, British Columbia", "Victoria, British Columbia", "Kelowna, British Columbia", "Prince George, British Columbia", "Whitehorse, Yukon", "Yellowknife, Northwest Territories", "Iqaluit, Nunavut", "Boston, Massachusetts", "London, England", "Dublin, Ireland", "Lagos, Nigeria", "Delhi, India", "Manila, Philippines", "Seoul, South Korea", "Mexico City, Mexico"]


static func economic_backgrounds() -> Array:
	return ["a stable working-class income", "a comfortable middle-class income", "an affluent household with financial security", "a family business with unpredictable months", "a modest household that carefully budgeted", "financial uncertainty and frequent tradeoffs", "a rural household rich in land but short on cash", "a newly arrived family rebuilding from the beginning", "generational wealth paired with high expectations", "a struggling household held together by resourcefulness"]


static func household_types() -> Array:
	return ["Two-parent household", "Single-parent household", "Multigenerational household", "Blended household", "Raised by one devoted guardian", "Adoptive household", "Foster-to-adopt household"]


static func childhood_homes() -> Array:
	return ["a small city apartment", "a busy suburban townhouse", "a weathered rural farmhouse", "a quiet coastal home", "a multigenerational family house", "a compact northern community home", "a rented duplex near downtown", "a home above the family business", "a crowded but lively row house", "a newly built suburban home"]


static func childhood_traits() -> Array:
	return ["Curious", "Fearless", "Patient", "Empathetic", "Energetic", "Observant", "Competitive", "Imaginative", "Independent", "Playful", "Cautious", "Stubborn"]


static func early_challenges() -> Array:
	return ["A difficult first year of health", "A parent working long shifts", "A move shortly after birth", "A home filled with extended family", "A calm and secure infancy", "An unexpected financial setback", "A close bond with a grandparent", "A noisy home where someone was always awake", "A community that quickly became family", "A parent returning to school"]


static func family_traditions() -> Array:
	return ["Sunday dinners", "summer road trips", "music in the kitchen", "weekend hockey", "storytelling after supper", "community volunteering", "holiday baking", "camping near the water", "board-game nights", "big birthday breakfasts", "watching every hometown game"]


static func parent_jobs() -> Array:
	return ["Nurse", "Carpenter", "Teacher", "Truck Driver", "Accountant", "Cook", "Electrician", "Retail Manager", "Software Developer", "Paramedic", "Small Business Owner", "Mechanic", "Social Worker", "Office Administrator", "Construction Worker", "Civil Servant", "Fisher", "Farm Worker", "Graphic Designer", "Police Officer", "Caregiver", "Laboratory Technician", "Sales Representative", "Hotel Worker", "Musician", "Student", "Between jobs"]


static func parent_traits() -> Array:
	return ["warm and expressive", "quietly dependable", "ambitious and demanding", "funny under pressure", "protective but cautious", "restless and adventurous", "patient and practical", "creative and unpredictable", "strict about routines", "deeply community-minded", "reserved but affectionate"]


static func skin_palettes() -> Array:
	return [["f2d2bd", "d8aa91"], ["e7bd9d", "c98c6d"], ["d9a17e", "b97859"], ["bd7b56", "96563e"], ["995f43", "75412f"], ["764832", "573021"], ["513326", "382218"], ["c58c68", "9d6248"]]
