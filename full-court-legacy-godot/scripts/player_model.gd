extends Node3D

var _visual_root: Node3D
var _torso_root: Node3D
var _head_root: Node3D
var _left_shoulder: Node3D
var _right_shoulder: Node3D
var _left_elbow: Node3D
var _right_elbow: Node3D
var _left_hip: Node3D
var _right_hip: Node3D
var _left_knee: Node3D
var _right_knee: Node3D
var _left_hand: Node3D
var _right_hand: Node3D

var _phase := 0.0
var _motion_blend := 0.0
var _action := ""
var _action_time := 0.0
var _action_duration := 0.0
var _action_side := 1
var _is_defender := false

var _cadence_scale := 1.0
var _stride_scale := 1.0
var _bob_scale := 1.0
var _arm_swing_scale := 1.0
var _release_height := 1.0
var _release_speed := 1.0
var _jump_scale := 1.0
var _follow_through := 1.0
var _dribble_reach := 1.0
var _crossover_lean := 1.0
var _handle_speed := 1.0
var _pose_response := 1.0
var _stance_scale := 1.0

var _skin_material: StandardMaterial3D
var _hair_material: StandardMaterial3D
var _beard_material: StandardMaterial3D
var _eye_white_material: StandardMaterial3D
var _iris_material: StandardMaterial3D
var _brow_material: StandardMaterial3D
var _lip_material: StandardMaterial3D
var _shoe_material: StandardMaterial3D
var _sole_material: StandardMaterial3D

func build(jersey_material: Material, trim_material: Material, career_player: bool, jersey_number: int) -> void:
	_is_defender = not career_player
	_skin_material = _material(Color("#B97861"), 0.63)
	_hair_material = _material(Color("#171417"), 0.82)
	_beard_material = _material(Color("#241A19"), 0.9)
	_eye_white_material = _material(Color("#E7E5E0"), 0.52)
	_iris_material = _material(Color("#252522"), 0.38)
	_brow_material = _material(Color("#21191A"), 0.88)
	_lip_material = _material(Color("#985F62"), 0.58)
	_shoe_material = _material(Color("#E8F5FA"), 0.4)
	_sole_material = _material(Color("#101820"), 0.72)
	_configure_pbr_materials()

	_visual_root = Node3D.new()
	_visual_root.name = "AnimatedVisualRig"
	add_child(_visual_root)
	_build_body(jersey_material, trim_material, career_player, jersey_number)
	_build_head(career_player)
	_build_arms(jersey_material)
	_build_legs(trim_material)

func set_animation_profile(profile: Dictionary) -> void:
	_cadence_scale = float(profile.get("cadence_scale", 1.0))
	_stride_scale = float(profile.get("stride_scale", 1.0))
	_bob_scale = float(profile.get("bob_scale", 1.0))
	_arm_swing_scale = float(profile.get("arm_swing_scale", 1.0))
	_release_height = float(profile.get("release_height", 1.0))
	_release_speed = float(profile.get("release_speed", 1.0))
	_jump_scale = float(profile.get("jump_scale", 1.0))
	_follow_through = float(profile.get("follow_through", 1.0))
	_dribble_reach = float(profile.get("dribble_reach", 1.0))
	_crossover_lean = float(profile.get("crossover_lean", 1.0))
	_handle_speed = float(profile.get("handle_speed", 1.0))
	_pose_response = float(profile.get("pose_response", 1.0))
	_stance_scale = float(profile.get("stance_scale", 1.0))

