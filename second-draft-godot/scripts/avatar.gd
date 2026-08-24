extends Control
class_name StoryAvatar

var profile_age := 0
var profile_health := 80
var profile_happiness := 75
var profile_appearance: Dictionary = {}
var elapsed := 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process(true)


func set_profile(age: int, health: int, happiness: int, appearance: Dictionary = {}) -> void:
	profile_age = age
	profile_health = health
	profile_happiness = happiness
	profile_appearance = appearance.duplicate(true)
	queue_redraw()


func _process(delta: float) -> void:
	elapsed += delta
	queue_redraw()


func _draw() -> void:
	var scale_value := minf(size.x, size.y) / 170.0
	var center := Vector2(size.x * 0.5, size.y * 0.52 + sin(elapsed * 1.5) * 1.3)
	var skin := Color(str(profile_appearance.get("skin", "d6a07d")))
	var skin_shadow := Color(str(profile_appearance.get("skin_shadow", "b9775b")))
	var hair := Color(str(profile_appearance.get("hair_color", "171922")))
	var beard := hair.darkened(0.12)
	var navy := Color(str(profile_appearance.get("outfit_color", "173a5e")))
	var teal := Color(str(profile_appearance.get("accent_color", "46c2a6")))
	var eye_color := Color(str(profile_appearance.get("eye_color", "293849")))
	var cream := Color("f7fbff")
	var face_shape := clampi(int(profile_appearance.get("face_shape", 0)), 0, 4)
	var face_radii: Vector2 = [Vector2(45, 45), Vector2(42, 48), Vector2(48, 43), Vector2(43, 46), Vector2(46, 47)][face_shape]
	var background_style := clampi(int(profile_appearance.get("background_style", 0)), 0, 5)

	draw_circle(center, 80.0 * scale_value, Color(0.08, 0.13, 0.22, 0.18))
	draw_portrait_background(center, scale_value, background_style, teal)
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
	draw_circle(center + Vector2(-face_radii.x + 4, -2) * scale_value, 12.0 * scale_value, skin_shadow)
	draw_circle(center + Vector2(face_radii.x - 4, -2) * scale_value, 12.0 * scale_value, skin_shadow)
	draw_ellipse_shape(center + Vector2(0, -8) * scale_value, face_radii * scale_value, skin)

	# Facial hair is one piece of the saved portrait DNA and develops with age.
	var beard_style := clampi(int(profile_appearance.get("beard_style", 2)), 0, 4)
	if profile_age >= 16 and beard_style > 0:
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
		if beard_style >= 3:
			draw_colored_polygon(beard_points, beard)
		elif beard_style == 2:
			draw_arc(center + Vector2(0, 17) * scale_value, 28.0 * scale_value, 0.08, PI - 0.08, 24, Color(beard, 0.84), 7.0 * scale_value, true)
		draw_arc(center + Vector2(0, 7) * scale_value, 13.0 * scale_value, PI * 1.05, PI * 1.95, 18, beard, (5.0 if beard_style != 1 else 2.4) * scale_value, true)
	elif profile_age >= 12 and beard_style > 0:
		draw_arc(center + Vector2(0, 8) * scale_value, 11.0 * scale_value, PI * 1.08, PI * 1.92, 16, Color(0.12, 0.1, 0.12, 0.38), 2.0 * scale_value, true)

	draw_hair(center, scale_value, hair, clampi(int(profile_appearance.get("hair_style", 0)), 0, 7))

	# Brows and expressive anime eyes.
	var brow_lift := float(clampi(int(profile_appearance.get("brow_style", 0)), 0, 3) - 1) * 1.5
	draw_line(center + Vector2(-29, -16 - brow_lift) * scale_value, center + Vector2(-8, -19 + brow_lift) * scale_value, hair, 4.5 * scale_value, true)
	draw_line(center + Vector2(8, -19 + brow_lift) * scale_value, center + Vector2(29, -16 - brow_lift) * scale_value, hair, 4.5 * scale_value, true)
	var blinking := fmod(elapsed, 4.6) > 4.42
	var eye_style := clampi(int(profile_appearance.get("eye_style", 0)), 0, 3)
	var eye_radii := Vector2(10 + eye_style, 6 + int(float(eye_style) / 2.0))
	if blinking:
		draw_line(center + Vector2(-28, -7) * scale_value, center + Vector2(-8, -7) * scale_value, hair, 3.0 * scale_value, true)
		draw_line(center + Vector2(8, -7) * scale_value, center + Vector2(28, -7) * scale_value, hair, 3.0 * scale_value, true)
	else:
		draw_ellipse_shape(center + Vector2(-18, -7) * scale_value, eye_radii * scale_value, cream)
		draw_ellipse_shape(center + Vector2(18, -7) * scale_value, eye_radii * scale_value, cream)
		draw_circle(center + Vector2(-16, -7) * scale_value, 5.0 * scale_value, eye_color)
		draw_circle(center + Vector2(16, -7) * scale_value, 5.0 * scale_value, eye_color)
		draw_circle(center + Vector2(-14, -9) * scale_value, 1.6 * scale_value, cream)
		draw_circle(center + Vector2(18, -9) * scale_value, 1.6 * scale_value, cream)

	# Nose, expression, and subtle aging details.
	var nose_length := 10.0 + float(clampi(int(profile_appearance.get("nose_style", 0)), 0, 3)) * 1.5
	draw_line(center + Vector2(0, -6) * scale_value, center + Vector2(-3, -6 + nose_length) * scale_value, skin_shadow, 2.0 * scale_value, true)
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
	if bool(profile_appearance.get("freckles", false)):
		for offset in [Vector2(-24, 1), Vector2(-18, 3), Vector2(-12, 1), Vector2(14, 1), Vector2(20, 3), Vector2(26, 0)]:
			draw_circle(center + offset * scale_value, 1.1 * scale_value, Color(skin_shadow, 0.72))
	if bool(profile_appearance.get("glasses", false)):
		draw_arc(center + Vector2(-18, -7) * scale_value, 13.0 * scale_value, 0.0, TAU, 24, Color("26333f"), 2.0 * scale_value, true)
		draw_arc(center + Vector2(18, -7) * scale_value, 13.0 * scale_value, 0.0, TAU, 24, Color("26333f"), 2.0 * scale_value, true)
		draw_line(center + Vector2(-5, -7) * scale_value, center + Vector2(5, -7) * scale_value, Color("26333f"), 2.0 * scale_value, true)
	if bool(profile_appearance.get("earrings", false)):
		draw_circle(center + Vector2(face_radii.x, 7) * scale_value, 2.6 * scale_value, teal)


