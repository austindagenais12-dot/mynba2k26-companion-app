extends Control

const BG := Color("091423")
const SURFACE := Color("112236")
const SURFACE_RAISED := Color("172d43")
const SURFACE_SOFT := Color("1d3850")
const TEXT := Color("f7fbff")
const MUTED := Color("9cb1c2")
const TEAL := Color("46c2a6")
const TEAL_DARK := Color("247f71")
const GOLD := Color("ffb65b")
const ROSE := Color("ef7184")
const BLUE := Color("5ea9dd")
const LINE := Color("29465e")
const CAREERS_PER_PAGE := 14

var simulation: LifeSimulation
var current_page := "life"
var page_host: Control
var year_label: Label
var nav_buttons: Dictionary = {}
var overlay: ColorRect
var toast_panel: PanelContainer
var toast_label: Label
var toast_serial := 0
var career_query := ""
var career_sector := "All sectors"
var career_eligible_only := false
var career_page := 0


func _ready() -> void:
	simulation = LifeSimulation.new()
	if not simulation.load_game():
		simulation.new_life()
	build_shell()
	show_page("life")
	if not simulation.pending_event.is_empty():
		call_deferred("show_event_dialog", simulation.pending_event)


func build_shell() -> void:
	var background := ColorRect.new()
	background.color = BG
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)

	var glow_top := ColorRect.new()
	glow_top.color = Color(0.11, 0.34, 0.43, 0.16)
	glow_top.position = Vector2(0, 0)
	glow_top.size = Vector2(720, 230)
	glow_top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(glow_top)

	var safe_margin := MarginContainer.new()
	safe_margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	set_margins(safe_margin, 20, 18, 20, 18)
	add_child(safe_margin)

	var shell := VBoxContainer.new()
	shell.add_theme_constant_override("separation", 14)
	safe_margin.add_child(shell)

	shell.add_child(build_top_bar())

	page_host = Control.new()
	page_host.size_flags_vertical = Control.SIZE_EXPAND_FILL
	page_host.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	shell.add_child(page_host)

	shell.add_child(build_bottom_nav())
	build_toast()


func build_top_bar() -> Control:
	var bar := HBoxContainer.new()
	bar.custom_minimum_size.y = 68
	bar.add_theme_constant_override("separation", 12)

	var title_box := VBoxContainer.new()
	title_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_box.add_theme_constant_override("separation", -2)
	bar.add_child(title_box)
	var title := make_label("SECOND DRAFT", 27, TEXT, 900)
	title_box.add_child(title)
	var subtitle := make_label("ONE LIFE. YOUR CHOICES.", 12, TEAL, 700)
	title_box.add_child(subtitle)

	var year_chip := PanelContainer.new()
	year_chip.add_theme_stylebox_override("panel", make_style(Color("17354a"), 18, 1, Color("2c6271")))
	year_chip.custom_minimum_size = Vector2(110, 52)
	bar.add_child(year_chip)
	var year_margin := MarginContainer.new()
	set_margins(year_margin, 14, 7, 14, 7)
	year_chip.add_child(year_margin)
	year_label = make_label("", 17, TEXT, 700)
	year_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	year_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	year_margin.add_child(year_label)

	var new_button := make_button("NEW", "secondary", 14)
	new_button.custom_minimum_size = Vector2(84, 52)
	new_button.pressed.connect(show_new_life_dialog)
	bar.add_child(new_button)
	return bar


func build_bottom_nav() -> Control:
	var panel := PanelContainer.new()
	panel.custom_minimum_size.y = 88
	panel.add_theme_stylebox_override("panel", make_style(Color("102438"), 24, 1, LINE))
	var margin := MarginContainer.new()
	set_margins(margin, 8, 8, 8, 8)
	panel.add_child(margin)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 4)
	margin.add_child(row)
	var pages := [
		["life", "LIFE"],
		["people", "PEOPLE"],
		["work", "WORK"],
		["activities", "DO"],
		["assets", "ASSETS"]
	]
	for page in pages:
		var button := make_button(str(page[1]), "nav", 12)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.pressed.connect(show_page.bind(str(page[0])))
		row.add_child(button)
		nav_buttons[str(page[0])] = button
	return panel


func build_toast() -> void:
	toast_panel = PanelContainer.new()
	toast_panel.add_theme_stylebox_override("panel", make_style(Color("24495b"), 18, 1, TEAL))
	toast_panel.set_anchors_preset(Control.PRESET_CENTER_TOP)
	toast_panel.position = Vector2(-250, 92)
	toast_panel.size = Vector2(500, 64)
	toast_panel.z_index = 50
	toast_panel.visible = false
	add_child(toast_panel)
	var margin := MarginContainer.new()
	set_margins(margin, 18, 12, 18, 12)
	toast_panel.add_child(margin)
	toast_label = make_label("", 15, TEXT, 700)
	toast_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	toast_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	toast_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	margin.add_child(toast_label)


func show_page(page_name: String) -> void:
	current_page = page_name
	clear_children(page_host)
	update_top_bar()
	update_nav()
	match page_name:
		"people":
			build_people_page()
		"work":
			build_work_page()
		"activities":
			build_activities_page()
		"assets":
			build_assets_page()
		_:
			build_life_page()


