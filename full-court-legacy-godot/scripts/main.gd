extends Node3D

const HUDScript = preload("res://scripts/hud.gd")
const CareerStore = preload("res://scripts/career_store.gd")
const PlayerModelScript = preload("res://scripts/anime_player_model.gd")
const BasketballPhysicsScript = preload("res://scripts/basketball_physics.gd")
const NetPhysicsScript = preload("res://scripts/net_physics.gd")
const AnimationCatalog = preload("res://scripts/animation_catalog.gd")

const SESSION_LENGTH := 120.0
const NAVY := Color("#061735")
const LAKE_BLUE := Color("#0B74BB")
const ICE := Color("#E4F5FF")
const STEEL := Color("#596671")
const ORANGE := Color("#E76516")
const SKIN := Color("#885039")

var materials: Dictionary = {}
var profile: Dictionary = {}
var rng := RandomNumberGenerator.new()

var hud
var player: CharacterBody3D
var defender: CharacterBody3D
var player_model
var defender_model
var ball: RigidBody3D
var net_simulator: Node3D
var camera: Camera3D
var score_zone: Area3D
var hoop_target := Vector3(0.0, 3.05, 11.72)

var session_active := false
var session_score := 0
var session_makes := 0
var session_attempts := 0
var time_remaining := SESSION_LENGTH
var session_ended_at := 0.0

var ball_possessed := true
var dribble_phase := PI * 0.5
var dribble_side := 1
var ball_released_at := -100.0
var last_attempt_at := -100.0
var ball_return_delay := -1.0
var shot_token := 0
var processed_score_token := -1
var last_shot_value := 2

var is_sprinting := false
var charging_shot := false
var previous_shoot_held := false
var shot_charge_time := 0.0
var crossover_cooldown := 0.0
var previous_cross_key := false
var previous_reset_key := false
var previous_motion_key := false
var motion_style_index := 0

var defender_lateral_noise := Vector3.ZERO
var defender_next_read := 0.0

func _ready() -> void:
	Engine.max_fps = 60
	DisplayServer.screen_set_orientation(DisplayServer.SCREEN_LANDSCAPE)
	rng.randomize()
	profile = CareerStore.load_profile()
	if str(profile.get("player_name", "ROOKIE")) == "ROOKIE":
		profile.player_name = "AUSTIN"
		CareerStore.save_profile(profile)
	motion_style_index = posmod(int(profile.get("animation_style", 0)), AnimationCatalog.TOTAL_STYLES)
	_build_materials()
	_build_environment()
	_build_hoop()
	_build_characters()
	_build_ball()
	_build_net()
	_build_camera()
	_build_hud()
	_start_session(true)

func _physics_process(delta: float) -> void:
	var now := _now()
	if session_active:
		time_remaining = maxf(0.0, time_remaining - delta)
		hud.set_clock(time_remaining)
		if time_remaining <= 0.0:
			_end_session()
	elif now - session_ended_at >= 5.2:
		_start_session(false)

	crossover_cooldown -= delta
	_process_motion_style_input()
	_process_player(delta)
	_process_defender(delta, now)
	_update_character_animations(delta)
	_process_possessed_ball(delta)
	_process_camera(delta)
	_process_loose_ball(delta, now)

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_WM_CLOSE_REQUEST:
		if not profile.is_empty():
			CareerStore.save_profile(profile)

func _exit_tree() -> void:
	if not profile.is_empty():
		CareerStore.save_profile(profile)

func _build_materials() -> void:
	materials.court = _make_court_material()
	materials.navy = _make_material(NAVY, 0.42)
	materials.blue = _make_material(LAKE_BLUE, 0.38)
	materials.ice = _make_material(ICE, 0.32)
	materials.steel = _make_material(STEEL, 0.3, 0.14)
	materials.orange = _make_material(ORANGE, 0.5)
	materials.skin = _make_material(SKIN, 0.52)
	materials.line = _make_material(ICE, 0.75, 0.0, true)
	materials.dark = _make_material(Color("#0B1018"), 0.62)
	materials.green = _make_material(Color("#35FF6C"), 0.5, 0.0, true)
	materials.concrete = _make_material(Color("#D8D7D0"), 0.9)
	materials.acoustic = _make_material(Color("#AEB5BD"), 0.82)
	materials.charcoal = _make_material(Color("#222B34"), 0.72, 0.08)
	materials.bleacher = _make_material(Color("#17375C"), 0.66)
	materials.rubber = _make_material(Color("#15243A"), 0.9)
	materials.silver = _make_material(Color("#9AA7B2"), 0.34, 0.48)
	materials.wood = _make_material(Color("#B9824B"), 0.46)
	materials.red = _make_material(Color("#C62832"), 0.55)
	materials.glass = _make_material(Color(0.45, 0.72, 0.88, 0.52), 0.12, 0.08)
	materials.glass.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA

