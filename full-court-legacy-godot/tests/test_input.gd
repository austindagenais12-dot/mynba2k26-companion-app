extends SceneTree

const VirtualJoystickScript = preload("res://scripts/virtual_joystick.gd")

func _initialize() -> void:
	var joystick = VirtualJoystickScript.new()
	joystick.size = Vector2(286.0, 286.0)
	var center := Vector2(143.0, 143.0)
	var up := joystick.map_local_point(Vector2(143.0, 30.0))
	var down := joystick.map_local_point(Vector2(143.0, 256.0))
	var left := joystick.map_local_point(Vector2(30.0, 143.0))
	var right := joystick.map_local_point(Vector2(256.0, 143.0))
	var neutral := joystick.map_local_point(center)

	assert(up.y > 0.95, "Touching above centre must move the player forward.")
	assert(down.y < -0.95, "Touching below centre must move the player backward.")
	assert(left.x < -0.95, "Touching left of centre must move the player left.")
	assert(right.x > 0.95, "Touching right of centre must move the player right.")
	assert(neutral.length() < 0.001, "Joystick centre must remain neutral.")
	print("JOYSTICK TESTS PASSED: forward/back/left/right/neutral")
	joystick.free()
	quit(0)
