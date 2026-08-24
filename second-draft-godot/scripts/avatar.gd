extends Control
class_name StoryAvatar

var profile_age := 0
var profile_health := 80
var profile_happiness := 75
var elapsed := 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process(true)


func set_profile(age: int, health: int, happiness: int) -> void:
	profile_age = age
	profile_health = health
	profile_happiness = happiness
	queue_redraw()


func _process(delta: float) -> void:
	elapsed += delta
	queue_redraw()


func _draw() -> void:
	var scale_value := minf(size.x, size.y) / 170.0
	var center := Vector2(size.x * 0.5, size.y * 0.52 + sin(elapsed * 1.5) * 1.3)
	var skin := Color("d6a07d")
	var skin_shadow := Color("b9775b")
	var hair := Color("171922")
	var beard := Color("252027")
	var navy := Color("173a5e")
	var teal := Color("46c2a6")
	var cream := Color("f7fbff")

	draw_circle(center, 80.0 * scale_value, Color(0.08, 0.13, 0.22, 0.18))
	# Jersey and shoulders.
	var body_points := PackedVector2Array([
		center + Vector2(-68, 74) * scale_value,
		center + Vector2(-48, 46) * scale_value,
		center + Vector2(-25, 37) * scale_value,
		center + Vector2(25, 37) * scale_value,
		center + Vector2(48, 46) * scale_value,
		center + Vector2(68, 74) * scale_value
	])
	draw_colored_polygon(body_points, navy)
	draw_line(center + Vector2(-27, 45) * scale_value, center + Vector2(-15, 74) * scale_value, teal, 5.0 * scale_value, true)
	draw_line(center + Vector2(27, 45) * scale_value, center + Vector2(15, 74) * scale_value, teal, 5.0 * scale_value, true)

	# Neck, ears, and face.
	draw_rect(Rect2(center + Vector2(-18, 28) * scale_value, Vector2(36, 34) * scale_value), skin_shadow, true)
	draw_circle(center + Vector2(-40, -2) * scale_value, 12.0 * scale_value, skin_shadow)
	draw_circle(center + Vector2(40, -2) * scale_value, 12.0 * scale_value, skin_shadow)
	draw_circle(center + Vector2(0, -8) * scale_value, 45.0 * scale_value, skin)

	# Full beard inspired by Austin's look grows in as the avatar reaches adulthood.
	if profile_age >= 16:
		var beard_points := PackedVector2Array([
			center + Vector2(-41, 2) * scale_value,
			center + Vector2(-36, 24) * scale_value,
			center + Vector2(-22, 42) * scale_value,
			center + Vector2(0, 49) * scale_value,
			center + Vector2(22, 42) * scale_value,
			center + Vector2(36, 24) * scale_value,
			center + Vector2(41, 2) * scale_value,
			center + Vector2(30, 17) * scale_value,
			center + Vector2(14, 29) * scale_value,
			center + Vector2(0, 32) * scale_value,
			center + Vector2(-14, 29) * scale_value,
			center + Vector2(-30, 17) * scale_value
		])
		draw_colored_polygon(beard_points, beard)
		draw_arc(center + Vector2(0, 7) * scale_value, 13.0 * scale_value, PI * 1.05, PI * 1.95, 18, beard, 5.0 * scale_value, true)
	elif profile_age >= 12:
		draw_arc(center + Vector2(0, 8) * scale_value, 11.0 * scale_value, PI * 1.08, PI * 1.92, 16, Color(0.12, 0.1, 0.12, 0.38), 2.0 * scale_value, true)

	# Swept, layered dark hair.
	var hair_points := PackedVector2Array([
		center + Vector2(-44, -18) * scale_value,
		center + Vector2(-40, -42) * scale_value,
		center + Vector2(-25, -58) * scale_value,
		center + Vector2(-4, -62) * scale_value,
		center + Vector2(19, -56) * scale_value,
		center + Vector2(40, -42) * scale_value,
		center + Vector2(46, -18) * scale_value,
		center + Vector2(32, -30) * scale_value,
		center + Vector2(20, -43) * scale_value,
		center + Vector2(10, -25) * scale_value,
		center + Vector2(-2, -43) * scale_value,
		center + Vector2(-18, -29) * scale_value,
		center + Vector2(-32, -24) * scale_value
	])
	draw_colored_polygon(hair_points, hair)
	draw_arc(center + Vector2(-4, -30) * scale_value, 34.0 * scale_value, PI * 1.08, PI * 1.85, 16, Color("34333d"), 4.0 * scale_value, true)

	# Brows and expressive anime eyes.
	draw_line(center + Vector2(-29, -16) * scale_value, center + Vector2(-8, -19) * scale_value, hair, 4.5 * scale_value, true)
	draw_line(center + Vector2(8, -19) * scale_value, center + Vector2(29, -16) * scale_value, hair, 4.5 * scale_value, true)
	var blinking := fmod(elapsed, 4.6) > 4.42
	if blinking:
		draw_line(center + Vector2(-28, -7) * scale_value, center + Vector2(-8, -7) * scale_value, hair, 3.0 * scale_value, true)
		draw_line(center + Vector2(8, -7) * scale_value, center + Vector2(28, -7) * scale_value, hair, 3.0 * scale_value, true)
	else:
		draw_ellipse_shape(center + Vector2(-18, -7) * scale_value, Vector2(11, 7) * scale_value, cream)
		draw_ellipse_shape(center + Vector2(18, -7) * scale_value, Vector2(11, 7) * scale_value, cream)
		draw_circle(center + Vector2(-16, -7) * scale_value, 5.0 * scale_value, Color("293849"))
		draw_circle(center + Vector2(16, -7) * scale_value, 5.0 * scale_value, Color("293849"))
		draw_circle(center + Vector2(-14, -9) * scale_value, 1.6 * scale_value, cream)
		draw_circle(center + Vector2(18, -9) * scale_value, 1.6 * scale_value, cream)

	# Nose, expression, and subtle aging details.
	draw_line(center + Vector2(0, -6) * scale_value, center + Vector2(-3, 6) * scale_value, skin_shadow, 2.0 * scale_value, true)
	var smile_amount := remap(clampf(float(profile_happiness), 0.0, 100.0), 0.0, 100.0, -0.22, 0.18)
	draw_arc(center + Vector2(0, 18) * scale_value, 12.0 * scale_value, PI * (0.15 - smile_amount), PI * (0.85 + smile_amount), 16, Color("8a4f55"), 2.4 * scale_value, true)
	if profile_age >= 48:
		var line_alpha := clampf(float(profile_age - 45) / 55.0, 0.12, 0.48)
		draw_line(center + Vector2(-33, 3) * scale_value, center + Vector2(-27, 9) * scale_value, Color(0.38, 0.21, 0.18, line_alpha), 1.2 * scale_value, true)
		draw_line(center + Vector2(33, 3) * scale_value, center + Vector2(27, 9) * scale_value, Color(0.38, 0.21, 0.18, line_alpha), 1.2 * scale_value, true)
	if profile_age >= 65:
		draw_line(center + Vector2(-23, -50) * scale_value, center + Vector2(-10, -45) * scale_value, Color(0.72, 0.75, 0.78, 0.7), 2.3 * scale_value, true)
		draw_line(center + Vector2(18, -48) * scale_value, center + Vector2(31, -39) * scale_value, Color(0.72, 0.75, 0.78, 0.7), 2.3 * scale_value, true)
	if profile_health < 30:
		draw_arc(center + Vector2(0, 0) * scale_value, 46.0 * scale_value, 0.0, TAU, 40, Color(0.65, 0.25, 0.32, 0.24), 3.0 * scale_value, true)


func draw_ellipse_shape(position: Vector2, radii: Vector2, color: Color) -> void:
	var points := PackedVector2Array()
	for index in range(24):
		var angle := TAU * float(index) / 24.0
		points.append(position + Vector2(cos(angle) * radii.x, sin(angle) * radii.y))
	draw_colored_polygon(points, color)