func _build_environment() -> void:
	var world_environment := WorldEnvironment.new()
	world_environment.name = "GymEnvironment"
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color("#A9C5D6")
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("#D7E4EC")
	environment.ambient_light_energy = 0.48
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	world_environment.environment = environment
	add_child(world_environment)

	var key_light := DirectionalLight3D.new()
	key_light.name = "ClerestoryDaylight"
	key_light.light_color = Color("#F4FAFF")
	key_light.light_energy = 0.92
	key_light.shadow_enabled = true
	key_light.rotation_degrees = Vector3(-52.0, -31.0, 0.0)
	add_child(key_light)

	var gym := Node3D.new()
	gym.name = "LakeshoreRealLifeGym"
	add_child(gym)

	# Layered floor assembly: dark resilient apron around a polished maple court.
	_make_box(gym, "GymFloorSlab", Vector3(0.0, -0.21, 0.0), Vector3(17.2, 0.22, 29.2), materials.charcoal, true)
	_make_box(gym, "Court", Vector3(0.0, -0.08, 0.0), Vector3(15.2, 0.16, 28.4), materials.court, true)
	_make_box(gym, "WestCourtApron", Vector3(-7.9, -0.075, 0.0), Vector3(0.65, 0.15, 28.4), materials.navy, false)
	_make_box(gym, "EastCourtApron", Vector3(7.9, -0.075, 0.0), Vector3(0.65, 0.15, 28.4), materials.navy, false)

	# Full-height masonry shell with acoustic upper panels and structural columns.
	_make_box(gym, "NorthCinderblockWall", Vector3(0.0, 2.45, 14.55), Vector3(17.4, 4.9, 0.3), materials.concrete, true)
	_make_box(gym, "SouthCinderblockWall", Vector3(0.0, 2.45, -14.55), Vector3(17.4, 4.9, 0.3), materials.concrete, true)
	_make_box(gym, "WestCinderblockWall", Vector3(-8.55, 2.45, 0.0), Vector3(0.3, 4.9, 29.4), materials.concrete, true)
	_make_box(gym, "EastCinderblockWall", Vector3(8.55, 2.45, 0.0), Vector3(0.3, 4.9, 29.4), materials.concrete, true)
	_make_box(gym, "NorthAcousticWall", Vector3(0.0, 6.45, 14.55), Vector3(17.4, 3.1, 0.3), materials.acoustic, false)
	_make_box(gym, "SouthAcousticWall", Vector3(0.0, 6.45, -14.55), Vector3(17.4, 3.1, 0.3), materials.acoustic, false)
	_make_box(gym, "WestAcousticWall", Vector3(-8.55, 6.45, 0.0), Vector3(0.3, 3.1, 29.4), materials.acoustic, false)
	_make_box(gym, "EastAcousticWall", Vector3(8.55, 6.45, 0.0), Vector3(0.3, 3.1, 29.4), materials.acoustic, false)
	_make_box(gym, "InsulatedRoof", Vector3(0.0, 8.5, 0.0), Vector3(17.4, 0.18, 29.4), materials.charcoal, false)

	for x in [-8.15, -5.45, -2.72, 0.0, 2.72, 5.45, 8.15]:
		_make_box(gym, "NorthWallColumn", Vector3(x, 4.25, 14.36), Vector3(0.16, 8.2, 0.18), materials.silver, false)
		_make_box(gym, "SouthWallColumn", Vector3(x, 4.25, -14.36), Vector3(0.16, 8.2, 0.18), materials.silver, false)
	for z in [-13.7, -9.15, -4.58, 0.0, 4.58, 9.15, 13.7]:
		_make_box(gym, "WestWallColumn", Vector3(-8.36, 4.25, z), Vector3(0.18, 8.2, 0.16), materials.silver, false)
		_make_box(gym, "EastWallColumn", Vector3(8.36, 4.25, z), Vector3(0.18, 8.2, 0.16), materials.silver, false)

	# Safety padding is broken into realistic upholstered panels.
	for panel_index in range(11):
		var panel_x := -7.35 + panel_index * 1.47
		_make_box(gym, "NorthSafetyPad%d" % panel_index, Vector3(panel_x, 1.18, 14.33), Vector3(1.39, 2.18, 0.18), materials.rubber, false)
		_make_box(gym, "SouthSafetyPad%d" % panel_index, Vector3(panel_x, 1.18, -14.33), Vector3(1.39, 2.18, 0.18), materials.rubber, false)
	_make_box(gym, "NorthLakeBlueRail", Vector3(0.0, 2.35, 14.2), Vector3(16.4, 0.12, 0.09), materials.blue, false)
	_make_box(gym, "SouthLakeBlueRail", Vector3(0.0, 2.35, -14.2), Vector3(16.4, 0.12, 0.09), materials.blue, false)

	_build_real_bleachers(gym)
	_build_gym_windows(gym)
	_build_gym_doors(gym)
	_build_ceiling_structure(gym)
	_build_scoreboard_and_banners(gym)
	_build_gym_furniture(gym)
	_build_lakeshore_wall_branding(gym)

	var line_y := 0.012
	_make_polyline(gym, [
		Vector3(-7.2, line_y, -13.6), Vector3(7.2, line_y, -13.6),
		Vector3(7.2, line_y, 13.6), Vector3(-7.2, line_y, 13.6)
	], 0.055, materials.line, true)
	_make_polyline(gym, [Vector3(-7.2, line_y, 0.0), Vector3(7.2, line_y, 0.0)], 0.05, materials.line, false)
	_make_polyline(gym, _circle_points(Vector3(0.0, line_y, 0.0), 1.8, 56), 0.05, materials.line, true)
	_build_key_lines(gym, line_y, 1.0)
	_build_key_lines(gym, line_y, -1.0)
	_build_three_point_line(gym, line_y, 1.0)
	_build_three_point_line(gym, line_y, -1.0)

	_make_floor_disc(gym, "CentreLogoOuter", Vector3(0.0, 0.026, 0.0), 1.58, materials.navy)
	_make_floor_disc(gym, "CentreLogoLake", Vector3(0.0, 0.039, 0.0), 1.32, materials.blue)
	_make_floor_disc(gym, "CentreLogoIce", Vector3(0.0, 0.052, 0.0), 0.98, materials.ice)
	_make_polyline(gym, [Vector3(-0.82, 0.068, 0.35), Vector3(-0.25, 0.068, -0.48), Vector3(0.08, 0.068, -0.04), Vector3(0.43, 0.068, -0.62), Vector3(0.88, 0.068, 0.35)], 0.1, materials.navy, false)
	_make_polyline(gym, [Vector3(-0.66, 0.072, 0.55), Vector3(0.0, 0.072, 0.18), Vector3(0.72, 0.072, 0.54)], 0.08, materials.blue, false)

	var west_wordmark := _make_label_3d(gym, "WestSidelineWordmark", "LAKESHORE RAPTORS", Vector3(-7.05, 0.035, 0.0), 62, 0.0046, ICE, false)
	west_wordmark.rotation_degrees = Vector3(-90.0, 0.0, -90.0)
	var east_wordmark := _make_label_3d(gym, "EastSidelineWordmark", "LAKESHORE RAPTORS", Vector3(7.05, 0.035, 0.0), 62, 0.0046, ICE, false)
	east_wordmark.rotation_degrees = Vector3(-90.0, 0.0, 90.0)


func _build_real_bleachers(gym: Node3D) -> void:
	for side in [-1.0, 1.0]:
		var side_name := "West" if side < 0.0 else "East"
		for row in range(6):
			var x := side * (7.28 + row * 0.18)
			var y := 0.24 + row * 0.29
			for section in [-1.0, 1.0]:
				var z := section * 5.2
				_make_box(gym, "%sBleacherSeat%d" % [side_name, row], Vector3(x, y, z), Vector3(0.52, 0.12, 8.55), materials.bleacher, false)
				_make_box(gym, "%sBleacherRiser%d" % [side_name, row], Vector3(x + side * 0.19, y - 0.14, z), Vector3(0.1, 0.3, 8.55), materials.charcoal, false)
			var step_material: Material = materials.concrete if row % 2 == 0 else materials.acoustic
			_make_box(gym, "%sAisleStep%d" % [side_name, row], Vector3(x, y - 0.03, 0.0), Vector3(0.56, 0.18, 1.45), step_material, false)
		for rail_z in [-1.0, 1.0]:
			_make_cylinder_between(gym, "%sAisleRail" % side_name, Vector3(side * 7.15, 0.35, rail_z), Vector3(side * 8.22, 2.02, rail_z), 0.035, materials.silver, false)
			_make_cylinder_between(gym, "%sAislePost" % side_name, Vector3(side * 7.3, 0.2, rail_z), Vector3(side * 7.3, 0.95, rail_z), 0.032, materials.silver, false)
			_make_cylinder_between(gym, "%sAislePost" % side_name, Vector3(side * 8.15, 1.55, rail_z), Vector3(side * 8.15, 2.25, rail_z), 0.032, materials.silver, false)