func update_player_animation(delta: float, movement_amount: float, sprinting: bool, has_ball: bool, charging: bool, shot_progress: float, dribble_side: int) -> void:
	if _visual_root == null:
		return
	_advance_action(delta)
	var target_blend := clampf(movement_amount, 0.0, 1.0)
	_motion_blend = lerpf(_motion_blend, target_blend, 1.0 - exp(-delta * 9.0))
	var cadence := lerpf(2.2, 9.5 if sprinting else 6.2, _motion_blend) * _cadence_scale
	_phase += delta * cadence
	var stride_amount := (0.72 if sprinting else 0.48) * _motion_blend * _stride_scale
	var stride := sin(_phase) * stride_amount
	var bob := absf(sin(_phase * 2.0)) * (0.035 if sprinting else 0.022) * _motion_blend * _bob_scale
	var breathing := sin(Time.get_ticks_msec() / 1000.0 * 2.1) * 0.008

	var left_hip_target := Vector3(stride, 0.0, 0.0)
	var right_hip_target := Vector3(-stride, 0.0, 0.0)
	var left_knee_target := Vector3(maxf(0.0, -stride) * 0.62, 0.0, 0.0)
	var right_knee_target := Vector3(maxf(0.0, stride) * 0.62, 0.0, 0.0)
	var left_shoulder_target := Vector3(-stride * 0.72 * _arm_swing_scale, 0.0, -0.08)
	var right_shoulder_target := Vector3(stride * 0.72 * _arm_swing_scale, 0.0, 0.08)
	var left_elbow_target := Vector3(0.16 + absf(stride) * 0.18, 0.0, 0.0)
	var right_elbow_target := Vector3(0.16 + absf(stride) * 0.18, 0.0, 0.0)
	var torso_target := Vector3(0.0, sin(_phase) * 0.055 * _motion_blend, sin(_phase) * 0.018 * _motion_blend)
	var head_target := Vector3(-sin(_phase) * 0.018 * _motion_blend, -torso_target.y * 0.35, 0.0)
	var root_offset := Vector3(0.0, bob + breathing, 0.0)

	if has_ball and not charging:
		var ball_arm := (0.48 + absf(sin(_phase * 1.35 * _handle_speed)) * 0.16) * _dribble_reach
		if dribble_side > 0:
			right_shoulder_target.x = ball_arm
			right_shoulder_target.z = 0.14
			right_elbow_target.x = 0.42
		else:
			left_shoulder_target.x = ball_arm
			left_shoulder_target.z = -0.14
			left_elbow_target.x = 0.42
		torso_target.y += -0.07 * dribble_side

	if charging:
		var charge := clampf(shot_progress, 0.0, 1.0)
		var crouch := sin(charge * PI * 0.78)
		left_shoulder_target = Vector3(1.72 + charge * 0.28, 0.0, -0.2)
		right_shoulder_target = Vector3(1.72 + charge * 0.28, 0.0, 0.2)
		left_elbow_target = Vector3(-0.62 + charge * 0.2, 0.0, 0.0)
		right_elbow_target = Vector3(-0.62 + charge * 0.2, 0.0, 0.0)
		left_hip_target.x = 0.22 * crouch
		right_hip_target.x = 0.22 * crouch
		left_knee_target.x = -0.38 * crouch
		right_knee_target.x = -0.38 * crouch
		root_offset.y -= 0.09 * crouch
		torso_target.x = -0.08 * crouch

	if _action == "crossover":
		var progress := clampf(_action_time / maxf(_action_duration, 0.001), 0.0, 1.0)
		var pulse := sin(progress * PI)
		root_offset.x = -_action_side * pulse * 0.1 * _crossover_lean
		torso_target.z = -_action_side * pulse * 0.2 * _crossover_lean
		torso_target.y = _action_side * pulse * 0.16 * _crossover_lean
		left_hip_target.x += pulse * 0.24
		right_hip_target.x += pulse * 0.24
		if _action_side > 0:
			right_shoulder_target = Vector3(0.8, -0.18, 0.58 * pulse)
			right_elbow_target.x = 0.56
		else:
			left_shoulder_target = Vector3(0.8, 0.18, -0.58 * pulse)
			left_elbow_target.x = 0.56
	elif _action == "shot":
		var progress := clampf(_action_time / maxf(_action_duration, 0.001), 0.0, 1.0)
		var jump := sin(progress * PI)
		root_offset.y += jump * 0.19 * _jump_scale
		left_shoulder_target = Vector3(2.54 + 0.18 * _release_height, 0.0, -0.12 * _follow_through)
		right_shoulder_target = Vector3(2.58 + 0.18 * _release_height, 0.0, 0.12 * _follow_through)
		left_elbow_target = Vector3(-0.08, 0.0, 0.0)
		right_elbow_target = Vector3(0.06 + progress * 0.2 * _follow_through, 0.0, 0.0)
		torso_target.x = -0.1 * jump
		head_target.x = 0.08

	_apply_pose(delta, root_offset, torso_target, head_target, left_shoulder_target, right_shoulder_target, left_elbow_target, right_elbow_target, left_hip_target, right_hip_target, left_knee_target, right_knee_target)

