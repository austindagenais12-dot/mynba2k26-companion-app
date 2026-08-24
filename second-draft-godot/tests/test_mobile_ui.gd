extends SceneTree


func _initialize() -> void:
	call_deferred("run_tests")


func run_tests() -> void:
	var failures: Array[String] = []
	var packed_scene := load("res://main.tscn") as PackedScene
	if packed_scene == null:
		failures.append("Could not load the main scene.")
		finish(failures, null)
		return
	var app = packed_scene.instantiate()
	root.add_child(app)
	await wait_frames(3)

	for page_name in ["life", "people", "work", "activities", "assets"]:
		app.call("show_page", page_name)
		await wait_frames(3)
		var page_host := app.get("page_host") as Control
		var page_scroll := find_scroll_container(page_host)
		if page_scroll == null:
			failures.append("%s page has no ScrollContainer." % page_name)
			continue
		if not page_scroll.follow_focus:
			failures.append("%s page does not follow focused controls." % page_name)
		if page_scroll.vertical_scroll_mode == ScrollContainer.SCROLL_MODE_DISABLED:
			failures.append("%s page has vertical scrolling disabled." % page_name)
		if page_scroll.scroll_deadzone <= 0:
			failures.append("%s page has no mobile drag deadzone." % page_name)

	app.call("show_page", "work")
	await wait_frames(4)
	var work_host := app.get("page_host") as Control
	var work_scroll := find_scroll_container(work_host)
	if work_scroll == null:
		failures.append("Work page scroll container disappeared.")
		finish(failures, app)
		return
	var work_bar := work_scroll.get_v_scroll_bar()
	var available_scroll := int(work_bar.max_value - work_bar.page)
	if available_scroll < 400:
		failures.append("The career page did not produce a usable vertical scroll range.")
	work_scroll.scroll_vertical = mini(300, available_scroll)
	await wait_frames(2)
	var remembered_scroll := work_scroll.scroll_vertical
	if remembered_scroll <= 0:
		failures.append("The career page could not be scrolled programmatically.")

	app.call("show_page", "life")
	await wait_frames(3)
	app.call("show_page", "work")
	await wait_frames(4)
	work_host = app.get("page_host") as Control
	work_scroll = find_scroll_container(work_host)
	if work_scroll == null or absi(work_scroll.scroll_vertical - remembered_scroll) > 3:
		failures.append("Page scroll position was not restored after tab navigation.")

	var text_inputs: Array[LineEdit] = []
	collect_line_edits(work_host, text_inputs)
	if text_inputs.size() != 1:
		failures.append("Expected one career search field, found %d." % text_inputs.size())
	else:
		var search := text_inputs[0]
		if search.mouse_filter != Control.MOUSE_FILTER_PASS:
			failures.append("Career search does not pass touch drags to its scroll parent.")
		if not search.virtual_keyboard_enabled or not search.virtual_keyboard_show_on_focus:
			failures.append("Career search is not configured for the mobile keyboard.")
		var baseline_max := work_scroll.get_v_scroll_bar().max_value
		work_scroll.scroll_vertical = 0
		search.grab_focus()
		await create_timer(0.70).timeout
		await wait_frames(2)
		if not search.has_focus():
			failures.append("Career search did not retain input focus.")
		if work_scroll.get_v_scroll_bar().max_value < baseline_max + 300.0:
			failures.append("Keyboard focus did not add enough scroll room below the search field.")
		if work_scroll.scroll_vertical <= 0:
			failures.append("Career search focus did not move the page into view.")
		search.release_focus()
		await wait_frames(4)

	var page_buttons: Array[Button] = []
	collect_buttons(work_scroll, page_buttons)
	for button in page_buttons:
		if button.mouse_filter == Control.MOUSE_FILTER_STOP:
			failures.append("A career-page button still blocks touch scrolling: %s" % button.text)
			break

	app.call("show_new_life_dialog")
	await wait_frames(3)
	var dialog_overlay := app.get("overlay") as Control
	var dialog_scroll := find_scroll_container(dialog_overlay)
	var dialog_inputs: Array[LineEdit] = []
	collect_line_edits(dialog_overlay, dialog_inputs)
	if dialog_scroll == null or not dialog_scroll.follow_focus:
		failures.append("New-life dialog is not scrollable and focus-aware.")
	if dialog_inputs.size() != 2:
		failures.append("Expected two name fields in the new-life dialog.")
	else:
		dialog_inputs[1].grab_focus()
		await create_timer(0.35).timeout
		if not dialog_inputs[1].has_focus():
			failures.append("The second name field did not retain focus.")
	app.call("close_overlay")
	await wait_frames(2)

	finish(failures, app)


func wait_frames(count: int) -> void:
	for _index in range(count):
		await process_frame


func find_scroll_container(node: Node) -> ScrollContainer:
	if node == null:
		return null
	if node is ScrollContainer:
		return node as ScrollContainer
	for child in node.get_children():
		var found := find_scroll_container(child)
		if found != null:
			return found
	return null


func collect_line_edits(node: Node, results: Array[LineEdit]) -> void:
	if node == null:
		return
	if node is LineEdit:
		results.append(node as LineEdit)
	for child in node.get_children():
		collect_line_edits(child, results)


func collect_buttons(node: Node, results: Array[Button]) -> void:
	if node == null:
		return
	if node is Button:
		results.append(node as Button)
	for child in node.get_children():
		collect_buttons(child, results)


func finish(failures: Array[String], app: Node) -> void:
	if is_instance_valid(app):
		app.queue_free()
	if failures.is_empty():
		print("PASS: all five pages scroll, positions persist, touch controls pass drags, and text fields follow Android keyboard focus.")
		quit(0)
		return
	for failure in failures:
		push_error(failure)
	quit(1)