func _build_gym_windows(gym: Node3D) -> void:
	for side in [-1.0, 1.0]:
		var side_name := "West" if side < 0.0 else "East"
		for index in range(6):
			var z := -11.4 + index * 4.56
			_make_box(gym, "%sClerestoryGlass%d" % [side_name, index], Vector3(side * 8.35, 6.6, z), Vector3(0.08, 1.28, 2.75), materials.glass, false)
			_make_box(gym, "%sWindowTopFrame%d" % [side_name, index], Vector3(side * 8.3, 7.26, z), Vector3(0.12, 0.09, 2.86), materials.charcoal, false)
			_make_box(gym, "%sWindowBottomFrame%d" % [side_name, index], Vector3(side * 8.3, 5.94, z), Vector3(0.12, 0.09, 2.86), materials.charcoal, false)
			_make_box(gym, "%sWindowMullion%d" % [side_name, index], Vector3(side * 8.29, 6.6, z), Vector3(0.13, 1.28, 0.075), materials.charcoal, false)


func _build_gym_doors(gym: Node3D) -> void:
	for wall_side in [-1.0, 1.0]:
		var z := wall_side * 14.32
		var wall_name := "South" if wall_side < 0.0 else "North"
		for doorway_side in [-1.0, 1.0]:
			var doorway_x := doorway_side * 5.9
			for leaf in [-1.0, 1.0]:
				var x := doorway_x + leaf * 0.55
				_make_box(gym, "%sDoubleDoor" % wall_name, Vector3(x, 1.18, z), Vector3(1.02, 2.28, 0.12), materials.charcoal, false)
				_make_box(gym, "%sDoorVisionGlass" % wall_name, Vector3(x, 1.56, z - wall_side * 0.07), Vector3(0.23, 0.62, 0.025), materials.glass, false)
				_make_box(gym, "%sDoorPushBar" % wall_name, Vector3(x, 0.93, z - wall_side * 0.09), Vector3(0.68, 0.045, 0.04), materials.silver, false)
			_make_box(gym, "%sDoorHeader" % wall_name, Vector3(doorway_x, 2.4, z), Vector3(2.3, 0.12, 0.16), materials.silver, false)
			var exit_label := _make_label_3d(gym, "%sExitLabel" % wall_name, "EXIT", Vector3(doorway_x, 2.61, z - wall_side * 0.1), 28, 0.0026, Color("#65FF94"), true)
			exit_label.outline_size = 5


func _build_ceiling_structure(gym: Node3D) -> void:
	for z in [-11.0, -5.5, 0.0, 5.5, 11.0]:
		_make_cylinder_between(gym, "RoofTrussBottom", Vector3(-8.25, 7.25, z), Vector3(8.25, 7.25, z), 0.055, materials.charcoal, false)
		_make_cylinder_between(gym, "RoofTrussLeftPitch", Vector3(-8.25, 7.25, z), Vector3(0.0, 8.34, z), 0.055, materials.charcoal, false)
		_make_cylinder_between(gym, "RoofTrussRightPitch", Vector3(0.0, 8.34, z), Vector3(8.25, 7.25, z), 0.055, materials.charcoal, false)
		for segment in range(4):
			var x0 := -8.0 + segment * 4.0
			var x1 := x0 + 4.0
			var apex_y := 8.28 - absf((x0 + x1) * 0.5) * 0.13
			_make_cylinder_between(gym, "RoofTrussWeb", Vector3(x0, 7.25, z), Vector3(x1, apex_y, z), 0.034, materials.charcoal, false)
	for duct_x in [-4.85, 4.85]:
		_make_cylinder_between(gym, "SilverHVACDuct", Vector3(duct_x, 7.72, -13.6), Vector3(duct_x, 7.72, 13.6), 0.2, materials.silver, false)
	for z in [-9.0, -3.0, 3.0, 9.0]:
		for x in [-5.0, 0.0, 5.0]:
			_make_box(gym, "SuspendedLEDPanel", Vector3(x, 7.03, z), Vector3(2.15, 0.08, 0.48), materials.ice, false)
	for light_index in range(6):
		var fill := OmniLight3D.new()
		fill.name = "LEDGymFill%d" % light_index
		fill.position = Vector3(-3.8 if light_index % 2 == 0 else 3.8, 6.85, -9.0 + float(light_index / 2) * 9.0)
		fill.omni_range = 11.5
		fill.light_energy = 2.15
		fill.light_color = Color("#E8F5FF")
		fill.shadow_enabled = false
		gym.add_child(fill)


func _build_scoreboard_and_banners(gym: Node3D) -> void:
	_make_box(gym, "ScoreboardBlueFrame", Vector3(0.0, 5.8, 14.29), Vector3(4.6, 2.05, 0.16), materials.blue, false)
	_make_box(gym, "DigitalScoreboard", Vector3(0.0, 5.8, 14.18), Vector3(4.32, 1.78, 0.1), materials.dark, false)
	_make_label_3d(gym, "ScoreboardTitle", "LAKESHORE RAPTORS", Vector3(0.0, 6.43, 14.08), 44, 0.0032, ICE, true)
	_make_label_3d(gym, "ScoreboardReadout", "HOME  00     2:00     GUEST  00", Vector3(0.0, 5.83, 14.07), 42, 0.0028, Color("#FFB12B"), true)
	_make_label_3d(gym, "ScoreboardDetails", "PERIOD 1      FOULS 0      FOULS 0", Vector3(0.0, 5.34, 14.07), 28, 0.0024, Color("#F2F6F8"), true)
	_make_box(gym, "ShotClockHousing", Vector3(0.0, 4.55, 14.2), Vector3(1.05, 0.68, 0.12), materials.dark, false)
	_make_label_3d(gym, "ShotClockDigits", "24", Vector3(0.0, 4.56, 14.08), 58, 0.004, Color("#FF5038"), true)

	var banner_years := ["2018", "2020", "2022", "2024"]
	for index in range(banner_years.size()):
		var x := -6.5 + index * 4.35
		_make_box(gym, "ChampionshipBanner%d" % index, Vector3(x, 5.85, -14.28), Vector3(1.7, 2.25, 0.08), materials.navy if index % 2 == 0 else materials.blue, false)
		_make_label_3d(gym, "BannerText%d" % index, "RAPTORS\nCHAMPIONS\n%s" % banner_years[index], Vector3(x, 5.9, -14.18), 31, 0.0028, ICE, true)

	# Stylized but recognizable Canadian flag between the championship banners.
	_make_box(gym, "CanadaFlagWhite", Vector3(0.0, 7.23, -14.27), Vector3(2.55, 1.15, 0.06), materials.ice, false)
	_make_box(gym, "CanadaFlagLeftRed", Vector3(-1.02, 7.23, -14.2), Vector3(0.52, 1.15, 0.035), materials.red, false)
	_make_box(gym, "CanadaFlagRightRed", Vector3(1.02, 7.23, -14.2), Vector3(0.52, 1.15, 0.035), materials.red, false)
	_make_label_3d(gym, "CanadaMapleLeaf", "◆", Vector3(0.0, 7.2, -14.16), 72, 0.005, Color("#C62832"), true)