func update_defender_animation(delta: float, movement_amount: float) -> void:
	if _visual_root == null:
		return
	_motion_blend = lerpf(_motion_blend, clampf(movement_amount, 0.0, 1.0), 1.0 - exp(-delta * 8.0))
	_phase += delta * lerpf(2.0, 7.4, _motion_blend)
	var shuffle := sin(_phase) * 0.26 * _motion_blend
	var root_offset := Vector3(0.0, -0.07 + absf(sin(_phase * 2.0)) * 0.018, 0.0)
	var torso_target := Vector3(-0.08, sin(_phase) * 0.035, 0.0)
	var head_target := Vector3(0.06, -torso_target.y * 0.4, 0.0)
	var left_shoulder_target := Vector3(0.28, 0.0, -1.05)
	var right_shoulder_target := Vector3(0.28, 0.0, 1.05)
	var left_elbow_target := Vector3(-0.12, 0.0, 0.0)
	var right_elbow_target := Vector3(-0.12, 0.0, 0.0)
	var left_hip_target := Vector3(0.14 + shuffle, 0.0, -0.08)
	var right_hip_target := Vector3(0.14 - shuffle, 0.0, 0.08)
	var left_knee_target := Vector3(-0.28, 0.0, 0.0)
	var right_knee_target := Vector3(-0.28, 0.0, 0.0)
	_apply_pose(delta, root_offset, torso_target, head_target, left_shoulder_target, right_shoulder_target, left_elbow_target, right_elbow_target, left_hip_target, right_hip_target, left_knee_target, right_knee_target)

func play_crossover(side: int) -> void:
	_action = "crossover"
	_action_time = 0.0
	_action_duration = 0.42
	_action_side = side

func play_shot_release() -> void:
	_action = "shot"
	_action_time = 0.0
	_action_duration = 0.58 / maxf(_release_speed, 0.5)

func get_hand_position(side: int) -> Vector3:
	var hand := _right_hand if side > 0 else _left_hand
	return hand.global_position if hand != null else global_position + Vector3.UP

func _advance_action(delta: float) -> void:
	if _action.is_empty():
		return
	_action_time += delta
	if _action_time >= _action_duration:
		_action = ""
		_action_time = 0.0

func _apply_pose(delta: float, root_offset: Vector3, torso_target: Vector3, head_target: Vector3, left_shoulder_target: Vector3, right_shoulder_target: Vector3, left_elbow_target: Vector3, right_elbow_target: Vector3, left_hip_target: Vector3, right_hip_target: Vector3, left_knee_target: Vector3, right_knee_target: Vector3) -> void:
	var weight := 1.0 - exp(-delta * 14.0 * _pose_response)
	_visual_root.position = _visual_root.position.lerp(root_offset, weight)
	_lerp_rotation(_torso_root, torso_target, weight)
	_lerp_rotation(_head_root, head_target, weight)
	_lerp_rotation(_left_shoulder, left_shoulder_target, weight)
	_lerp_rotation(_right_shoulder, right_shoulder_target, weight)
	_lerp_rotation(_left_elbow, left_elbow_target, weight)
	_lerp_rotation(_right_elbow, right_elbow_target, weight)
	_lerp_rotation(_left_hip, left_hip_target, weight)
	_lerp_rotation(_right_hip, right_hip_target, weight)
	_lerp_rotation(_left_knee, left_knee_target, weight)
	_lerp_rotation(_right_knee, right_knee_target, weight)

func _lerp_rotation(node: Node3D, target: Vector3, weight: float) -> void:
	if node == null:
		return
	node.rotation = Vector3(
		lerp_angle(node.rotation.x, target.x, weight),
		lerp_angle(node.rotation.y, target.y, weight),
		lerp_angle(node.rotation.z, target.z, weight)
	)