func update_top_bar() -> void:
	if year_label == null:
		return
	year_label.text = "%d\nAGE %d" % [int(simulation.data.get("year", 2026)), int(simulation.data.get("age", 0))]


func update_nav() -> void:
	for page_name in nav_buttons:
		var button: Button = nav_buttons[page_name]
		if page_name == current_page:
			button.add_theme_color_override("font_color", BG)
			button.add_theme_stylebox_override("normal", make_style(TEAL, 16))
			button.add_theme_stylebox_override("hover", make_style(TEAL, 16))
		else:
			button.add_theme_color_override("font_color", MUTED)
			button.add_theme_stylebox_override("normal", make_style(Color(0, 0, 0, 0), 16))
			button.add_theme_stylebox_override("hover", make_style(SURFACE_SOFT, 16))


func build_life_page() -> void:
	var content := make_scroll_page()
	content.add_child(build_profile_card())
	content.add_child(build_stats_card())

	if bool(simulation.data.get("alive", true)):
		var age_button := make_button("AGE +1", "primary", 24)
		age_button.custom_minimum_size.y = 78
		age_button.disabled = not simulation.pending_event.is_empty()
		age_button.tooltip_text = "Choose an event response before aging up." if age_button.disabled else "Move forward one year"
		age_button.pressed.connect(on_age_up)
		content.add_child(age_button)
	else:
		content.add_child(build_life_summary_card())

	var timeline_header := HBoxContainer.new()
	timeline_header.add_theme_constant_override("separation", 10)
	content.add_child(timeline_header)
	var timeline_title := make_label("LIFE TIMELINE", 18, TEXT, 800)
	timeline_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	timeline_header.add_child(timeline_title)
	var count_label := make_label("%d MOMENTS" % simulation.data.get("history", []).size(), 12, MUTED, 700)
	timeline_header.add_child(count_label)

	var history: Array = simulation.data.get("history", [])
	for entry in history:
		content.add_child(build_history_card(entry))


func build_profile_card() -> Control:
	var panel := make_panel(SURFACE_RAISED, 24, 1, LINE)
	var margin := MarginContainer.new()
	set_margins(margin, 18, 18, 18, 18)
	panel.add_child(margin)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 18)
	margin.add_child(row)

	var avatar_shell := PanelContainer.new()
	avatar_shell.custom_minimum_size = Vector2(174, 174)
	avatar_shell.add_theme_stylebox_override("panel", make_style(Color("0d1a2b"), 28, 2, Color("2f6871")))
	row.add_child(avatar_shell)
	var avatar := StoryAvatar.new()
	avatar.custom_minimum_size = Vector2(170, 170)
	var stats: Dictionary = simulation.data.get("stats", {})
	avatar.set_profile(int(simulation.data.get("age", 0)), int(stats.get("health", 0)), int(stats.get("happiness", 0)))
	avatar_shell.add_child(avatar)

	var details := VBoxContainer.new()
	details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	details.add_theme_constant_override("separation", 5)
	row.add_child(details)
	var full_name := "%s %s" % [str(simulation.data.get("first_name", "Austin")), str(simulation.data.get("last_name", "Dagenais"))]
	var name_label := make_label(full_name, 27, TEXT, 900)
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	details.add_child(name_label)
	details.add_child(make_label(str(simulation.data.get("birthplace", "Kelowna, British Columbia")), 13, MUTED, 500))
	details.add_child(make_divider())
	var job: Dictionary = simulation.data.get("job", {})
	var role := "Retired" if bool(simulation.data.get("retired", false)) else str(job.get("title", "Growing up" if int(simulation.data.get("age", 0)) < 18 else "Between jobs"))
	details.add_child(make_key_value("CURRENT", role, TEAL))
	details.add_child(make_key_value("EDUCATION", str(simulation.data.get("education_label", "At home")), BLUE))
	details.add_child(make_key_value("BALANCE", simulation.format_money(int(simulation.data.get("balance", 0))), GOLD if int(simulation.data.get("balance", 0)) >= 0 else ROSE))
	return panel


func build_stats_card() -> Control:
	var panel := make_panel(SURFACE, 22, 1, LINE)
	var margin := MarginContainer.new()
	set_margins(margin, 18, 16, 18, 16)
	panel.add_child(margin)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 10)
	margin.add_child(content)
	var heading := HBoxContainer.new()
	content.add_child(heading)
	var title := make_label("YOUR VITALS", 15, TEXT, 800)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	heading.add_child(title)
	heading.add_child(make_label("LIFE SCORE %d" % simulation.life_score(), 12, TEAL, 700))
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 16)
	grid.add_theme_constant_override("v_separation", 9)
	content.add_child(grid)
	var stats: Dictionary = simulation.data.get("stats", {})
	var definitions := [
		["HEALTH", "health", TEAL],
		["HAPPINESS", "happiness", GOLD],
		["SMARTS", "smarts", BLUE],
		["CONFIDENCE", "confidence", Color("b68cff")],
		["DISCIPLINE", "discipline", Color("75d6e8")],
		["REPUTATION", "reputation", ROSE]
	]
	for definition in definitions:
		grid.add_child(build_stat_meter(str(definition[0]), int(stats.get(definition[1], 0)), definition[2]))
	return panel