func _build_gym_furniture(gym: Node3D) -> void:
	_make_box(gym, "ScorersTable", Vector3(-6.78, 0.46, 0.0), Vector3(0.42, 0.86, 3.55), materials.navy, false)
	_make_box(gym, "ScorersTableTop", Vector3(-6.75, 0.91, 0.0), Vector3(0.62, 0.08, 3.7), materials.wood, false)
	var table_label := _make_label_3d(gym, "ScorersTableBrand", "LAKESHORE\nRAPTORS", Vector3(-6.54, 0.47, 0.0), 34, 0.003, ICE, true)
	table_label.rotation.y = PI * 0.5
	for bench_side in [-1.0, 1.0]:
		for seat_index in range(5):
			var z := bench_side * (4.4 + seat_index * 0.72)
			_make_box(gym, "TeamBenchSeat", Vector3(-6.72, 0.46, z), Vector3(0.42, 0.08, 0.62), materials.bleacher, false)
			_make_cylinder_between(gym, "TeamBenchLeg", Vector3(-6.82, 0.08, z - 0.22), Vector3(-6.82, 0.43, z - 0.22), 0.025, materials.silver, false)
			_make_cylinder_between(gym, "TeamBenchLeg", Vector3(-6.82, 0.08, z + 0.22), Vector3(-6.82, 0.43, z + 0.22), 0.025, materials.silver, false)
	# Ball rack and six spare balls beside the home bench.
	_make_cylinder_between(gym, "BallRackBottom", Vector3(6.72, 0.2, -8.2), Vector3(6.72, 0.2, -5.8), 0.035, materials.silver, false)
	_make_cylinder_between(gym, "BallRackTop", Vector3(6.72, 0.72, -8.2), Vector3(6.72, 0.72, -5.8), 0.035, materials.silver, false)
	for ball_index in range(6):
		var spare_ball := MeshInstance3D.new()
		spare_ball.name = "SpareBasketball%d" % ball_index
		var sphere := SphereMesh.new()
		sphere.radius = 0.115
		sphere.height = 0.23
		sphere.radial_segments = 16
		sphere.rings = 8
		spare_ball.mesh = sphere
		spare_ball.material_override = materials.orange
		spare_ball.position = Vector3(6.72, 0.36 if ball_index < 3 else 0.86, -7.85 + (ball_index % 3) * 0.7)
		gym.add_child(spare_ball)


func _build_lakeshore_wall_branding(gym: Node3D) -> void:
	_make_label_3d(gym, "NorthGymWordmark", "LAKESHORE RAPTORS", Vector3(0.0, 3.48, 14.12), 66, 0.0045, ICE, true)
	_make_label_3d(gym, "SouthGymSlogan", "BUILT BY THE LAKE, DRIVEN BY THE CLIMB", Vector3(0.0, 3.5, -14.12), 52, 0.0037, Color("#0A2342"), true)
	var mountain_points := [
		Vector3(-5.2, 2.74, 14.1), Vector3(-3.6, 3.75, 14.1), Vector3(-2.6, 3.04, 14.1),
		Vector3(-1.15, 4.15, 14.1), Vector3(0.0, 3.22, 14.1), Vector3(1.3, 4.02, 14.1),
		Vector3(2.45, 3.12, 14.1), Vector3(3.7, 3.82, 14.1), Vector3(5.2, 2.74, 14.1)
	]
	for index in range(mountain_points.size() - 1):
		_make_cylinder_between(gym, "MountainWallMural", mountain_points[index], mountain_points[index + 1], 0.045, materials.blue, false)


func _make_label_3d(parent: Node3D, label_name: String, text_value: String, local_position: Vector3, font_size: int, pixel_size: float, color: Color, billboard_enabled: bool) -> Label3D:
	var label := Label3D.new()
	label.name = label_name
	label.text = text_value
	label.font_size = font_size
	label.pixel_size = pixel_size
	label.outline_size = 9
	label.modulate = color
	label.position = local_position
	if billboard_enabled:
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	parent.add_child(label)
	return label


func _make_floor_disc(parent: Node3D, object_name: String, local_position: Vector3, radius: float, material: Material) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.name = object_name
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = 0.018
	mesh.radial_segments = 64
	instance.mesh = mesh
	instance.material_override = material
	instance.position = local_position
	parent.add_child(instance)
	return instance

func _build_key_lines(parent: Node3D, y: float, direction: float) -> void:
	var baseline := direction * 13.6
	var free_throw := direction * 8.8
	_make_polyline(parent, [
		Vector3(-2.45, y, baseline), Vector3(-2.45, y, free_throw),
		Vector3(2.45, y, free_throw), Vector3(2.45, y, baseline)
	], 0.05, materials.line, false)
	_make_polyline(parent, _circle_points(Vector3(0.0, y, free_throw), 1.8, 44), 0.05, materials.line, true)

func _build_three_point_line(parent: Node3D, y: float, direction: float) -> void:
	var points: Array = []
	var hoop_z := direction * 11.75
	points.append(Vector3(-6.65, y, direction * 13.6))
	points.append(Vector3(-6.65, y, direction * 10.25))
	var segments := 42
	for index in range(segments + 1):
		var angle := lerpf(PI, 0.0, float(index) / float(segments))
		points.append(Vector3(cos(angle) * 6.75, y, hoop_z - direction * sin(angle) * 6.75))
	points.append(Vector3(6.65, y, direction * 13.6))
	_make_polyline(parent, points, 0.05, materials.line, false)

func _build_hoop() -> void:
	var assembly := Node3D.new()
	assembly.name = "NorthBasket"
	add_child(assembly)

	_make_box(assembly, "SupportBase", Vector3(0.0, 0.35, 13.25), Vector3(1.1, 0.7, 0.85), materials.steel, true)
	_make_box(assembly, "SupportPole", Vector3(0.0, 2.15, 13.15), Vector3(0.18, 3.7, 0.18), materials.steel, true)
	_make_box(assembly, "SupportArm", Vector3(0.0, 3.65, 12.7), Vector3(0.16, 0.16, 1.05), materials.steel, true)
	_make_box(assembly, "Backboard", Vector3(0.0, 3.42, 12.38), Vector3(1.82, 1.05, 0.08), materials.ice, true)
	_make_box(assembly, "BoardSquareOuter", Vector3(0.0, 3.28, 12.325), Vector3(0.66, 0.5, 0.018), materials.orange, false)
	_make_box(assembly, "BoardSquareInner", Vector3(0.0, 3.28, 12.31), Vector3(0.52, 0.36, 0.02), materials.ice, false)

	var rim_radius := 0.235
	var rim_segments := 32
	for index in range(rim_segments):
		var a_angle := TAU * float(index) / float(rim_segments)
		var b_angle := TAU * float(index + 1) / float(rim_segments)
		var a := hoop_target + Vector3(cos(a_angle) * rim_radius, 0.0, sin(a_angle) * rim_radius)
		var b := hoop_target + Vector3(cos(b_angle) * rim_radius, 0.0, sin(b_angle) * rim_radius)
		_make_cylinder_between(assembly, "Rim%d" % index, a, b, 0.013, materials.orange, true)

	score_zone = Area3D.new()
	score_zone.name = "ScoreZone"
	score_zone.position = hoop_target + Vector3(0.0, -0.23, 0.0)
	score_zone.collision_layer = 0
	score_zone.collision_mask = 4
	score_zone.monitoring = true
	var zone_shape := CollisionShape3D.new()
	var zone_box := BoxShape3D.new()
	zone_box.size = Vector3(0.34, 0.2, 0.34)
	zone_shape.shape = zone_box
	score_zone.add_child(zone_shape)
	add_child(score_zone)
	score_zone.body_entered.connect(_on_score_zone_body_entered)