func draw_portrait_background(center: Vector2, scale_value: float, style: int, accent: Color) -> void:
	match style:
		1:
			draw_arc(center, 67.0 * scale_value, 0.0, TAU, 48, Color(accent, 0.22), 8.0 * scale_value, true)
		2:
			for index in range(5):
				draw_line(center + Vector2(-72, -56 + index * 28) * scale_value, center + Vector2(72, -84 + index * 28) * scale_value, Color(accent, 0.13), 5.0 * scale_value, true)
		3:
			for angle_index in range(8):
				var angle := TAU * float(angle_index) / 8.0
				draw_circle(center + Vector2(cos(angle) * 65, sin(angle) * 65) * scale_value, 8.0 * scale_value, Color(accent, 0.16))
		4:
			draw_colored_polygon(PackedVector2Array([center + Vector2(-70, 54) * scale_value, center + Vector2(0, -73) * scale_value, center + Vector2(70, 54) * scale_value]), Color(accent, 0.12))
		5:
			for index in range(6):
				draw_circle(center + Vector2(-62 + index * 25, -58 + (index % 2) * 112) * scale_value, 5.0 * scale_value, Color(accent, 0.18))


func draw_hair(center: Vector2, scale_value: float, hair: Color, style: int) -> void:
	match style:
		1:
			draw_arc(center + Vector2(0, -27) * scale_value, 39.0 * scale_value, PI, TAU, 28, hair, 16.0 * scale_value, true)
		2:
			for offset in [Vector2(-35, -35), Vector2(-24, -51), Vector2(-8, -57), Vector2(10, -56), Vector2(27, -48), Vector2(39, -32)]:
				draw_circle(center + offset * scale_value, 13.0 * scale_value, hair)
		3:
			draw_ellipse_shape(center + Vector2(-36, -6) * scale_value, Vector2(13, 51) * scale_value, hair)
			draw_ellipse_shape(center + Vector2(36, -6) * scale_value, Vector2(13, 51) * scale_value, hair)
			draw_arc(center + Vector2(0, -29) * scale_value, 40.0 * scale_value, PI, TAU, 28, hair, 17.0 * scale_value, true)
		4:
			draw_arc(center + Vector2(0, -29) * scale_value, 39.0 * scale_value, PI, TAU, 28, Color(hair, 0.74), 5.0 * scale_value, true)
		5:
			draw_circle(center + Vector2(32, -54) * scale_value, 19.0 * scale_value, hair)
			draw_arc(center + Vector2(0, -28) * scale_value, 40.0 * scale_value, PI, TAU, 28, hair, 15.0 * scale_value, true)
		6:
			var mohawk_points := PackedVector2Array([center + Vector2(-18, -44) * scale_value, center + Vector2(-8, -71) * scale_value, center + Vector2(0, -45) * scale_value, center + Vector2(9, -74) * scale_value, center + Vector2(20, -42) * scale_value])
			draw_colored_polygon(mohawk_points, hair)
		7:
			for x_position in [-31, -20, -9, 3, 15, 27]:
				draw_line(center + Vector2(x_position, -50) * scale_value, center + Vector2(x_position + 4, -21) * scale_value, hair, 7.0 * scale_value, true)
		_:
			var swept_points := PackedVector2Array([center + Vector2(-44, -18) * scale_value, center + Vector2(-40, -42) * scale_value, center + Vector2(-25, -58) * scale_value, center + Vector2(-4, -62) * scale_value, center + Vector2(19, -56) * scale_value, center + Vector2(40, -42) * scale_value, center + Vector2(46, -18) * scale_value, center + Vector2(32, -30) * scale_value, center + Vector2(20, -43) * scale_value, center + Vector2(10, -25) * scale_value, center + Vector2(-2, -43) * scale_value, center + Vector2(-18, -29) * scale_value, center + Vector2(-32, -24) * scale_value])
			draw_colored_polygon(swept_points, hair)


func draw_ellipse_shape(position: Vector2, radii: Vector2, color: Color) -> void:
	var points := PackedVector2Array()
	for index in range(24):
		var angle := TAU * float(index) / 24.0
		points.append(position + Vector2(cos(angle) * radii.x, sin(angle) * radii.y))
	draw_colored_polygon(points, color)
