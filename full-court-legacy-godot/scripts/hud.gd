extends CanvasLayer

const VirtualJoystickScript = preload("res://scripts/virtual_joystick.gd")

const NAVY := Color("#071B3E")
const NAVY_ALPHA := Color(0.025, 0.08, 0.17, 0.92)
const LAKE_BLUE := Color("#0D82CA")
const ICE := Color("#E4F5FF")
const WHITE := Color("#FFFFFF")

var move_input := Vector2.ZERO
var sprint_held := false
var shoot_held := false
var _crossover_requested := false
var _reset_requested := false

var _score_label: Label
var _clock_label: Label
var _profile_label: Label
var _stats_label: Label
var _feedback_label: Label
var _meter_panel: Control
var _meter_fill: Control
var _meter_marker: Control
var _feedback_until := 0.0

func _process(_delta: float) -> void:
	if _feedback_label != null and _feedback_label.visible and Time.get_ticks_msec() / 1000.0 >= _feedback_until:
		_feedback_label.hide()

func build(profile: Dictionary) -> void:
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS

	var root := Control.new()
	root.name = "PlayerLockMobileHUD"
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(root)

	var top_bar := _make_panel(root, "TopBar", NAVY_ALPHA, Vector2(0, 0), Vector2(1920, 92), 0)
	_score_label = _make_label(top_bar, "OPEN GYM  0", Vector2(34, 4), Vector2(500, 82), 38, HORIZONTAL_ALIGNMENT_LEFT, ICE)
	_clock_label = _make_label(top_bar, "2:00", Vector2(820, 4), Vector2(280, 82), 44, HORIZONTAL_ALIGNMENT_CENTER, WHITE)
	_profile_label = _make_label(top_bar, _format_profile(profile), Vector2(1160, 4), Vector2(726, 82), 27, HORIZONTAL_ALIGNMENT_RIGHT, ICE)

	_stats_label = _make_label(root, "0/0 FG", Vector2(1425, 104), Vector2(440, 54), 27, HORIZONTAL_ALIGNMENT_RIGHT, WHITE)
	var hint := _make_label(root, "PLAYER LOCK  •  CREATE SPACE  •  HOLD & RELEASE TO SHOOT", Vector2(585, 1000), Vector2(750, 44), 19, HORIZONTAL_ALIGNMENT_CENTER, Color(0.82, 0.91, 0.98, 0.75))
	hint.mouse_filter = Control.MOUSE_FILTER_IGNORE

	_feedback_label = _make_label(root, "GREEN", Vector2(550, 218), Vector2(820, 96), 58, HORIZONTAL_ALIGNMENT_CENTER, WHITE)
	_feedback_label.add_theme_constant_override("outline_size", 10)
	_feedback_label.add_theme_color_override("font_outline_color", Color(0.01, 0.02, 0.05, 0.86))
	_feedback_label.hide()

	_meter_panel = _make_panel(root, "ShotMeter", Color(0.02, 0.04, 0.08, 0.9), Vector2(755, 900), Vector2(410, 52), 16)
	_meter_fill = _make_panel(_meter_panel, "MeterFill", LAKE_BLUE, Vector2(12, 12), Vector2(1, 28), 8)
	_meter_marker = _make_panel(_meter_panel, "GreenWindow", Color("#36FF6C"), Vector2(12, 5), Vector2(12, 42), 5)
	_meter_panel.hide()

	var team_tag := _make_panel(root, "TeamTag", Color(0.025, 0.08, 0.17, 0.74), Vector2(34, 112), Vector2(330, 48), 12)
	_make_label(team_tag, "LAKESHORE RAPTORS", Vector2.ZERO, team_tag.size, 22, HORIZONTAL_ALIGNMENT_CENTER, ICE)

	var joystick := VirtualJoystickScript.new()
	joystick.name = "MoveJoystick"
	joystick.position = Vector2(52, 744)
	joystick.size = Vector2(286, 286)
	root.add_child(joystick)
	var stick_back := _style(Color(0.03, 0.11, 0.22, 0.6), 143)
	joystick.add_theme_stylebox_override("panel", stick_back)
	var backing := Panel.new()
	backing.position = Vector2.ZERO
	backing.size = joystick.size
	backing.mouse_filter = Control.MOUSE_FILTER_IGNORE
	backing.add_theme_stylebox_override("panel", stick_back)
	joystick.add_child(backing)
	joystick.move_child(backing, 0)
	var handle := Panel.new()
	handle.size = Vector2(118, 118)
	handle.mouse_filter = Control.MOUSE_FILTER_IGNORE
	handle.add_theme_stylebox_override("panel", _style(Color(0.08, 0.58, 0.9, 0.94), 59))
	joystick.add_child(handle)
	joystick.set_handle(handle)
	joystick.value_changed.connect(_on_joystick_changed)
	_make_label(root, "MOVE", Vector2(135, 1022), Vector2(120, 34), 18, HORIZONTAL_ALIGNMENT_CENTER, Color(0.8, 0.93, 1.0, 0.8))

	var shoot_button := _make_button(root, "SHOOT", Vector2(1650, 778), Vector2(205, 205), LAKE_BLUE, 102, 31)
	shoot_button.button_down.connect(_on_shoot_down)
	shoot_button.button_up.connect(_on_shoot_up)

	var sprint_button := _make_button(root, "SPRINT", Vector2(1370, 854), Vector2(162, 162), NAVY, 81, 26)
	sprint_button.button_down.connect(_on_sprint_down)
	sprint_button.button_up.connect(_on_sprint_up)

	var cross_button := _make_button(root, "CROSS", Vector2(1418, 658), Vector2(154, 154), Color("#294D70"), 77, 25)
	cross_button.pressed.connect(_on_cross_pressed)

	var reset_button := _make_button(root, "RESET BALL", Vector2(32, 176), Vector2(186, 54), Color(0.08, 0.18, 0.3, 0.86), 16, 18)
	reset_button.pressed.connect(_on_reset_pressed)