func _build_characters() -> void:
	player = _build_character("CareerPlayer", Vector3(0.0, 0.05, -4.2), materials.blue, materials.navy, true)
	defender = _build_character("AIDefender", Vector3(0.0, 0.05, 3.2), materials.steel, materials.navy, false)
	add_child(player)
	add_child(defender)

func _build_character(character_name: String, spawn_position: Vector3, jersey_material: Material, trim_material: Material, show_number: bool) -> CharacterBody3D:
	var character := CharacterBody3D.new()
	character.name = character_name
	character.position = spawn_position
	character.collision_layer = 2
	character.collision_mask = 1
	character.floor_snap_length = 0.22
	character.floor_max_angle = deg_to_rad(48.0)

	var collision := CollisionShape3D.new()
	var capsule_shape := CapsuleShape3D.new()
	capsule_shape.radius = 0.34
	capsule_shape.height = 1.9
	collision.shape = capsule_shape
	collision.position.y = 0.95
	character.add_child(collision)

	var model = PlayerModelScript.new()
	model.name = "AustinPlayerModel" if show_number else "DefenderPlayerModel"
	character.add_child(model)
	model.build(jersey_material, trim_material, show_number, int(profile.get("jersey_number", 7)))
	if show_number:
		player_model = model
		player_model.set_animation_profile(AnimationCatalog.get_profile(motion_style_index))
	else:
		defender_model = model
		defender_model.set_animation_profile(AnimationCatalog.get_profile(417))

	return character

func _build_ball() -> void:
	ball = BasketballPhysicsScript.new()
	ball.name = "Basketball"
	ball.mass = 0.62
	ball.configure_realistic_physics()
	ball.collision_layer = 4
	ball.collision_mask = 1
	ball.freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC
	ball.freeze = true

	var physics_material := PhysicsMaterial.new()
	physics_material.bounce = 0.78
	physics_material.friction = 0.6
	ball.physics_material_override = physics_material

	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = "PebbledLeatherBall"
	var sphere_mesh := SphereMesh.new()
	sphere_mesh.radius = 0.12
	sphere_mesh.height = 0.24
	sphere_mesh.radial_segments = 24
	sphere_mesh.rings = 12
	mesh_instance.mesh = sphere_mesh
	var ball_material := _make_material(Color("#C85818"), 0.78)
	ball_material.clearcoat_enabled = true
	ball_material.clearcoat_roughness = 0.86
	mesh_instance.material_override = ball_material
	ball.add_child(mesh_instance)
	_add_ball_seam(Vector3.ZERO)
	_add_ball_seam(Vector3(PI * 0.5, 0.0, 0.0))
	_add_ball_seam(Vector3(0.0, 0.0, PI * 0.5))

	var collision := CollisionShape3D.new()
	var sphere_shape := SphereShape3D.new()
	sphere_shape.radius = 0.12
	collision.shape = sphere_shape
	ball.add_child(collision)
	add_child(ball)

func _add_ball_seam(rotation: Vector3) -> void:
	var seam := MeshInstance3D.new()
	seam.name = "RecessedBallSeam"
	var torus := TorusMesh.new()
	torus.inner_radius = 0.116
	torus.outer_radius = 0.123
	torus.rings = 32
	torus.ring_segments = 6
	seam.mesh = torus
	seam.material_override = materials.dark
	seam.rotation = rotation
	ball.add_child(seam)

func _build_net() -> void:
	net_simulator = NetPhysicsScript.new()
	net_simulator.name = "ResponsiveBasketNet"
	add_child(net_simulator)
	net_simulator.build(hoop_target, ball)

func _build_camera() -> void:
	camera = Camera3D.new()
	camera.name = "PlayerLockCamera"
	camera.fov = 56.0
	camera.near = 0.08
	camera.far = 120.0
	camera.current = true
	add_child(camera)
	var attack_direction := (hoop_target - player.global_position)
	attack_direction.y = 0.0
	attack_direction = attack_direction.normalized()
	camera.global_position = player.global_position - attack_direction * 7.4 + Vector3.UP * 6.2
	camera.look_at(player.global_position + Vector3.UP * 1.05 + attack_direction * 2.6, Vector3.UP)

func _build_hud() -> void:
	hud = HUDScript.new()
	hud.name = "HUD"
	add_child(hud)
	hud.build(profile)
	_refresh_motion_style_hud()

func _process_player(delta: float) -> void:
	var keyboard_input := Vector2(
		float(Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT)) - float(Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT)),
		float(Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP)) - float(Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN))
	).limit_length(1.0)
	var move_input: Vector2 = hud.move_input
	if keyboard_input.length_squared() > move_input.length_squared():
		move_input = keyboard_input

	var camera_forward := -camera.global_transform.basis.z
	var camera_right := camera.global_transform.basis.x
	camera_forward.y = 0.0
	camera_right.y = 0.0
	camera_forward = camera_forward.normalized()
	camera_right = camera_right.normalized()
	var move_direction := (camera_forward * move_input.y + camera_right * move_input.x).limit_length(1.0)

	var sprint_input: bool = hud.sprint_held or Input.is_key_pressed(KEY_SHIFT)
	is_sprinting = sprint_input and move_direction.length_squared() > 0.1 and not charging_shot
	var base_speed := lerpf(3.5, 5.4, inverse_lerp(25.0, 99.0, 72.0))
	var move_speed := base_speed * (1.3 if is_sprinting else 1.0)
	if charging_shot:
		move_speed *= 0.18

	player.velocity.x = move_direction.x * move_speed
	player.velocity.z = move_direction.z * move_speed
	if player.is_on_floor():
		player.velocity.y = -0.6
	else:
		player.velocity.y -= 18.0 * delta
	player.move_and_slide()

	if move_direction.length_squared() > 0.02 and not charging_shot:
		player.look_at(player.global_position + move_direction, Vector3.UP)

	var bounded := player.global_position
	bounded.x = clampf(bounded.x, -6.85, 6.85)
	bounded.z = clampf(bounded.z, -13.1, 10.9)
	if bounded.y < -0.5:
		bounded.y = 0.05
	player.global_position = bounded

	var cross_key := Input.is_key_pressed(KEY_E)
	var cross_requested: bool = hud.consume_crossover() or (cross_key and not previous_cross_key)
	previous_cross_key = cross_key
	if cross_requested:
		_try_crossover()

	var reset_key := Input.is_key_pressed(KEY_R)
	var reset_requested: bool = hud.consume_reset() or (reset_key and not previous_reset_key)
	previous_reset_key = reset_key
	if reset_requested:
		_return_ball_to_player()

	_process_shot_input(delta)