func build_stat_meter(title: String, value: int, color: Color) -> Control:
	var box := VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.custom_minimum_size.x = 292
	box.add_theme_constant_override("separation", 3)
	var row := HBoxContainer.new()
	box.add_child(row)
	var label := make_label(title, 11, MUTED, 700)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(label)
	row.add_child(make_label("%d" % value, 12, TEXT, 800))
	var bar := ProgressBar.new()
	bar.min_value = 0
	bar.max_value = 100
	bar.value = value
	bar.show_percentage = false
	bar.custom_minimum_size.y = 9
	bar.add_theme_stylebox_override("background", make_style(Color("07111d"), 5))
	bar.add_theme_stylebox_override("fill", make_style(color, 5))
	box.add_child(bar)
	return box


func build_history_card(entry: Dictionary) -> Control:
	var tone := str(entry.get("tone", "neutral"))
	var accent := MUTED
	match tone:
		"teal": accent = TEAL
		"gold": accent = GOLD
		"rose": accent = ROSE
		"blue": accent = BLUE
	var panel := make_panel(Color("102238"), 18, 1, Color(accent, 0.52))
	var margin := MarginContainer.new()
	set_margins(margin, 16, 13, 16, 13)
	panel.add_child(margin)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 14)
	margin.add_child(row)
	var age_chip := PanelContainer.new()
	age_chip.custom_minimum_size = Vector2(66, 58)
	age_chip.add_theme_stylebox_override("panel", make_style(Color(accent, 0.16), 14, 1, Color(accent, 0.7)))
	row.add_child(age_chip)
	var age_label := make_label("AGE\n%d" % int(entry.get("age", 0)), 12, accent, 800)
	age_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	age_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	age_chip.add_child(age_label)
	var text_box := VBoxContainer.new()
	text_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_box.add_theme_constant_override("separation", 3)
	row.add_child(text_box)
	text_box.add_child(make_label(str(entry.get("title", "A moment")), 16, TEXT, 800))
	var body := make_label(str(entry.get("body", "")), 13, MUTED, 500)
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text_box.add_child(body)
	return panel


func build_life_summary_card() -> Control:
	var panel := make_panel(Color("251c2a"), 24, 1, ROSE)
	var margin := MarginContainer.new()
	set_margins(margin, 22, 20, 22, 20)
	panel.add_child(margin)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	margin.add_child(box)
	box.add_child(make_label("A LIFE COMPLETED", 24, TEXT, 900))
	var cause := str(simulation.data.get("cause_of_death", "natural causes"))
	var summary := "%s lived to age %d and died from %s." % [str(simulation.data.get("first_name", "Your character")), int(simulation.data.get("age", 0)), cause]
	var summary_label := make_label(summary, 15, MUTED, 500)
	summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(summary_label)
	box.add_child(make_key_value("FINAL SCORE", str(simulation.life_score()), GOLD))
	box.add_child(make_key_value("NET WORTH", simulation.format_money(simulation.net_worth()), TEAL))
	box.add_child(make_key_value("MEMORIES", str(simulation.data.get("history", []).size()), BLUE))
	var restart := make_button("BEGIN ANOTHER LIFE", "primary", 17)
	restart.custom_minimum_size.y = 62
	restart.pressed.connect(show_new_life_dialog)
	box.add_child(restart)
	return panel


func build_people_page() -> void:
	var content := make_scroll_page()
	content.add_child(make_page_intro("PEOPLE", "Relationships grow when you choose to show up."))
	var relationships := simulation.relationship_entries()
	for relationship in relationships:
		content.add_child(build_relationship_card(relationship))
	if relationships.is_empty():
		content.add_child(make_empty_card("No close relationships yet", "New people will enter your story as you age."))


func build_relationship_card(relationship: Dictionary) -> Control:
	var panel := make_panel(SURFACE, 20, 1, LINE)
	var margin := MarginContainer.new()
	set_margins(margin, 18, 15, 18, 15)
	panel.add_child(margin)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	margin.add_child(box)
	var header := HBoxContainer.new()
	box.add_child(header)
	var name := make_label(str(relationship.get("name", "Someone")), 20, TEXT, 800)
	name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(name)
	var value := int(relationship.get("value", 50))
	header.add_child(make_label("%d%%" % value, 15, TEAL if value >= 50 else ROSE, 800))
	var bar := ProgressBar.new()
	bar.max_value = 100
	bar.value = value
	bar.show_percentage = false
	bar.custom_minimum_size.y = 11
	bar.add_theme_stylebox_override("background", make_style(Color("07111d"), 6))
	bar.add_theme_stylebox_override("fill", make_style(TEAL if value >= 50 else ROSE, 6))
	box.add_child(bar)
	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 8)
	box.add_child(actions)
	var action_defs := [["TALK", "talk"], ["HANG OUT", "spend_time"], ["GIFT", "gift"]]
	for action_def in action_defs:
		var button := make_button(str(action_def[0]), "secondary", 12)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.custom_minimum_size.y = 48
		button.pressed.connect(on_relationship_action.bind(str(relationship.get("key", "")), str(action_def[1])))
		actions.add_child(button)
	return panel


