extends Control

signal value_changed(value: Vector2)

var value := Vector2.ZERO
var _touch_index := -1
var _mouse_active := false
var _handle: Control

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	gui_input.connect(_on_gui_input)

func set_handle(handle: Control) -> void:
	_handle = handle
	_reset_handle()

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and _touch_index == -1:
			_touch_index = event.index
			_update_from_local_position(event.position)
			accept_event()
		elif not event.pressed and event.index == _touch_index:
			_touch_index = -1
			_set_value(Vector2.ZERO)
			accept_event()
	elif event is InputEventScreenDrag and event.index == _touch_index:
		_update_from_local_position(event.position)
		accept_event()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_mouse_active = event.pressed
		if _mouse_active:
			_update_from_local_position(event.position)
		else:
			_set_value(Vector2.ZERO)
		accept_event()
	elif event is InputEventMouseMotion and _mouse_active:
		_update_from_local_position(event.position)
		accept_event()

func _update_from_local_position(local_point: Vector2) -> void:
	var center := size * 0.5
	var radius: float = min(size.x, size.y) * 0.36
	_set_value((local_point - center) / max(radius, 1.0))

func _set_value(next_value: Vector2) -> void:
	var visual_value := next_value.limit_length(1.0)
	# GUI Y grows downward, while gameplay Y uses positive as forward/up.
	value = Vector2(visual_value.x, -visual_value.y)
	if _handle != null:
		var radius: float = min(size.x, size.y) * 0.36
		_handle.position = size * 0.5 - _handle.size * 0.5 + visual_value * radius
	value_changed.emit(value)

func map_local_point(local_point: Vector2) -> Vector2:
	var center := size * 0.5
	var radius: float = min(size.x, size.y) * 0.36
	var visual_value: Vector2 = ((local_point - center) / max(radius, 1.0)).limit_length(1.0)
	return Vector2(visual_value.x, -visual_value.y)

func _reset_handle() -> void:
	if _handle != null:
		_handle.position = size * 0.5 - _handle.size * 0.5