func _process_motion_style_input() -> void:
	var motion_key := Input.is_key_pressed(KEY_Q)
	var keyboard_step := 1 if motion_key and not previous_motion_key else 0
	previous_motion_key = motion_key
	var requested_step: int = hud.consume_motion_style_step() + keyboard_step
	if hud.consume_motion_style_random():
		motion_style_index = AnimationCatalog.random_style(rng)
	elif requested_step != 0:
		motion_style_index = posmod(motion_style_index + requested_step, AnimationCatalog.TOTAL_STYLES)
	else:
		return
	profile.animation_style = motion_style_index
	CareerStore.save_profile(profile)
	if player_model != null:
		player_model.set_animation_profile(AnimationCatalog.get_profile(motion_style_index))
	_refresh_motion_style_hud()

func _refresh_motion_style_hud() -> void:
	if hud == null:
		return
	hud.set_motion_style(
		motion_style_index,
		AnimationCatalog.TOTAL_STYLES,
		AnimationCatalog.get_display_name(motion_style_index)
	)

func _try_crossover() -> void:
	if not ball_possessed or crossover_cooldown > 0.0 or charging_shot:
		return
	dribble_side *= -1
	dribble_phase = PI * 0.5
	var burst := lerpf(0.28, 0.5, inverse_lerp(25.0, 99.0, 68.0))
	player.global_position += player.global_transform.basis.x * dribble_side * burst
	var bounded := player.global_position
	bounded.x = clampf(bounded.x, -6.85, 6.85)
	bounded.z = clampf(bounded.z, -13.1, 10.9)
	player.global_position = bounded
	crossover_cooldown = 0.42
	if player_model != null:
		player_model.play_crossover(dribble_side)
	hud.show_feedback("CROSSOVER", Color("#6FD8FF"), 0.5)

func _process_shot_input(delta: float) -> void:
	var shoot_held: bool = hud.shoot_held or Input.is_key_pressed(KEY_SPACE)
	if shoot_held and not previous_shoot_held and ball_possessed and session_active:
		charging_shot = true
		shot_charge_time = 0.0

	if charging_shot:
		shot_charge_time += delta
		var meter := clampf(shot_charge_time / 1.05, 0.0, 1.0)
		var ideal := _get_ideal_release()
		hud.set_shot_meter(true, meter, ideal)
		var face_hoop := hoop_target - player.global_position
		face_hoop.y = 0.0
		if face_hoop.length_squared() > 0.01:
			player.look_at(player.global_position + face_hoop.normalized(), Vector3.UP)

	if not shoot_held and previous_shoot_held and charging_shot:
		_release_shot()
	elif charging_shot and shot_charge_time > 1.35:
		_release_shot()

	previous_shoot_held = shoot_held

func _get_ideal_release() -> float:
	var distance := player.global_position.distance_to(hoop_target)
	return lerpf(0.62, 0.79, clampf(inverse_lerp(1.5, 9.5, distance), 0.0, 1.0))

func _release_shot() -> void:
	if not charging_shot or not ball_possessed:
		charging_shot = false
		hud.set_shot_meter(false, 0.0, 0.72)
		return

	charging_shot = false
	var meter := clampf(shot_charge_time / 1.05, 0.0, 1.0)
	var ideal := _get_ideal_release()
	var timing_error := absf(meter - ideal)
	var contest := _get_contest(player.global_position + Vector3.UP * 1.7)
	var rating_help := inverse_lerp(25.0, 99.0, 66.0) * 0.08
	var effective_error := maxf(0.0, timing_error - rating_help) + contest * 0.16
	var green_window := lerpf(0.035, 0.075, inverse_lerp(25.0, 99.0, 66.0))
	var green := timing_error <= green_window and contest < 0.55

	var feedback := "GOOD"
	var feedback_color := Color("#6FD8FF")
	if green:
		feedback = "GREEN"
		feedback_color = Color("#35FF6C")
	elif meter < ideal - 0.09:
		feedback = "EARLY"
		feedback_color = Color("#FFAD2E")
	elif meter > ideal + 0.09:
		feedback = "LATE"
		feedback_color = Color("#FF6A33")

	var horizontal_distance := Vector2(player.global_position.x, player.global_position.z).distance_to(Vector2(hoop_target.x, hoop_target.z))
	var shot_value := 3 if horizontal_distance >= 6.75 else 2
	var miss_radius := 0.0 if green else lerpf(0.04, 0.72, clampf(effective_error * 2.4, 0.0, 1.0))
	var random_error := _random_point_in_circle(miss_radius)
	var target := hoop_target + Vector3(random_error.x, 0.08, random_error.y)
	var flight_time := lerpf(0.62, 0.96, clampf(inverse_lerp(1.5, 10.5, horizontal_distance), 0.0, 1.0))

	_register_shot_attempt(shot_value, feedback, feedback_color, int(round(contest * 100.0)))
	if player_model != null:
		player_model.play_shot_release()
	_launch_ball(target, flight_time, shot_value)
	hud.set_shot_meter(false, 0.0, ideal)

func _launch_ball(target: Vector3, flight_time: float, shot_value: int) -> void:
	var release_position := player.to_global(Vector3(0.32 * dribble_side, 1.72, -0.22))
	ball.global_position = release_position
	last_shot_value = shot_value
	ball_possessed = false
	ball_released_at = _now()
	shot_token += 1
	ball.freeze = false
	ball.sleeping = false
	var safe_time := maxf(0.42, flight_time)
	var horizontal_direction := target - release_position
	horizontal_direction.y = 0.0
	horizontal_direction = horizontal_direction.normalized()
	var backspin_axis := horizontal_direction.cross(Vector3.UP)
	var distance_weight := clampf(inverse_lerp(1.5, 10.5, horizontal_distance_to_hoop()), 0.0, 1.0)
	var backspin := backspin_axis * lerpf(15.5, 19.5, distance_weight)
	ball.angular_velocity = backspin
	ball.linear_velocity = BasketballPhysicsScript.solve_launch_velocity(release_position, target, safe_time, backspin, ball.mass)

func horizontal_distance_to_hoop() -> float:
	return Vector2(player.global_position.x, player.global_position.z).distance_to(Vector2(hoop_target.x, hoop_target.z))