func build_work_page() -> void:
	var content := make_scroll_page()
	content.add_child(make_page_intro("WORK & EDUCATION", "Search %s realistic career options across %d sectors." % [format_number(CareerCatalog.count()), CareerCatalog.sectors().size()]))
	content.add_child(build_current_work_card())
	content.add_child(make_section_label("EDUCATION PATHS"))
	content.add_child(build_education_card())
	content.add_child(make_section_label("CAREER EXPLORER"))
	content.add_child(build_career_filters())
	var education_limit := int(simulation.data.get("education", 0)) if career_eligible_only else -1
	var results := CareerCatalog.filter_jobs(career_query, career_sector, education_limit)
	var page_count := maxi(1, int(ceil(float(results.size()) / float(CAREERS_PER_PAGE))))
	career_page = clampi(career_page, 0, page_count - 1)
	var start_index := career_page * CAREERS_PER_PAGE
	var end_index := mini(results.size(), start_index + CAREERS_PER_PAGE)
	var result_header := HBoxContainer.new()
	content.add_child(result_header)
	var result_count := make_label("%s MATCHES" % format_number(results.size()), 13, TEAL, 800)
	result_count.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	result_header.add_child(result_count)
	result_header.add_child(make_label("PAGE %d / %d" % [career_page + 1, page_count], 12, MUTED, 700))
	if results.is_empty():
		content.add_child(make_empty_card("No careers matched", "Try a broader title, workplace, or sector."))
	else:
		for index in range(start_index, end_index):
			content.add_child(build_job_card(results[index]))
	content.add_child(build_career_pagination(page_count))


func build_current_work_card() -> Control:
	var panel := make_panel(SURFACE_RAISED, 22, 1, Color("35677a"))
	var margin := MarginContainer.new()
	set_margins(margin, 19, 17, 19, 17)
	panel.add_child(margin)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 9)
	margin.add_child(box)
	box.add_child(make_label("YOUR PATH", 13, TEAL, 800))
	box.add_child(make_key_value("EDUCATION", str(simulation.data.get("education_label", "At home")), BLUE))
	var job: Dictionary = simulation.data.get("job", {})
	var job_title := "Retired" if bool(simulation.data.get("retired", false)) else str(job.get("title", "Not employed"))
	box.add_child(make_key_value("POSITION", job_title, TEXT))
	if not job.is_empty():
		box.add_child(make_key_value("CAREER RANK", str(job.get("rank", "Entry")), BLUE))
		box.add_child(make_key_value("SECTOR", str(job.get("sector", "General")), MUTED))
	box.add_child(make_key_value("ANNUAL PAY", simulation.format_money(int(job.get("salary", 0))) if not job.is_empty() else "$0", GOLD))
	if not job.is_empty() and not bool(simulation.data.get("retired", false)):
		var progress := ProgressBar.new()
		progress.max_value = 100
		progress.value = int(simulation.data.get("job_progress", 0))
		progress.show_percentage = false
		progress.custom_minimum_size.y = 12
		progress.add_theme_stylebox_override("background", make_style(Color("07111d"), 6))
		progress.add_theme_stylebox_override("fill", make_style(GOLD, 6))
		box.add_child(progress)
		box.add_child(make_label("%d%% toward your next career level" % int(simulation.data.get("job_progress", 0)), 12, MUTED, 600))
	return panel


func build_education_card() -> Control:
	var panel := make_panel(SURFACE, 20, 1, LINE)
	var margin := MarginContainer.new()
	set_margins(margin, 17, 15, 17, 15)
	panel.add_child(margin)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	margin.add_child(box)
	var current_level := int(simulation.data.get("education", 0))
	box.add_child(make_key_value("CURRENT LEVEL", CareerCatalog.education_label(current_level), BLUE))
	var active: Dictionary = simulation.data.get("education_program", {})
	if not active.is_empty():
		box.add_child(make_key_value("ENROLLED", str(active.get("title", "Program")), TEAL))
		box.add_child(make_key_value("TIME LEFT", "%d years" % int(active.get("years_left", 0)), GOLD))
		box.add_child(make_key_value("YEARLY TUITION", simulation.format_money(int(active.get("annual_cost", 0))), ROSE))
		var note := make_label("Study progresses automatically whenever you age up.", 12, MUTED, 500)
		note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		box.add_child(note)
		return panel
	for program in CareerCatalog.education_programs():
		box.add_child(build_program_row(program, current_level))
	return panel