func _build_body(jersey_material: Material, trim_material: Material, career_player: bool, jersey_number: int) -> void:
	_torso_root = _pivot(_visual_root, "TorsoRoot", Vector3.ZERO)
	_mesh_capsule(_torso_root, "AthleticJersey", Vector3(0.0, 1.32, 0.0), 0.36, 0.88, jersey_material, Vector3(1.2, 1.0, 0.76))
	_mesh_box(_torso_root, "JerseyWaist", Vector3(0.0, 0.98, 0.0), Vector3(0.7, 0.22, 0.43), jersey_material)
	_mesh_box(_torso_root, "SideStripeLeft", Vector3(-0.36, 1.18, 0.0), Vector3(0.055, 0.56, 0.35), trim_material)
	_mesh_box(_torso_root, "SideStripeRight", Vector3(0.36, 1.18, 0.0), Vector3(0.055, 0.56, 0.35), trim_material)
	_mesh_box(_torso_root, "Shorts", Vector3(0.0, 0.8, 0.0), Vector3(0.66, 0.34, 0.46), trim_material)
	_mesh_box(_torso_root, "Waistband", Vector3(0.0, 0.94, 0.0), Vector3(0.69, 0.075, 0.47), jersey_material)

	if career_player:
		var name_label := Label3D.new()
		name_label.name = "AustinNameplate"
		name_label.text = "AUSTIN"
		name_label.font_size = 54
		name_label.pixel_size = 0.0026
		name_label.outline_size = 8
		name_label.modulate = Color("#E4F5FF")
		name_label.position = Vector3(0.0, 1.53, 0.303)
		name_label.rotation.y = PI
		_torso_root.add_child(name_label)

		var number := Label3D.new()
		number.name = "CareerNumber"
		number.text = str(jersey_number)
		number.font_size = 102
		number.pixel_size = 0.0032
		number.outline_size = 9
		number.modulate = Color("#E4F5FF")
		number.position = Vector3(0.0, 1.3, 0.31)
		number.rotation.y = PI
		_torso_root.add_child(number)

func _build_head(career_player: bool) -> void:
	_head_root = _pivot(_torso_root, "HeadRoot", Vector3(0.0, 1.98, 0.0))
	_mesh_sphere(_head_root, "Head", Vector3.ZERO, 0.25, 0.5, _skin_material, Vector3(0.96, 1.02, 0.92))
	_mesh_sphere(_head_root, "LeftEar", Vector3(-0.242, -0.015, 0.0), 0.07, 0.14, _skin_material, Vector3(0.55, 1.0, 0.75))
	_mesh_sphere(_head_root, "RightEar", Vector3(0.242, -0.015, 0.0), 0.07, 0.14, _skin_material, Vector3(0.55, 1.0, 0.75))

	if not career_player:
		_mesh_sphere(_head_root, "DefenderHair", Vector3(0.0, 0.19, 0.02), 0.245, 0.22, _hair_material, Vector3(1.01, 0.72, 1.01))
		return

	# Austin-inspired face: oval head, prominent straight nose, thick brows,
	# swept medium dark hair, moustache, and a full jaw/chin beard.
	_mesh_sphere(_head_root, "NoseBridge", Vector3(0.0, 0.015, -0.235), 0.075, 0.19, _skin_material, Vector3(0.75, 1.0, 0.72))
	_mesh_sphere(_head_root, "NoseTip", Vector3(0.0, -0.035, -0.286), 0.068, 0.09, _skin_material, Vector3(1.0, 0.62, 0.82))
	for side in [-1.0, 1.0]:
		_mesh_sphere(_head_root, "EyeWhite", Vector3(0.092 * side, 0.045, -0.223), 0.05, 0.054, _eye_white_material, Vector3(1.28, 0.74, 0.56))
		_mesh_sphere(_head_root, "Iris", Vector3(0.092 * side, 0.045, -0.254), 0.021, 0.027, _iris_material, Vector3(1.0, 1.0, 0.48))
		var brow := _mesh_box(_head_root, "ThickBrow", Vector3(0.095 * side, 0.12, -0.232), Vector3(0.145, 0.032, 0.024), _brow_material)
		brow.rotation.z = deg_to_rad(-7.0 * side)
		_mesh_sphere(_head_root, "JawBeard", Vector3(0.145 * side, -0.125, -0.105), 0.13, 0.28, _beard_material, Vector3(0.9, 1.08, 0.72))
		_mesh_box(_head_root, "Sideburn", Vector3(0.205 * side, 0.015, -0.035), Vector3(0.055, 0.2, 0.12), _beard_material)
	_mesh_box(_head_root, "UpperLip", Vector3(0.0, -0.092, -0.249), Vector3(0.17, 0.035, 0.026), _lip_material)
	_mesh_box(_head_root, "LowerLip", Vector3(0.0, -0.13, -0.242), Vector3(0.16, 0.038, 0.025), _lip_material)
	_mesh_capsule(_head_root, "Moustache", Vector3(0.0, -0.068, -0.263), 0.026, 0.17, _beard_material, Vector3(1.0, 1.0, 0.42), Vector3(0.0, 0.0, PI * 0.5))
	_mesh_sphere(_head_root, "ChinBeard", Vector3(0.0, -0.235, -0.075), 0.18, 0.25, _beard_material, Vector3(1.08, 1.1, 0.78))
	_mesh_sphere(_head_root, "UnderChinBeard", Vector3(0.0, -0.27, 0.02), 0.17, 0.18, _beard_material, Vector3(1.0, 0.75, 0.9))

	_mesh_sphere(_head_root, "HairCap", Vector3(0.0, 0.18, 0.035), 0.255, 0.25, _hair_material, Vector3(1.03, 0.82, 1.03))
	_mesh_sphere(_head_root, "HairBack", Vector3(0.0, 0.06, 0.205), 0.21, 0.36, _hair_material, Vector3(1.0, 1.12, 0.64))
	_mesh_sphere(_head_root, "HairLeftSweep", Vector3(-0.115, 0.205, -0.075), 0.15, 0.3, _hair_material, Vector3(0.9, 0.65, 0.72), Vector3(0.25, 0.0, -0.42))
	_mesh_sphere(_head_root, "HairCentreSweep", Vector3(0.0, 0.235, -0.105), 0.15, 0.32, _hair_material, Vector3(0.86, 0.62, 0.68), Vector3(0.3, 0.0, -0.24))
	_mesh_sphere(_head_root, "HairRightSweep", Vector3(0.12, 0.205, -0.055), 0.14, 0.28, _hair_material, Vector3(0.92, 0.66, 0.74), Vector3(0.18, 0.0, 0.24))
	_mesh_sphere(_head_root, "LongBackHair", Vector3(0.0, -0.025, 0.22), 0.18, 0.31, _hair_material, Vector3(1.02, 1.0, 0.58))