func _process_possessed_ball(delta: float) -> void:
	if not ball_possessed:
		return
	if charging_shot:
		var gather_progress := clampf(shot_charge_time / 1.05, 0.0, 1.0)
		ball.global_position = player.to_global(Vector3(0.0, lerpf(1.32, 1.84, gather_progress), -0.4))
		ball.rotation = Vector3(dribble_phase * 0.8, dribble_phase * 0.55, 0.0)
		return
	dribble_phase += delta * (11.5 if is_sprinting else 8.5)
	var bounce := absf(sin(dribble_phase))
	var hand_position: Vector3 = player_model.get_hand_position(dribble_side) if player_model != null else player.to_global(Vector3(0.48 * dribble_side, 1.08, -0.18))
	var hand_forward := -player.global_transform.basis.z
	hand_forward.y = 0.0
	hand_forward = hand_forward.normalized()
	var dribble_position := hand_position + hand_forward * 0.025
	dribble_position.y = lerpf(0.16, maxf(0.92, hand_position.y - 0.08), bounce)
	ball.global_position = dribble_position
	ball.rotation = Vector3(dribble_phase * 1.55, dribble_phase * 0.96, 0.0)

func _process_defender(delta: float, now: float) -> void:
	if not session_active:
		defender.velocity = Vector3.ZERO
		return
	if now >= defender_next_read:
		defender_lateral_noise = Vector3(rng.randf_range(-0.22, 0.22), 0.0, rng.randf_range(-0.22, 0.22))
		defender_next_read = now + rng.randf_range(0.22, 0.48)

	var toward_hoop := hoop_target - player.global_position
	toward_hoop.y = 0.0
	var ideal := player.global_position + toward_hoop.normalized() * 1.25 + defender_lateral_noise
	ideal.z = minf(ideal.z, 10.7)
	var delta_position := ideal - defender.global_position
	delta_position.y = 0.0
	var speed := 4.25 if is_sprinting else 3.65
	var movement := delta_position.limit_length(1.0) * speed
	defender.velocity.x = movement.x
	defender.velocity.z = movement.z
	if defender.is_on_floor():
		defender.velocity.y = -0.6
	else:
		defender.velocity.y -= 18.0 * delta
	defender.move_and_slide()

	var face_player := player.global_position - defender.global_position
	face_player.y = 0.0
	if face_player.length_squared() > 0.01:
		defender.look_at(defender.global_position + face_player.normalized(), Vector3.UP)
	var bounded := defender.global_position
	bounded.x = clampf(bounded.x, -6.8, 6.8)
	bounded.z = clampf(bounded.z, -12.8, 10.9)
	if bounded.y < -0.5:
		bounded.y = 0.05
	defender.global_position = bounded

func _update_character_animations(delta: float) -> void:
	if player_model != null:
		var player_speed := Vector2(player.velocity.x, player.velocity.z).length()
		var shot_progress := clampf(shot_charge_time / 1.05, 0.0, 1.0) if charging_shot else 0.0
		player_model.update_player_animation(
			delta,
			player_speed / 7.1,
			is_sprinting,
			ball_possessed,
			charging_shot,
			shot_progress,
			dribble_side
		)
	if defender_model != null:
		var defender_speed := Vector2(defender.velocity.x, defender.velocity.z).length()
		defender_model.update_defender_animation(delta, defender_speed / 4.4)

func _get_contest(release_point: Vector3) -> float:
	var defender_hand := defender.global_position + Vector3.UP * 1.55
	var distance := defender_hand.distance_to(release_point)
	var proximity := 1.0 - clampf(inverse_lerp(0.55, 2.6, distance), 0.0, 1.0)
	var to_release := (release_point - (defender.global_position + Vector3.UP * 1.2)).normalized()
	var defender_forward := -defender.global_transform.basis.z
	var facing := clampf(inverse_lerp(-0.1, 0.8, defender_forward.dot(to_release)), 0.0, 1.0)
	return clampf(proximity * lerpf(0.65, 1.0, facing), 0.0, 1.0)

func _process_camera(delta: float) -> void:
	var attack_direction := hoop_target - player.global_position
	attack_direction.y = 0.0
	if attack_direction.length_squared() < 0.01:
		attack_direction = Vector3.FORWARD
	else:
		attack_direction = attack_direction.normalized()
	var desired_position := player.global_position - attack_direction * 7.4 + Vector3.UP * 6.2
	var follow_weight := 1.0 - exp(-delta * 7.0)
	camera.global_position = camera.global_position.lerp(desired_position, follow_weight)
	var look_target := player.global_position + Vector3.UP * 1.05 + attack_direction * 2.6
	camera.look_at(look_target, Vector3.UP)

func _process_loose_ball(delta: float, now: float) -> void:
	if ball_return_delay >= 0.0:
		ball_return_delay -= delta
		if ball_return_delay <= 0.0:
			_return_ball_to_player()
		return
	if ball_possessed:
		return

	var ball_position := ball.global_position
	var out_of_bounds := absf(ball_position.x) > 8.2 or absf(ball_position.z) > 15.4 or ball_position.y < -1.5
	if out_of_bounds:
		_return_ball_to_player()
		return
	var distance := (player.global_position + Vector3.UP * 0.4).distance_to(ball_position)
	if now - ball_released_at > 0.55 and distance < 1.15 and ball.linear_velocity.length() < 7.0:
		_return_ball_to_player()
		return
	if now - last_attempt_at > 4.8:
		_return_ball_to_player()

func _on_score_zone_body_entered(body: Node3D) -> void:
	if body != ball or not session_active or ball_possessed:
		return
	if ball.linear_velocity.y >= -0.15 or processed_score_token == shot_token:
		return
	processed_score_token = shot_token
	session_score += last_shot_value
	session_makes += 1
	profile.field_goals_made = int(profile.get("field_goals_made", 0)) + 1
	profile.career_points = int(profile.get("career_points", 0)) + last_shot_value
	profile.xp = int(profile.get("xp", 0)) + (30 if last_shot_value == 3 else 20)
	CareerStore.save_profile(profile)
	hud.set_score(session_score)
	hud.set_attempt_stats(session_makes, session_attempts)
	hud.refresh_profile(profile)
	hud.show_feedback("+%d  BUCKET" % last_shot_value, Color("#35FF75"), 1.1)
	ball_return_delay = 1.05

func _register_shot_attempt(_shot_value: int, timing: String, timing_color: Color, contest_percent: int) -> void:
	if not session_active:
		return
	session_attempts += 1
	profile.field_goals_attempted = int(profile.get("field_goals_attempted", 0)) + 1
	last_attempt_at = _now()
	var contest_label := "OPEN" if contest_percent <= 4 else "%d%% COVERED" % contest_percent
	hud.set_attempt_stats(session_makes, session_attempts)
	hud.show_feedback("%s  •  %s" % [timing, contest_label], timing_color, 1.15)
	CareerStore.save_profile(profile)

func _start_session(first_session: bool) -> void:
	session_active = true
	session_score = 0
	session_makes = 0
	session_attempts = 0
	time_remaining = SESSION_LENGTH
	last_attempt_at = -100.0
	ball_return_delay = -1.0
	hud.set_score(0)
	hud.set_clock(time_remaining)
	hud.set_attempt_stats(0, 0)
	hud.refresh_profile(profile)
	_return_ball_to_player()
	if not first_session:
		hud.show_feedback("NEW OPEN-GYM SESSION", ICE, 1.2)