func build_program_row(program: Dictionary, current_level: int) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	var details := VBoxContainer.new()
	details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	details.add_theme_constant_override("separation", 2)
	row.add_child(details)
	details.add_child(make_label(str(program.get("title", "Program")), 15, TEXT, 800))
	var summary := "%d years • %s/year • %s" % [int(program.get("years", 1)), simulation.format_money(int(program.get("annual_cost", 0))), str(program.get("subtitle", ""))]
	var summary_label := make_label(summary, 11, MUTED, 500)
	summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	details.add_child(summary_label)
	var button := make_button("ENROLL", "secondary", 11)
	button.custom_minimum_size = Vector2(94, 48)
	button.disabled = current_level < int(program.get("requires", 0)) or current_level >= int(program.get("target", 0)) or int(simulation.data.get("age", 0)) < 18
	button.pressed.connect(on_program_enroll.bind(str(program.get("id", ""))))
	row.add_child(button)
	return row


func build_career_filters() -> Control:
	var panel := make_panel(SURFACE_RAISED, 20, 1, Color("35677a"))
	var margin := MarginContainer.new()
	set_margins(margin, 15, 14, 15, 14)
	panel.add_child(margin)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 9)
	margin.add_child(box)
	var search := make_line_edit(career_query, "Search nurse, welder, artist, pilot…")
	search.text = career_query
	box.add_child(search)
	var filter_row := HBoxContainer.new()
	filter_row.add_theme_constant_override("separation", 8)
	box.add_child(filter_row)
	var sector_select := OptionButton.new()
	sector_select.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sector_select.custom_minimum_size.y = 54
	sector_select.add_theme_font_size_override("font_size", 13)
	sector_select.add_theme_color_override("font_color", TEXT)
	sector_select.add_theme_stylebox_override("normal", make_style(Color("0d1d2d"), 14, 1, LINE))
	sector_select.add_item("All sectors")
	for sector_name in CareerCatalog.sectors():
		sector_select.add_item(str(sector_name))
	for index in range(sector_select.item_count):
		if sector_select.get_item_text(index) == career_sector:
			sector_select.select(index)
			break
	filter_row.add_child(sector_select)
	var search_button := make_button("SEARCH", "primary", 12)
	search_button.custom_minimum_size = Vector2(112, 54)
	search_button.pressed.connect(on_career_search.bind(search, sector_select))
	filter_row.add_child(search_button)
	var eligible := CheckButton.new()
	eligible.text = "Only show careers my education currently qualifies for"
	eligible.button_pressed = career_eligible_only
	eligible.add_theme_font_size_override("font_size", 12)
	eligible.add_theme_color_override("font_color", MUTED)
	box.add_child(eligible)
	eligible.toggled.connect(on_career_eligible_toggled)
	search.text_submitted.connect(on_career_text_submitted.bind(search, sector_select))
	return panel


func build_career_pagination(page_count: int) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	var previous := make_button("PREVIOUS", "secondary", 13)
	previous.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	previous.custom_minimum_size.y = 54
	previous.disabled = career_page <= 0
	previous.pressed.connect(on_career_page.bind(-1))
	row.add_child(previous)
	var next := make_button("NEXT", "secondary", 13)
	next.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	next.custom_minimum_size.y = 54
	next.disabled = career_page >= page_count - 1
	next.pressed.connect(on_career_page.bind(1))
	row.add_child(next)
	return row


func build_job_card(job: Dictionary) -> Control:
	var panel := make_panel(SURFACE, 18, 1, LINE)
	var margin := MarginContainer.new()
	set_margins(margin, 16, 13, 16, 13)
	panel.add_child(margin)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	margin.add_child(row)
	var details := VBoxContainer.new()
	details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	details.add_theme_constant_override("separation", 4)
	row.add_child(details)
	var title_label := make_label(str(job.get("title", "Job")), 17, TEXT, 800)
	title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	details.add_child(title_label)
	details.add_child(make_label("%s / year" % simulation.format_money(int(job.get("salary", 0))), 14, GOLD, 700))
	details.add_child(make_label(str(job.get("sector", "General")), 11, TEAL, 700))
	var requirement := "Age %d • %s • %s %d" % [int(job.get("min_age", 18)), CareerCatalog.education_short_label(int(job.get("education", 0))), str(job.get("stat", "smarts")).capitalize(), int(job.get("minimum", 0))]
	details.add_child(make_label(requirement, 11, MUTED, 500))
	var apply := make_button("APPLY", "secondary", 12)
	apply.custom_minimum_size = Vector2(105, 52)
	apply.pressed.connect(on_job_apply.bind(str(job.get("id", ""))))
	row.add_child(apply)
	return panel


func build_activities_page() -> void:
	var content := make_scroll_page()
	content.add_child(make_page_intro("ACTIVITIES", "Each activity can be completed once per year."))
	var used: Array = simulation.data.get("activities_used", [])
	for activity in EventCatalog.activities():
		content.add_child(build_activity_card(activity, used.has(str(activity.get("id", "")))))