func _build_arms(jersey_material: Material) -> void:
	_left_shoulder = _pivot(_torso_root, "LeftShoulder", Vector3(-0.43, 1.55, 0.0))
	_right_shoulder = _pivot(_torso_root, "RightShoulder", Vector3(0.43, 1.55, 0.0))
	_build_arm(_left_shoulder, true, jersey_material)
	_build_arm(_right_shoulder, false, jersey_material)

func _build_arm(shoulder: Node3D, left_side: bool, jersey_material: Material) -> void:
	_mesh_capsule(shoulder, "UpperArm", Vector3(0.0, -0.245, 0.0), 0.105, 0.54, _skin_material)
	_mesh_capsule(shoulder, "JerseySleeve", Vector3(0.0, -0.085, 0.0), 0.135, 0.25, jersey_material, Vector3(1.0, 1.0, 0.88))
	var elbow := _pivot(shoulder, "Elbow", Vector3(0.0, -0.49, 0.0))
	_mesh_capsule(elbow, "Forearm", Vector3(0.0, -0.215, 0.0), 0.09, 0.48, _skin_material)
	var hand := _pivot(elbow, "HandAnchor", Vector3(0.0, -0.44, 0.0))
	_mesh_sphere(hand, "Hand", Vector3.ZERO, 0.105, 0.2, _skin_material, Vector3(0.82, 1.0, 0.72))
	if left_side:
		_left_elbow = elbow
		_left_hand = hand
	else:
		_right_elbow = elbow
		_right_hand = hand

func _build_legs(trim_material: Material) -> void:
	_left_hip = _pivot(_visual_root, "LeftHip", Vector3(-0.19, 0.82, 0.0))
	_right_hip = _pivot(_visual_root, "RightHip", Vector3(0.19, 0.82, 0.0))
	_build_leg(_left_hip, true, trim_material)
	_build_leg(_right_hip, false, trim_material)