func _end_session() -> void:
	if not session_active:
		return
	session_active = false
	var before_xp := int(profile.get("xp", 0))
	profile.sessions_played = int(profile.get("sessions_played", 0)) + 1
	profile.xp = before_xp + maxi(10, session_score * 2)
	CareerStore.save_profile(profile)
	hud.refresh_profile(profile)
	hud.show_session_complete(session_score, int(profile.xp) - before_xp)
	session_ended_at = _now()

func _return_ball_to_player() -> void:
	if ball == null or player == null:
		return
	ball_return_delay = -1.0
	ball_possessed = true
	ball.freeze = true
	ball.linear_velocity = Vector3.ZERO
	ball.angular_velocity = Vector3.ZERO
	dribble_phase = PI * 0.5
	dribble_side = 1
	ball.global_position = player.to_global(Vector3(0.48, 1.05, -0.18))
	last_attempt_at = -100.0
	charging_shot = false
	shot_charge_time = 0.0
	if hud != null:
		hud.set_shot_meter(false, 0.0, 0.72)

func _make_material(color: Color, roughness: float, metallic := 0.0, unshaded := false) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = roughness
	material.metallic = metallic
	if unshaded:
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	return material


func _make_court_material() -> ShaderMaterial:
	var shader := Shader.new()
	shader.code = """
shader_type spatial;
render_mode diffuse_burley, specular_schlick_ggx;

uniform vec3 maple_light : source_color = vec3(0.76, 0.48, 0.25);
uniform vec3 maple_dark : source_color = vec3(0.48, 0.25, 0.12);
uniform vec3 seam_color : source_color = vec3(0.22, 0.12, 0.07);

float hash21(vec2 p) {
	p = fract(p * vec2(123.34, 345.45));
	p += dot(p, p + 34.345);
	return fract(p.x * p.y);
}

void fragment() {
	vec2 plank_uv = UV * vec2(46.0, 18.0);
	float plank_id = floor(plank_uv.x) + floor(plank_uv.y) * 47.0;
	float variation = hash21(vec2(plank_id, floor(plank_uv.y)));
	float long_grain = sin(UV.y * 780.0 + variation * 19.0) * 0.5 + 0.5;
	long_grain += sin(UV.y * 1710.0 + UV.x * 21.0) * 0.18;
	float board_seam = smoothstep(0.465, 0.5, abs(fract(plank_uv.x) - 0.5));
	float end_seam = smoothstep(0.478, 0.5, abs(fract(plank_uv.y + variation * 0.5) - 0.5));
	vec3 wood = mix(maple_dark, maple_light, 0.52 + variation * 0.24 + long_grain * 0.1);
	wood = mix(wood, seam_color, max(board_seam, end_seam) * 0.74);
	ALBEDO = wood;
	ROUGHNESS = 0.27 + variation * 0.08;
	SPECULAR = 0.58;
	METALLIC = 0.0;
}
"""
	var material := ShaderMaterial.new()
	material.shader = shader
	return material

func _make_box(parent: Node3D, object_name: String, position: Vector3, size: Vector3, material: Material, collision_enabled: bool) -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = object_name
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh_instance.mesh = mesh
	mesh_instance.material_override = material
	mesh_instance.position = position
	parent.add_child(mesh_instance)
	if collision_enabled:
		var body := StaticBody3D.new()
		body.name = object_name + "Body"
		body.position = position
		body.collision_layer = 1
		body.collision_mask = 6
		body.physics_material_override = _surface_physics_material(object_name)
		var collision := CollisionShape3D.new()
		var shape := BoxShape3D.new()
		shape.size = size
		collision.shape = shape
		body.add_child(collision)
		parent.add_child(body)
	return mesh_instance

func _make_cylinder_between(parent: Node3D, object_name: String, start: Vector3, finish: Vector3, radius: float, material: Material, collision_enabled: bool) -> MeshInstance3D:
	var direction := finish - start
	var length := direction.length()
	var rotation := Quaternion(Vector3.UP, direction.normalized())
	var midpoint := (start + finish) * 0.5
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = object_name
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = length
	mesh.radial_segments = 8
	mesh_instance.mesh = mesh
	mesh_instance.material_override = material
	mesh_instance.position = midpoint
	mesh_instance.quaternion = rotation
	parent.add_child(mesh_instance)
	if collision_enabled:
		var body := StaticBody3D.new()
		body.name = object_name + "Body"
		body.position = midpoint
		body.quaternion = rotation
		body.collision_layer = 1
		body.collision_mask = 4
		body.physics_material_override = _surface_physics_material(object_name)
		var collision := CollisionShape3D.new()
		var shape := CylinderShape3D.new()
		shape.radius = radius
		shape.height = length
		collision.shape = shape
		body.add_child(collision)
		parent.add_child(body)
	return mesh_instance

func _surface_physics_material(object_name: String) -> PhysicsMaterial:
	var physics_material := PhysicsMaterial.new()
	if "Rim" in object_name:
		physics_material.bounce = 0.62
		physics_material.friction = 0.34
	elif "Backboard" in object_name or "Board" in object_name:
		physics_material.bounce = 0.67
		physics_material.friction = 0.22
	elif "Court" in object_name:
		physics_material.bounce = 0.79
		physics_material.friction = 0.66
	else:
		physics_material.bounce = 0.24
		physics_material.friction = 0.58
	return physics_material

func _make_polyline(parent: Node3D, points: Array, width: float, material: Material, closed: bool) -> void:
	if points.size() < 2:
		return
	for index in range(points.size() - 1):
		_make_floor_line(parent, points[index], points[index + 1], width, material)
	if closed:
		_make_floor_line(parent, points[points.size() - 1], points[0], width, material)

func _make_floor_line(parent: Node3D, start: Vector3, finish: Vector3, width: float, material: Material) -> void:
	var delta := finish - start
	var length := Vector2(delta.x, delta.z).length()
	if length <= 0.001:
		return
	var line := _make_box(parent, "CourtLine", (start + finish) * 0.5, Vector3(length, 0.014, width), material, false)
	line.rotation.y = -atan2(delta.z, delta.x)

func _circle_points(center: Vector3, radius: float, segments: int) -> Array:
	var points: Array = []
	for index in range(segments):
		var angle := TAU * float(index) / float(segments)
		points.append(center + Vector3(cos(angle) * radius, 0.0, sin(angle) * radius))
	return points

func _random_point_in_circle(radius: float) -> Vector2:
	if radius <= 0.0:
		return Vector2.ZERO
	var angle := rng.randf_range(0.0, TAU)
	var distance := sqrt(rng.randf()) * radius
	return Vector2(cos(angle), sin(angle)) * distance

func _now() -> float:
	return Time.get_ticks_msec() / 1000.0