func build_activity_card(activity: Dictionary, used: bool) -> Control:
	var panel := make_panel(SURFACE, 18, 1, LINE)
	var margin := MarginContainer.new()
	set_margins(margin, 16, 13, 16, 13)
	panel.add_child(margin)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	margin.add_child(row)
	var details := VBoxContainer.new()
	details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	details.add_theme_constant_override("separation", 4)
	row.add_child(details)
	details.add_child(make_label(str(activity.get("title", "Activity")), 17, TEXT, 800))
	details.add_child(make_label(str(activity.get("subtitle", "")), 12, MUTED, 500))
	var cost := int(activity.get("cost", 0))
	details.add_child(make_label("FREE" if cost == 0 else simulation.format_money(cost), 12, TEAL if cost == 0 else GOLD, 700))
	var button := make_button("DONE" if used else "DO IT", "secondary", 12)
	button.custom_minimum_size = Vector2(105, 54)
	button.disabled = used
	button.pressed.connect(on_activity.bind(str(activity.get("id", ""))))
	row.add_child(button)
	return panel


func build_assets_page() -> void:
	var content := make_scroll_page()
	content.add_child(make_page_intro("MONEY & ASSETS", "Build a life you can afford to keep."))
	content.add_child(build_finance_card())
	content.add_child(make_section_label("MARKETPLACE"))
	for asset in EventCatalog.assets():
		content.add_child(build_asset_card(asset))


func build_finance_card() -> Control:
	var panel := make_panel(SURFACE_RAISED, 22, 1, Color("426873"))
	var margin := MarginContainer.new()
	set_margins(margin, 18, 16, 18, 16)
	panel.add_child(margin)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 9)
	margin.add_child(box)
	box.add_child(make_label("FINANCIAL SNAPSHOT", 14, TEAL, 800))
	box.add_child(make_key_value("CASH", simulation.format_money(int(simulation.data.get("balance", 0))), GOLD))
	box.add_child(make_key_value("NET WORTH", simulation.format_money(simulation.net_worth()), TEXT))
	box.add_child(make_key_value("LAST INCOME", simulation.format_money(int(simulation.data.get("last_income", 0))), TEAL))
	box.add_child(make_key_value("LAST EXPENSES", simulation.format_money(int(simulation.data.get("last_expenses", 0))), ROSE))
	var owned: Array = simulation.data.get("assets", [])
	box.add_child(make_key_value("OWNED ASSETS", str(owned.size()), BLUE))
	return panel


func build_asset_card(asset: Dictionary) -> Control:
	var owned := simulation.owns_asset(str(asset.get("id", "")))
	var panel := make_panel(SURFACE, 18, 1, TEAL if owned else LINE)
	var margin := MarginContainer.new()
	set_margins(margin, 16, 13, 16, 13)
	panel.add_child(margin)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	margin.add_child(row)
	var details := VBoxContainer.new()
	details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	details.add_theme_constant_override("separation", 4)
	row.add_child(details)
	details.add_child(make_label(str(asset.get("title", "Asset")), 17, TEXT, 800))
	details.add_child(make_label(str(asset.get("subtitle", "")), 12, MUTED, 500))
	var yearly_cost := int(asset.get("yearly_cost", 0))
	var upkeep_text := "+%s yearly" % simulation.format_money(absi(yearly_cost)) if yearly_cost < 0 else "%s yearly cost" % simulation.format_money(yearly_cost)
	details.add_child(make_label("%s • %s" % [simulation.format_money(int(asset.get("price", 0))), upkeep_text], 12, GOLD, 700))
	var button := make_button("OWNED" if owned else "BUY", "secondary", 12)
	button.custom_minimum_size = Vector2(105, 54)
	button.disabled = owned
	button.pressed.connect(on_asset_purchase.bind(str(asset.get("id", ""))))
	row.add_child(button)
	return panel


func on_age_up() -> void:
	var event := simulation.age_up()
	show_page("life")
	if not event.is_empty():
		show_event_dialog(event)
	elif not bool(simulation.data.get("alive", true)):
		show_toast("Your life story is complete.")


func on_relationship_action(key: String, action: String) -> void:
	var result := simulation.relationship_action(key, action)
	show_toast(str(result.get("message", "")), bool(result.get("ok", false)))
	show_page("people")


func on_job_apply(job_id: String) -> void:
	var result := simulation.apply_for_job(job_id)
	show_toast(str(result.get("message", "")), bool(result.get("ok", false)))
	show_page("work")


func on_program_enroll(program_id: String) -> void:
	var result := simulation.enroll_education(program_id)
	show_toast(str(result.get("message", "")), bool(result.get("ok", false)))
	show_page("work")


func on_career_search(search: LineEdit, sector_select: OptionButton) -> void:
	career_query = search.text.strip_edges()
	career_sector = sector_select.get_item_text(sector_select.selected)
	career_page = 0
	show_page("work")


func on_career_text_submitted(_submitted: String, search: LineEdit, sector_select: OptionButton) -> void:
	on_career_search(search, sector_select)


func on_career_eligible_toggled(enabled: bool) -> void:
	career_eligible_only = enabled
	career_page = 0
	show_page("work")


func on_career_page(direction: int) -> void:
	career_page = maxi(0, career_page + direction)
	show_page("work")


func on_activity(activity_id: String) -> void:
	var result := simulation.perform_activity(activity_id)
	show_toast(str(result.get("message", "")), bool(result.get("ok", false)))
	show_page("activities")