func _build_leg(hip: Node3D, left_side: bool, trim_material: Material) -> void:
	_mesh_capsule(hip, "UpperLeg", Vector3(0.0, -0.255, 0.0), 0.145, 0.58, _skin_material, Vector3(1.0, 1.0, 0.88))
	_mesh_box(hip, "ShortLeg", Vector3(0.0, -0.08, 0.0), Vector3(0.3, 0.28, 0.42), trim_material)
	var knee := _pivot(hip, "Knee", Vector3(0.0, -0.52, 0.0))
	_mesh_capsule(knee, "LowerLeg", Vector3(0.0, -0.245, 0.0), 0.12, 0.55, _skin_material, Vector3(1.0, 1.0, 0.88))
	_mesh_box(knee, "Sock", Vector3(0.0, -0.43, -0.005), Vector3(0.2, 0.18, 0.22), _shoe_material)
	_mesh_box(knee, "Shoe", Vector3(0.0, -0.535, -0.07), Vector3(0.25, 0.16, 0.42), _shoe_material)
	_mesh_box(knee, "Sole", Vector3(0.0, -0.62, -0.075), Vector3(0.255, 0.045, 0.43), _sole_material)
	if left_side:
		_left_knee = knee
	else:
		_right_knee = knee

func _pivot(parent: Node3D, pivot_name: String, position: Vector3) -> Node3D:
	var pivot := Node3D.new()
	pivot.name = pivot_name
	pivot.position = position
	parent.add_child(pivot)
	return pivot

func _mesh_capsule(parent: Node3D, mesh_name: String, position: Vector3, radius: float, height: float, material: Material, scale := Vector3.ONE, rotation := Vector3.ZERO) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.name = mesh_name
	var mesh := CapsuleMesh.new()
	mesh.radius = radius
	mesh.height = maxf(height, radius * 2.0)
	mesh.radial_segments = 16
	mesh.rings = 6
	instance.mesh = mesh
	instance.material_override = material
	instance.position = position
	instance.scale = scale
	instance.rotation = rotation
	parent.add_child(instance)
	return instance

func _mesh_sphere(parent: Node3D, mesh_name: String, position: Vector3, radius: float, height: float, material: Material, scale := Vector3.ONE, rotation := Vector3.ZERO) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.name = mesh_name
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = maxf(height, radius * 2.0)
	mesh.radial_segments = 18
	mesh.rings = 10
	instance.mesh = mesh
	instance.material_override = material
	instance.position = position
	instance.scale = scale
	instance.rotation = rotation
	parent.add_child(instance)
	return instance

func _mesh_box(parent: Node3D, mesh_name: String, position: Vector3, size: Vector3, material: Material) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.name = mesh_name
	var mesh := BoxMesh.new()
	mesh.size = size
	instance.mesh = mesh
	instance.material_override = material
	instance.position = position
	parent.add_child(instance)
	return instance

func _material(color: Color, roughness: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = roughness
	return material

func _configure_pbr_materials() -> void:
	_skin_material.subsurf_scatter_enabled = true
	_skin_material.subsurf_scatter_skin_mode = true
	_skin_material.subsurf_scatter_strength = 0.16
	_skin_material.backlight_enabled = true
	_skin_material.backlight = Color(0.16, 0.045, 0.025, 1.0)
	_skin_material.rim_enabled = true
	_skin_material.rim = 0.18
	_hair_material.anisotropy_enabled = true
	_hair_material.anisotropy = 0.5
	_beard_material.anisotropy_enabled = true
	_beard_material.anisotropy = 0.32
	_eye_white_material.clearcoat_enabled = true
	_eye_white_material.clearcoat = 0.72
	_eye_white_material.clearcoat_roughness = 0.18
	_iris_material.clearcoat_enabled = true
	_iris_material.clearcoat = 0.86
	_iris_material.clearcoat_roughness = 0.08
	_lip_material.clearcoat_enabled = true
	_lip_material.clearcoat = 0.28
	_lip_material.clearcoat_roughness = 0.42
	_shoe_material.clearcoat_enabled = true
	_shoe_material.clearcoat = 0.48
	_shoe_material.clearcoat_roughness = 0.32
