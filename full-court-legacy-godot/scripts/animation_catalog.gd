extends RefCounted

const LOCOMOTION := [
	{"name": "Compact Guard", "cadence": 1.13, "stride": 0.78, "bob": 0.74, "arm": 0.82},
	{"name": "Balanced", "cadence": 1.0, "stride": 1.0, "bob": 1.0, "arm": 1.0},
	{"name": "Long Stride", "cadence": 0.88, "stride": 1.24, "bob": 1.06, "arm": 1.12},
	{"name": "Explosive", "cadence": 1.2, "stride": 1.08, "bob": 1.2, "arm": 1.18},
	{"name": "Shifty", "cadence": 1.16, "stride": 0.9, "bob": 0.86, "arm": 0.92},
	{"name": "Power", "cadence": 0.92, "stride": 1.16, "bob": 1.12, "arm": 1.08},
	{"name": "Upright", "cadence": 1.02, "stride": 0.94, "bob": 0.68, "arm": 0.88},
	{"name": "Low Stance", "cadence": 1.08, "stride": 1.02, "bob": 0.82, "arm": 1.04}
]

const RELEASE := [
	{"name": "Smooth One-Motion", "height": 1.0, "speed": 1.0, "jump": 0.92, "follow": 1.0},
	{"name": "Quick Guard", "height": 0.94, "speed": 1.22, "jump": 0.78, "follow": 0.88},
	{"name": "High Release", "height": 1.14, "speed": 0.94, "jump": 1.02, "follow": 1.12},
	{"name": "Compact Set", "height": 0.9, "speed": 1.12, "jump": 0.66, "follow": 0.82},
	{"name": "Elevated", "height": 1.08, "speed": 0.96, "jump": 1.25, "follow": 1.06},
	{"name": "Rhythm", "height": 1.02, "speed": 0.88, "jump": 1.0, "follow": 1.18},
	{"name": "Fast Snap", "height": 0.98, "speed": 1.3, "jump": 0.84, "follow": 0.74},
	{"name": "Classic", "height": 1.06, "speed": 0.92, "jump": 1.08, "follow": 1.22}
]

const HANDLE := [
	{"name": "Tight", "reach": 0.84, "lean": 0.86, "speed": 1.16},
	{"name": "Rhythm", "reach": 1.0, "lean": 1.0, "speed": 1.0},
	{"name": "Low", "reach": 0.9, "lean": 1.16, "speed": 1.14},
	{"name": "Wide", "reach": 1.2, "lean": 1.08, "speed": 0.94},
	{"name": "Power", "reach": 1.08, "lean": 1.24, "speed": 0.9},
	{"name": "Creative", "reach": 1.14, "lean": 1.12, "speed": 1.24}
]

const TEMPO := [
	{"name": "Controlled", "cadence": 0.92, "response": 0.9, "stance": 1.0},
	{"name": "Quick", "cadence": 1.08, "response": 1.12, "stance": 0.92},
	{"name": "Explosive", "cadence": 1.18, "response": 1.2, "stance": 1.12},
	{"name": "Deliberate", "cadence": 0.84, "response": 0.82, "stance": 1.08},
	{"name": "Fluid", "cadence": 1.0, "response": 1.0, "stance": 0.96},
	{"name": "Physical", "cadence": 0.96, "response": 1.06, "stance": 1.2}
]

const TOTAL_STYLES := 2304

static func get_profile(style_index: int) -> Dictionary:
	var normalized := posmod(style_index, TOTAL_STYLES)
	var cursor := normalized
	var locomotion_index := cursor % LOCOMOTION.size()
	cursor = int(cursor / LOCOMOTION.size())
	var release_index := cursor % RELEASE.size()
	cursor = int(cursor / RELEASE.size())
	var handle_index := cursor % HANDLE.size()
	cursor = int(cursor / HANDLE.size())
	var tempo_index := cursor % TEMPO.size()
	var locomotion: Dictionary = LOCOMOTION[locomotion_index]
	var release: Dictionary = RELEASE[release_index]
	var handle: Dictionary = HANDLE[handle_index]
	var tempo: Dictionary = TEMPO[tempo_index]
	return {
		"index": normalized,
		"name": "%s / %s / %s / %s" % [locomotion.name, release.name, handle.name, tempo.name],
		"locomotion_name": locomotion.name,
		"release_name": release.name,
		"handle_name": handle.name,
		"tempo_name": tempo.name,
		"cadence_scale": float(locomotion.cadence) * float(tempo.cadence),
		"stride_scale": float(locomotion.stride),
		"bob_scale": float(locomotion.bob),
		"arm_swing_scale": float(locomotion.arm),
		"release_height": float(release.height),
		"release_speed": float(release.speed),
		"jump_scale": float(release.jump),
		"follow_through": float(release.follow),
		"dribble_reach": float(handle.reach),
		"crossover_lean": float(handle.lean),
		"handle_speed": float(handle.speed),
		"pose_response": float(tempo.response),
		"stance_scale": float(tempo.stance)
	}

static func get_display_name(style_index: int) -> String:
	var profile := get_profile(style_index)
	return "#%04d  %s" % [int(profile.index) + 1, str(profile.name)]

static func random_style(rng: RandomNumberGenerator) -> int:
	return rng.randi_range(0, TOTAL_STYLES - 1)