func on_asset_purchase(asset_id: String) -> void:
	var result := simulation.purchase_asset(asset_id)
	show_toast(str(result.get("message", "")), bool(result.get("ok", false)))
	show_page("assets")


func show_event_dialog(event: Dictionary) -> void:
	close_overlay()
	overlay = ColorRect.new()
	overlay.color = Color(0.015, 0.03, 0.05, 0.88)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.z_index = 100
	add_child(overlay)

	var outer_margin := MarginContainer.new()
	outer_margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	set_margins(outer_margin, 38, 88, 38, 58)
	overlay.add_child(outer_margin)
	var center := CenterContainer.new()
	outer_margin.add_child(center)
	var card := make_panel(Color("14293d"), 28, 2, Color("3c6978"))
	card.custom_minimum_size.x = 620
	center.add_child(card)
	var margin := MarginContainer.new()
	set_margins(margin, 26, 24, 26, 24)
	card.add_child(margin)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 15)
	margin.add_child(box)
	var kicker := make_label("AGE %d • A TURNING POINT" % int(simulation.data.get("age", 0)), 12, TEAL, 800)
	box.add_child(kicker)
	var title := make_label(str(event.get("title", "A choice")), 29, TEXT, 900)
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(title)
	var body := make_label(str(event.get("body", "")), 17, Color("d5e2ea"), 500)
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.add_theme_constant_override("line_spacing", 5)
	box.add_child(body)
	box.add_child(make_divider())
	var choices: Array = event.get("choices", [])
	for index in range(choices.size()):
		var choice: Dictionary = choices[index]
		var button := make_button(str(choice.get("text", "Choose")), "choice", 16)
		button.custom_minimum_size.y = 68
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.pressed.connect(resolve_event_choice.bind(index))
		box.add_child(button)
	box.add_child(make_label("Your decision is recorded in the timeline.", 11, MUTED, 500))


func resolve_event_choice(index: int) -> void:
	var result := simulation.resolve_choice(index)
	close_overlay()
	show_page("life")
	show_toast(result, true)


func show_new_life_dialog() -> void:
	close_overlay()
	overlay = ColorRect.new()
	overlay.color = Color(0.015, 0.03, 0.05, 0.9)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.z_index = 100
	add_child(overlay)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(center)
	var card := make_panel(Color("14293d"), 28, 2, Color("3c6978"))
	card.custom_minimum_size = Vector2(610, 0)
	center.add_child(card)
	var margin := MarginContainer.new()
	set_margins(margin, 28, 26, 28, 26)
	card.add_child(margin)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 14)
	margin.add_child(box)
	box.add_child(make_label("BEGIN A NEW LIFE", 27, TEXT, 900))
	var warning := make_label("Starting again replaces the current local save, but the finished timeline will remain yours until you confirm.", 14, MUTED, 500)
	warning.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(warning)
	var first_input := make_line_edit(str(simulation.data.get("first_name", "Austin")), "First name")
	box.add_child(first_input)
	var last_input := make_line_edit(str(simulation.data.get("last_name", "Dagenais")), "Last name")
	box.add_child(last_input)
	var start := make_button("START NEW STORY", "primary", 16)
	start.custom_minimum_size.y = 62
	start.pressed.connect(start_new_life.bind(first_input, last_input))
	box.add_child(start)
	var cancel := make_button("KEEP CURRENT LIFE", "secondary", 14)
	cancel.custom_minimum_size.y = 56
	cancel.pressed.connect(close_overlay)
	box.add_child(cancel)


func start_new_life(first_input: LineEdit, last_input: LineEdit) -> void:
	simulation.new_life(first_input.text, last_input.text)
	close_overlay()
	show_page("life")
	show_toast("A new story has begun.", true)


func close_overlay() -> void:
	if is_instance_valid(overlay):
		overlay.queue_free()
	overlay = null


func show_toast(message: String, success: bool = false) -> void:
	if message.is_empty() or toast_panel == null:
		return
	toast_serial += 1
	var serial := toast_serial
	toast_label.text = message
	toast_panel.add_theme_stylebox_override("panel", make_style(Color("24495b") if success else Color("4b2f3b"), 18, 1, TEAL if success else ROSE))
	toast_panel.modulate = Color.WHITE
	toast_panel.visible = true
	get_tree().create_timer(2.8).timeout.connect(func() -> void:
		if serial == toast_serial and is_instance_valid(toast_panel):
			toast_panel.visible = false
	)


func make_scroll_page() -> VBoxContainer:
	var scroll := ScrollContainer.new()
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	page_host.add_child(scroll)
	var outer := MarginContainer.new()
	outer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	set_margins(outer, 0, 2, 5, 16)
	scroll.add_child(outer)
	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 13)
	outer.add_child(content)
	return content


func make_page_intro(title_text: String, subtitle_text: String) -> Control:
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 3)
	box.add_child(make_label(title_text, 27, TEXT, 900))
	var subtitle := make_label(subtitle_text, 14, MUTED, 500)
	subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(subtitle)
	return box


func make_section_label(text_value: String) -> Label:
	var label := make_label(text_value, 14, TEAL, 800)
	label.add_theme_constant_override("outline_size", 2)
	label.add_theme_color_override("font_outline_color", BG)
	return label