func consume_crossover() -> bool:
	var requested := _crossover_requested
	_crossover_requested = false
	return requested

func consume_reset() -> bool:
	var requested := _reset_requested
	_reset_requested = false
	return requested

func set_score(score: int) -> void:
	if _score_label != null:
		_score_label.text = "OPEN GYM  %d" % score

func set_clock(seconds: float) -> void:
	if _clock_label == null:
		return
	var rounded := maxi(0, int(ceil(seconds)))
	_clock_label.text = "%d:%02d" % [rounded / 60, rounded % 60]
	_clock_label.add_theme_color_override("font_color", Color("#FF5B43") if rounded <= 10 else WHITE)

func set_attempt_stats(made: int, attempted: int) -> void:
	if _stats_label == null:
		return
	var percentage := 0.0 if attempted == 0 else float(made) / float(attempted) * 100.0
	_stats_label.text = "%d/%d FG   %.0f%%" % [made, attempted, percentage]

func refresh_profile(profile: Dictionary) -> void:
	if _profile_label != null:
		_profile_label.text = _format_profile(profile)

func set_shot_meter(visible: bool, amount: float, ideal: float) -> void:
	if _meter_panel == null:
		return
	_meter_panel.visible = visible
	_meter_fill.size.x = maxf(1.0, clampf(amount, 0.0, 1.0) * 386.0)
	_meter_marker.position.x = 12.0 + clampf(ideal, 0.0, 1.0) * 386.0 - 6.0

func show_feedback(message: String, color: Color, duration := 1.2) -> void:
	if _feedback_label == null:
		return
	_feedback_label.text = message
	_feedback_label.add_theme_color_override("font_color", color)
	_feedback_label.show()
	_feedback_until = Time.get_ticks_msec() / 1000.0 + duration

func show_session_complete(score: int, xp_earned: int) -> void:
	show_feedback("SESSION COMPLETE  •  %d PTS  •  +%d XP" % [score, xp_earned], Color("#35FFB3"), 5.0)

func _format_profile(profile: Dictionary) -> String:
	return "#%d  %s  •  %s  •  %d OVR  •  %d XP" % [
		int(profile.get("jersey_number", 7)),
		str(profile.get("player_name", "ROOKIE")),
		str(profile.get("position", "PG")),
		int(profile.get("overall", 60)),
		int(profile.get("xp", 0))
	]

func _on_joystick_changed(value: Vector2) -> void:
	move_input = value

func _on_shoot_down() -> void:
	shoot_held = true

func _on_shoot_up() -> void:
	shoot_held = false

func _on_sprint_down() -> void:
	sprint_held = true

func _on_sprint_up() -> void:
	sprint_held = false

func _on_cross_pressed() -> void:
	_crossover_requested = true

func _on_reset_pressed() -> void:
	_reset_requested = true

func _make_label(parent: Control, content: String, position: Vector2, size: Vector2, font_size: int, horizontal: HorizontalAlignment, color: Color) -> Label:
	var label := Label.new()
	label.text = content
	label.position = position
	label.size = size
	label.horizontal_alignment = horizontal
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	parent.add_child(label)
	return label

func _make_panel(parent: Control, panel_name: String, color: Color, position: Vector2, size: Vector2, radius: int) -> Panel:
	var panel := Panel.new()
	panel.name = panel_name
	panel.position = position
	panel.size = size
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_theme_stylebox_override("panel", _style(color, radius))
	parent.add_child(panel)
	return panel

func _make_button(parent: Control, label: String, position: Vector2, size: Vector2, color: Color, radius: int, font_size: int) -> Button:
	var button := Button.new()
	button.text = label
	button.position = position
	button.size = size
	button.focus_mode = Control.FOCUS_NONE
	button.keep_pressed_outside = true
	button.add_theme_font_size_override("font_size", font_size)
	button.add_theme_color_override("font_color", WHITE)
	button.add_theme_color_override("font_hover_color", WHITE)
	button.add_theme_color_override("font_pressed_color", WHITE)
	button.add_theme_stylebox_override("normal", _style(color, radius))
	button.add_theme_stylebox_override("hover", _style(color.lightened(0.08), radius))
	button.add_theme_stylebox_override("pressed", _style(color.lightened(0.22), radius))
	button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	parent.add_child(button)
	return button

func _style(color: Color, radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.75, 0.92, 1.0, 0.16)
	return style