func make_empty_card(title_text: String, body_text: String) -> Control:
	var panel := make_panel(SURFACE, 20, 1, LINE)
	var margin := MarginContainer.new()
	set_margins(margin, 20, 20, 20, 20)
	panel.add_child(margin)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 5)
	margin.add_child(box)
	box.add_child(make_label(title_text, 18, TEXT, 800))
	var body := make_label(body_text, 13, MUTED, 500)
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(body)
	return panel


func make_key_value(key_text: String, value_text: String, value_color: Color) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	var key_label := make_label(key_text, 11, MUTED, 700)
	key_label.custom_minimum_size.x = 90
	row.add_child(key_label)
	var value_label := make_label(value_text, 13, value_color, 700)
	value_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	value_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	row.add_child(value_label)
	return row


func make_divider() -> Control:
	var divider := ColorRect.new()
	divider.color = LINE
	divider.custom_minimum_size.y = 1
	divider.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return divider


func make_panel(color: Color, radius: int, border_width: int = 0, border_color: Color = Color.TRANSPARENT) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", make_style(color, radius, border_width, border_color))
	return panel


func make_style(color: Color, radius: int, border_width: int = 0, border_color: Color = Color.TRANSPARENT) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	if border_width > 0:
		style.border_width_left = border_width
		style.border_width_top = border_width
		style.border_width_right = border_width
		style.border_width_bottom = border_width
		style.border_color = border_color
	style.anti_aliasing = true
	return style


func make_label(text_value: String, font_size: int, color: Color, weight: int = 500) -> Label:
	var label := Label.new()
	label.text = text_value
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	if weight >= 700:
		label.add_theme_constant_override("outline_size", 1)
		label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.16))
	return label


func make_button(text_value: String, style_name: String, font_size: int) -> Button:
	var button := Button.new()
	button.text = text_value
	button.add_theme_font_size_override("font_size", font_size)
	button.add_theme_color_override("font_color", TEXT)
	button.add_theme_color_override("font_hover_color", TEXT)
	button.add_theme_color_override("font_pressed_color", TEXT)
	button.add_theme_color_override("font_disabled_color", Color(MUTED, 0.55))
	button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	match style_name:
		"primary":
			button.add_theme_color_override("font_color", BG)
			button.add_theme_color_override("font_hover_color", BG)
			button.add_theme_color_override("font_pressed_color", BG)
			button.add_theme_stylebox_override("normal", make_style(TEAL, 18))
			button.add_theme_stylebox_override("hover", make_style(Color("5bd1b7"), 18))
			button.add_theme_stylebox_override("pressed", make_style(TEAL_DARK, 18))
		"choice":
			button.alignment = HORIZONTAL_ALIGNMENT_LEFT
			button.add_theme_stylebox_override("normal", make_style(Color("1b3850"), 16, 1, Color("3d6678")))
			button.add_theme_stylebox_override("hover", make_style(Color("244a61"), 16, 1, TEAL))
			button.add_theme_stylebox_override("pressed", make_style(Color("163f48"), 16, 1, TEAL))
		"nav":
			button.add_theme_stylebox_override("normal", make_style(Color.TRANSPARENT, 16))
			button.add_theme_stylebox_override("hover", make_style(SURFACE_SOFT, 16))
			button.add_theme_stylebox_override("pressed", make_style(Color("244a61"), 16))
		_:
			button.add_theme_stylebox_override("normal", make_style(SURFACE_SOFT, 15, 1, LINE))
			button.add_theme_stylebox_override("hover", make_style(Color("244a61"), 15, 1, Color("477286")))
			button.add_theme_stylebox_override("pressed", make_style(Color("183646"), 15, 1, TEAL))
	button.add_theme_stylebox_override("disabled", make_style(Color("102131"), 15, 1, Color("243c4d")))
	return button


func make_line_edit(default_text: String, placeholder: String) -> LineEdit:
	var input := LineEdit.new()
	input.text = default_text
	input.placeholder_text = placeholder
	input.custom_minimum_size.y = 58
	input.add_theme_font_size_override("font_size", 16)
	input.add_theme_color_override("font_color", TEXT)
	input.add_theme_color_override("font_placeholder_color", MUTED)
	input.add_theme_stylebox_override("normal", make_style(Color("0d1d2d"), 14, 1, LINE))
	input.add_theme_stylebox_override("focus", make_style(Color("10283a"), 14, 2, TEAL))
	return input


func format_number(value: int) -> String:
	var digits := str(absi(value))
	var formatted := ""
	while digits.length() > 3:
		formatted = "," + digits.right(3) + formatted
		digits = digits.left(digits.length() - 3)
	return digits + formatted


func set_margins(container: MarginContainer, left: int, top: int, right: int, bottom: int) -> void:
	container.add_theme_constant_override("margin_left", left)
	container.add_theme_constant_override("margin_top", top)
	container.add_theme_constant_override("margin_right", right)
	container.add_theme_constant_override("margin_bottom", bottom)


func clear_children(node: Node) -> void:
	for child in node.get_children():
		child.queue_free()
