extends Node3D

## Smooth, mobile-friendly sports-anime character with authored AnimationPlayer clips.
## The public API deliberately matches the original procedural player model so the
## career, ball-possession, defender, and Motion Studio systems remain compatible.

const AUTHORED_CLIPS := PackedStringArray([
	"idle",
	"walk",
	"sprint",
	"dribble_left",
	"dribble_right",
	"crossover_left",
	"crossover_right",
	"shot_gather",
	"shot_release",
	"defense_idle",
	"defense_shuffle"
])

const ROOT_POSITION := "AnimatedVisualRig:position"
const TORSO_ROTATION := "AnimatedVisualRig/TorsoRoot:rotation"
const HEAD_ROTATION := "AnimatedVisualRig/TorsoRoot/HeadRoot:rotation"
const LEFT_SHOULDER_ROTATION := "AnimatedVisualRig/TorsoRoot/LeftShoulder:rotation"
const RIGHT_SHOULDER_ROTATION := "AnimatedVisualRig/TorsoRoot/RightShoulder:rotation"
const LEFT_ELBOW_ROTATION := "AnimatedVisualRig/TorsoRoot/LeftShoulder/Elbow:rotation"
const RIGHT_ELBOW_ROTATION := "AnimatedVisualRig/TorsoRoot/RightShoulder/Elbow:rotation"
const LEFT_HIP_ROTATION := "AnimatedVisualRig/LeftHip:rotation"
const RIGHT_HIP_ROTATION := "AnimatedVisualRig/RightHip:rotation"
const LEFT_KNEE_ROTATION := "AnimatedVisualRig/LeftHip/Knee:rotation"
const RIGHT_KNEE_ROTATION := "AnimatedVisualRig/RightHip/Knee:rotation"

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
var _animation_player: AnimationPlayer
var _animation_library: AnimationLibrary

var _current_clip := ""
var _action := ""
var _action_time := 0.0
var _action_duration := 0.0
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
var _jersey_material: StandardMaterial3D
var _trim_material: StandardMaterial3D
var _outline_material: StandardMaterial3D


func build(jersey_source: Material, trim_source: Material, career_player: bool, jersey_number: int) -> void:
	_is_defender = not career_player
	_outline_material = _make_outline_material()
	_skin_material = _toon_material(Color("#C88770"), 0.68, 0.18)
	_hair_material = _toon_material(Color("#171A22"), 0.82, 0.32)
	_beard_material = _toon_material(Color("#272027"), 0.88, 0.25)
	_eye_white_material = _toon_material(Color("#F4F4F1"), 0.3, 0.42)
	_iris_material = _toon_material(Color("#25384B"), 0.25, 0.5)
	_brow_material = _toon_material(Color("#211B22"), 0.9, 0.2)
	_lip_material = _toon_material(Color("#A35F68"), 0.62, 0.2)
	_shoe_material = _toon_material(Color("#F4F8FC"), 0.42, 0.3)
	_sole_material = _toon_material(Color("#101A28"), 0.7, 0.18)
	_jersey_material = _toon_material(_source_color(jersey_source, Color("#0B74BB")), 0.64, 0.24)
	_trim_material = _toon_material(_source_color(trim_source, Color("#061735")), 0.6, 0.28)

	_visual_root = Node3D.new()
	_visual_root.name = "AnimatedVisualRig"
	add_child(_visual_root)
	_build_body(career_player, jersey_number)
	_build_head(career_player)
	_build_arms()
	_build_legs()
	_build_animation_player()
	_rebuild_authored_animations()
	_play_base_clip("defense_idle" if _is_defender else "idle", 0.0, 1.0)


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
	if _animation_player != null:
		_rebuild_authored_animations()
		_current_clip = ""


func update_player_animation(delta: float, movement_amount: float, sprinting: bool, has_ball: bool, charging: bool, shot_progress: float, dribble_side: int) -> void:
	if _animation_player == null:
		return
	if _advance_action(delta):
		return
	if charging:
		if _current_clip != "shot_gather":
			_animation_player.play("shot_gather", 0.12, 1.0)
			_current_clip = "shot_gather"
		_animation_player.seek(clampf(shot_progress, 0.0, 1.0) * _animation_length("shot_gather"), true)
		_animation_player.pause()
		return

	var amount := clampf(movement_amount, 0.0, 1.0)
	var clip := "idle"
	var speed := lerpf(0.92, 1.12, amount) * _cadence_scale
	if has_ball:
		clip = "dribble_right" if dribble_side > 0 else "dribble_left"
		speed = lerpf(0.82, 1.28 if sprinting else 1.05, amount) * _handle_speed * _cadence_scale
	elif amount > 0.12:
		clip = "sprint" if sprinting else "walk"
		speed = lerpf(0.82, 1.2, amount) * _cadence_scale
	_play_base_clip(clip, 0.16 / maxf(_pose_response, 0.5), speed)


func update_defender_animation(delta: float, movement_amount: float) -> void:
	if _animation_player == null:
		return
	if _advance_action(delta):
		return
	var amount := clampf(movement_amount, 0.0, 1.0)
	var clip := "defense_shuffle" if amount > 0.12 else "defense_idle"
	var speed := lerpf(0.86, 1.28, amount) * _cadence_scale
	_play_base_clip(clip, 0.14 / maxf(_pose_response, 0.5), speed)


func play_crossover(side: int) -> void:
	if _animation_player == null:
		return
	_action = "crossover"
	_action_time = 0.0
	_action_duration = 0.46 / maxf(_handle_speed, 0.5)
	_current_clip = "crossover_right" if side > 0 else "crossover_left"
	_animation_player.play(_current_clip, 0.07, _handle_speed)


func play_shot_release() -> void:
	if _animation_player == null:
		return
	_action = "shot"
	_action_time = 0.0
	_action_duration = 0.64 / maxf(_release_speed, 0.5)
	_current_clip = "shot_release"
	_animation_player.play("shot_release", 0.06, _release_speed)


func get_hand_position(side: int) -> Vector3:
	var hand := _right_hand if side > 0 else _left_hand
	return hand.global_position if hand != null else global_position + Vector3.UP


func get_authored_animation_names() -> PackedStringArray:
	return AUTHORED_CLIPS.duplicate()


func get_animation_player() -> AnimationPlayer:
	return _animation_player


func _advance_action(delta: float) -> bool:
	if _action.is_empty():
		return false
	_action_time += delta
	if _action_time < _action_duration:
		return true
	_action = ""
	_action_time = 0.0
	_current_clip = ""
	return false


func _play_base_clip(clip: String, blend_time: float, speed: float) -> void:
	if _current_clip == clip and _animation_player.is_playing():
		_animation_player.speed_scale = speed
		return
	_current_clip = clip
	_animation_player.play(clip, blend_time, speed)


func _animation_length(clip: String) -> float:
	if _animation_library == null or not _animation_library.has_animation(clip):
		return 1.0
	return _animation_library.get_animation(clip).length


func _build_body(career_player: bool, jersey_number: int) -> void:
	_torso_root = _pivot(_visual_root, "TorsoRoot", Vector3.ZERO)
	_mesh_capsule(_torso_root, "SmoothJerseyTorso", Vector3(0.0, 1.38, 0.0), 0.36, 0.94, _jersey_material, Vector3(1.18, 1.0, 0.74))
	_mesh_cylinder(_torso_root, "TaperedJerseyWaist", Vector3(0.0, 1.02, 0.0), 0.31, 0.36, 0.28, _jersey_material, Vector3(1.0, 1.0, 0.76))
	_mesh_cylinder(_torso_root, "RoundedWaistband", Vector3(0.0, 0.91, 0.0), 0.36, 0.36, 0.1, _trim_material, Vector3(1.0, 1.0, 0.78))
	_mesh_capsule(_torso_root, "LeftJerseyStripe", Vector3(-0.37, 1.26, 0.0), 0.025, 0.58, _trim_material, Vector3(1.0, 1.0, 0.74))
	_mesh_capsule(_torso_root, "RightJerseyStripe", Vector3(0.37, 1.26, 0.0), 0.025, 0.58, _trim_material, Vector3(1.0, 1.0, 0.74))
	_mesh_cylinder(_torso_root, "LeftShortsPanel", Vector3(-0.18, 0.79, 0.0), 0.18, 0.22, 0.36, _trim_material, Vector3(1.0, 1.0, 1.22))
	_mesh_cylinder(_torso_root, "RightShortsPanel", Vector3(0.18, 0.79, 0.0), 0.18, 0.22, 0.36, _trim_material, Vector3(1.0, 1.0, 1.22))
	_mesh_capsule(_torso_root, "LeftShortStripe", Vector3(-0.37, 0.78, -0.005), 0.022, 0.3, _jersey_material)
	_mesh_capsule(_torso_root, "RightShortStripe", Vector3(0.37, 0.78, -0.005), 0.022, 0.3, _jersey_material)

	var chest_wordmark := Label3D.new()
	chest_wordmark.name = "LakeshoreChestWordmark"
	chest_wordmark.text = "LAKESHORE\nRAPTORS"
	chest_wordmark.font_size = 38
	chest_wordmark.pixel_size = 0.0018
	chest_wordmark.outline_size = 8
	chest_wordmark.modulate = Color("#F7F9FC")
	chest_wordmark.position = Vector3(0.0, 1.5, -0.285)
	_torso_root.add_child(chest_wordmark)

	var front_number := Label3D.new()
	front_number.name = "FrontJerseyNumber"
	front_number.text = str(jersey_number if career_player else 23)
	front_number.font_size = 92
	front_number.pixel_size = 0.0025
	front_number.outline_size = 8
	front_number.modulate = Color("#F7F9FC")
	front_number.position = Vector3(0.0, 1.2, -0.294)
	_torso_root.add_child(front_number)

	var back_number := Label3D.new()
	back_number.name = "BackJerseyNumber"
	back_number.text = str(jersey_number if career_player else 23)
	back_number.font_size = 100
	back_number.pixel_size = 0.0027
	back_number.outline_size = 8
	back_number.modulate = Color("#F7F9FC")
	back_number.position = Vector3(0.0, 1.32, 0.295)
	back_number.rotation.y = PI
	_torso_root.add_child(back_number)

	if career_player:
		var nameplate := Label3D.new()
		nameplate.name = "AustinNameplate"
		nameplate.text = "AUSTIN"
		nameplate.font_size = 48
		nameplate.pixel_size = 0.0022
		nameplate.outline_size = 7
		nameplate.modulate = Color("#F7F9FC")
		nameplate.position = Vector3(0.0, 1.58, 0.298)
		nameplate.rotation.y = PI
		_torso_root.add_child(nameplate)


func _build_head(career_player: bool) -> void:
	_head_root = _pivot(_torso_root, "HeadRoot", Vector3(0.0, 2.0, 0.0))
	_mesh_sphere(_head_root, "AnimeHead", Vector3(0.0, 0.0, 0.0), 0.27, 0.52, _skin_material, Vector3(0.94, 1.04, 0.9))
	_mesh_sphere(_head_root, "LeftEar", Vector3(-0.245, -0.005, 0.005), 0.072, 0.14, _skin_material, Vector3(0.58, 1.0, 0.78))
	_mesh_sphere(_head_root, "RightEar", Vector3(0.245, -0.005, 0.005), 0.072, 0.14, _skin_material, Vector3(0.58, 1.0, 0.78))

	if not career_player:
		_mesh_sphere(_head_root, "DefenderHairCap", Vector3(0.0, 0.185, 0.02), 0.255, 0.24, _hair_material, Vector3(1.01, 0.76, 1.01))
		for side in [-1.0, 1.0]:
			_build_anime_eye(side)
		return

	_mesh_capsule(_head_root, "NoseBridge", Vector3(0.0, 0.015, -0.242), 0.035, 0.15, _skin_material, Vector3(0.82, 1.0, 0.68), Vector3(deg_to_rad(12.0), 0.0, 0.0))
	_mesh_sphere(_head_root, "NoseTip", Vector3(0.0, -0.045, -0.279), 0.062, 0.08, _skin_material, Vector3(1.0, 0.66, 0.82))
	for side in [-1.0, 1.0]:
		_build_anime_eye(side)
		var brow := _mesh_capsule(_head_root, "ExpressiveBrow", Vector3(0.098 * side, 0.132, -0.228), 0.018, 0.145, _brow_material, Vector3(1.0, 1.0, 0.7), Vector3(0.0, 0.0, deg_to_rad(82.0 - side * 5.0)))
		brow.rotation.y = deg_to_rad(side * 4.0)
		_mesh_sphere(_head_root, "CheekBeard", Vector3(0.155 * side, -0.12, -0.105), 0.13, 0.26, _beard_material, Vector3(0.9, 1.05, 0.7))
		_mesh_capsule(_head_root, "Sideburn", Vector3(0.208 * side, 0.0, -0.015), 0.035, 0.2, _beard_material, Vector3(0.9, 1.0, 0.72))
	_mesh_capsule(_head_root, "UpperLip", Vector3(0.0, -0.105, -0.25), 0.022, 0.15, _lip_material, Vector3(1.0, 1.0, 0.62), Vector3(0.0, 0.0, PI * 0.5))
	_mesh_capsule(_head_root, "LowerLip", Vector3(0.0, -0.142, -0.242), 0.02, 0.13, _lip_material, Vector3(1.0, 1.0, 0.58), Vector3(0.0, 0.0, PI * 0.5))
	_mesh_capsule(_head_root, "MoustacheLeft", Vector3(-0.055, -0.078, -0.264), 0.022, 0.115, _beard_material, Vector3(1.0, 1.0, 0.52), Vector3(0.0, 0.0, deg_to_rad(70.0)))
	_mesh_capsule(_head_root, "MoustacheRight", Vector3(0.055, -0.078, -0.264), 0.022, 0.115, _beard_material, Vector3(1.0, 1.0, 0.52), Vector3(0.0, 0.0, deg_to_rad(-70.0)))
	_mesh_sphere(_head_root, "FullChinBeard", Vector3(0.0, -0.235, -0.07), 0.185, 0.27, _beard_material, Vector3(1.08, 1.08, 0.78))
	_mesh_sphere(_head_root, "UnderChinBeard", Vector3(0.0, -0.27, 0.035), 0.17, 0.19, _beard_material, Vector3(1.0, 0.76, 0.9))

	_mesh_sphere(_head_root, "LayeredHairCap", Vector3(0.0, 0.19, 0.035), 0.262, 0.25, _hair_material, Vector3(1.03, 0.82, 1.03))
	_mesh_sphere(_head_root, "LayeredHairBack", Vector3(0.0, 0.04, 0.215), 0.215, 0.38, _hair_material, Vector3(1.02, 1.14, 0.63))
	var tuft_data := [
		[-0.17, 0.215, -0.08, -24.0, 0.28], [-0.09, 0.245, -0.12, -14.0, 0.32],
		[0.0, 0.255, -0.135, -4.0, 0.34], [0.09, 0.245, -0.12, 13.0, 0.31],
		[0.17, 0.215, -0.07, 25.0, 0.27], [-0.2, 0.11, 0.04, -32.0, 0.3],
		[0.2, 0.1, 0.05, 31.0, 0.29], [-0.14, 0.08, 0.19, -18.0, 0.31],
		[0.14, 0.07, 0.19, 19.0, 0.3]
	]
	for index in range(tuft_data.size()):
		var data: Array = tuft_data[index]
		_mesh_capsule(_head_root, "FlowingHairTuft%d" % index, Vector3(data[0], data[1], data[2]), 0.065, data[4], _hair_material, Vector3(1.0, 1.0, 0.7), Vector3(deg_to_rad(24.0), 0.0, deg_to_rad(data[3])))


func _build_anime_eye(side: float) -> void:
	_mesh_sphere(_head_root, "AnimeEyeWhite", Vector3(0.098 * side, 0.055, -0.235), 0.064, 0.07, _eye_white_material, Vector3(1.38, 0.82, 0.58))
	_mesh_sphere(_head_root, "AnimeIris", Vector3(0.098 * side, 0.052, -0.273), 0.03, 0.04, _iris_material, Vector3(1.0, 1.14, 0.48))
	_mesh_sphere(_head_root, "AnimePupil", Vector3(0.098 * side, 0.052, -0.29), 0.014, 0.02, _brow_material, Vector3(1.0, 1.12, 0.4))
	_mesh_sphere(_head_root, "EyeCatchlight", Vector3(0.091 * side, 0.065, -0.301), 0.006, 0.009, _eye_white_material)


func _build_arms() -> void:
	_left_shoulder = _pivot(_torso_root, "LeftShoulder", Vector3(-0.43, 1.58, 0.0))
	_right_shoulder = _pivot(_torso_root, "RightShoulder", Vector3(0.43, 1.58, 0.0))
	_build_arm(_left_shoulder, true)
	_build_arm(_right_shoulder, false)


func _build_arm(shoulder: Node3D, left_side: bool) -> void:
	_mesh_sphere(shoulder, "RoundedJerseyArmhole", Vector3(0.0, -0.065, 0.0), 0.14, 0.2, _jersey_material, Vector3(1.0, 1.0, 0.82))
	_mesh_capsule(shoulder, "UpperArm", Vector3(0.0, -0.255, 0.0), 0.105, 0.56, _skin_material, Vector3(1.04, 1.0, 0.98))
	var elbow := _pivot(shoulder, "Elbow", Vector3(0.0, -0.51, 0.0))
	_mesh_sphere(elbow, "ElbowJoint", Vector3.ZERO, 0.095, 0.16, _skin_material)
	_mesh_capsule(elbow, "Forearm", Vector3(0.0, -0.23, 0.0), 0.088, 0.5, _skin_material, Vector3(1.0, 1.0, 0.94))
	var hand := _pivot(elbow, "HandAnchor", Vector3(0.0, -0.47, 0.0))
	_mesh_sphere(hand, "Palm", Vector3.ZERO, 0.104, 0.18, _skin_material, Vector3(0.8, 1.0, 0.67))
	for finger_index in range(4):
		_mesh_capsule(hand, "Finger%d" % finger_index, Vector3((finger_index - 1.5) * 0.026, -0.095, -0.005), 0.012, 0.13, _skin_material, Vector3(1.0, 1.0, 0.82))
	if left_side:
		_left_elbow = elbow
		_left_hand = hand
	else:
		_right_elbow = elbow
		_right_hand = hand


func _build_legs() -> void:
	_left_hip = _pivot(_visual_root, "LeftHip", Vector3(-0.19, 0.82, 0.0))
	_right_hip = _pivot(_visual_root, "RightHip", Vector3(0.19, 0.82, 0.0))
	_build_leg(_left_hip, true)
	_build_leg(_right_hip, false)


func _build_leg(hip: Node3D, left_side: bool) -> void:
	_mesh_cylinder(hip, "RoundedShortLeg", Vector3(0.0, -0.12, 0.0), 0.15, 0.19, 0.32, _trim_material, Vector3(1.0, 1.0, 1.24))
	_mesh_capsule(hip, "UpperLeg", Vector3(0.0, -0.29, 0.0), 0.145, 0.63, _skin_material, Vector3(1.0, 1.0, 0.91))
	var knee := _pivot(hip, "Knee", Vector3(0.0, -0.57, 0.0))
	_mesh_sphere(knee, "KneeJoint", Vector3.ZERO, 0.123, 0.18, _skin_material, Vector3(1.0, 1.0, 0.9))
	_mesh_capsule(knee, "LowerLeg", Vector3(0.0, -0.27, 0.0), 0.118, 0.6, _skin_material, Vector3(1.0, 1.0, 0.88))
	_mesh_capsule(knee, "Sock", Vector3(0.0, -0.5, 0.0), 0.105, 0.28, _shoe_material, Vector3(1.0, 1.0, 0.9))
	_mesh_capsule(knee, "BasketballShoe", Vector3(0.0, -0.595, -0.09), 0.105, 0.39, _shoe_material, Vector3(1.15, 1.0, 0.94), Vector3(PI * 0.5, 0.0, 0.0))
	_mesh_sphere(knee, "ShoeToe", Vector3(0.0, -0.595, -0.27), 0.115, 0.16, _shoe_material, Vector3(1.06, 0.7, 1.18))
	_mesh_capsule(knee, "ShoeSole", Vector3(0.0, -0.655, -0.105), 0.105, 0.42, _sole_material, Vector3(1.18, 0.43, 0.96), Vector3(PI * 0.5, 0.0, 0.0))
	if left_side:
		_left_knee = knee
	else:
		_right_knee = knee


func _build_animation_player() -> void:
	_animation_player = AnimationPlayer.new()
	_animation_player.name = "AuthoredAnimationPlayer"
	_animation_player.root_node = NodePath("..")
	add_child(_animation_player)


func _rebuild_authored_animations() -> void:
	if _animation_player.has_animation_library(""):
		_animation_player.remove_animation_library("")
	_animation_library = AnimationLibrary.new()
	_animation_player.add_animation_library("", _animation_library)
	_add_clip("RESET", 0.05, false, {})
	_author_idle()
	_author_walk()
	_author_sprint()
	_author_dribble(false)
	_author_dribble(true)
	_author_crossover(false)
	_author_crossover(true)
	_author_shot_gather()
	_author_shot_release()
	_author_defense_idle()
	_author_defense_shuffle()


func _base_curves(length: float) -> Dictionary:
	var zero_rotation := [[0.0, Vector3.ZERO], [length, Vector3.ZERO]]
	return {
		ROOT_POSITION: [[0.0, Vector3.ZERO], [length, Vector3.ZERO]],
		TORSO_ROTATION: zero_rotation.duplicate(true),
		HEAD_ROTATION: zero_rotation.duplicate(true),
		LEFT_SHOULDER_ROTATION: zero_rotation.duplicate(true),
		RIGHT_SHOULDER_ROTATION: zero_rotation.duplicate(true),
		LEFT_ELBOW_ROTATION: zero_rotation.duplicate(true),
		RIGHT_ELBOW_ROTATION: zero_rotation.duplicate(true),
		LEFT_HIP_ROTATION: zero_rotation.duplicate(true),
		RIGHT_HIP_ROTATION: zero_rotation.duplicate(true),
		LEFT_KNEE_ROTATION: zero_rotation.duplicate(true),
		RIGHT_KNEE_ROTATION: zero_rotation.duplicate(true)
	}


func _add_clip(clip_name: String, length: float, looped: bool, overrides: Dictionary) -> void:
	var curves := _base_curves(length)
	for path in overrides:
		curves[path] = overrides[path]
	var animation := Animation.new()
	animation.length = length
	animation.loop_mode = Animation.LOOP_LINEAR if looped else Animation.LOOP_NONE
	for path in curves:
		var track := animation.add_track(Animation.TYPE_VALUE)
		animation.track_set_path(track, NodePath(path))
		var interpolation := Animation.INTERPOLATION_CUBIC_ANGLE if str(path).ends_with(":rotation") else Animation.INTERPOLATION_CUBIC
		animation.track_set_interpolation_type(track, interpolation)
		for key_data in curves[path]:
			animation.track_insert_key(track, float(key_data[0]), key_data[1])
	_animation_library.add_animation(clip_name, animation)


func _author_idle() -> void:
	var length := 2.4
	_add_clip("idle", length, true, {
		ROOT_POSITION: [[0.0, Vector3.ZERO], [0.6, Vector3(0.0, 0.012 * _bob_scale, 0.0)], [1.2, Vector3.ZERO], [1.8, Vector3(0.0, 0.008 * _bob_scale, 0.0)], [length, Vector3.ZERO]],
		TORSO_ROTATION: [[0.0, Vector3(-0.015, 0.0, -0.012)], [1.2, Vector3(0.012, 0.0, 0.012)], [length, Vector3(-0.015, 0.0, -0.012)]],
		HEAD_ROTATION: [[0.0, Vector3(0.02, -0.018, 0.0)], [1.2, Vector3(-0.012, 0.018, 0.0)], [length, Vector3(0.02, -0.018, 0.0)]],
		LEFT_SHOULDER_ROTATION: [[0.0, Vector3(0.04, 0.0, -0.04)], [1.2, Vector3(0.075, 0.0, -0.055)], [length, Vector3(0.04, 0.0, -0.04)]],
		RIGHT_SHOULDER_ROTATION: [[0.0, Vector3(0.055, 0.0, 0.04)], [1.2, Vector3(0.035, 0.0, 0.055)], [length, Vector3(0.055, 0.0, 0.04)]]
	})


func _author_walk() -> void:
	var length := 0.78
	var stride := 0.52 * _stride_scale
	var arm := 0.42 * _arm_swing_scale
	var bob := 0.035 * _bob_scale
	_add_clip("walk", length, true, {
		ROOT_POSITION: [[0.0, Vector3.ZERO], [length * 0.25, Vector3(0.0, bob, 0.0)], [length * 0.5, Vector3.ZERO], [length * 0.75, Vector3(0.0, bob, 0.0)], [length, Vector3.ZERO]],
		TORSO_ROTATION: [[0.0, Vector3(0.0, -0.045, -0.02)], [length * 0.5, Vector3(0.0, 0.045, 0.02)], [length, Vector3(0.0, -0.045, -0.02)]],
		HEAD_ROTATION: [[0.0, Vector3(0.0, 0.025, 0.0)], [length * 0.5, Vector3(0.0, -0.025, 0.0)], [length, Vector3(0.0, 0.025, 0.0)]],
		LEFT_SHOULDER_ROTATION: [[0.0, Vector3(-arm, 0.0, -0.06)], [length * 0.5, Vector3(arm, 0.0, -0.06)], [length, Vector3(-arm, 0.0, -0.06)]],
		RIGHT_SHOULDER_ROTATION: [[0.0, Vector3(arm, 0.0, 0.06)], [length * 0.5, Vector3(-arm, 0.0, 0.06)], [length, Vector3(arm, 0.0, 0.06)]],
		LEFT_ELBOW_ROTATION: [[0.0, Vector3(0.2, 0.0, 0.0)], [length * 0.5, Vector3(0.34, 0.0, 0.0)], [length, Vector3(0.2, 0.0, 0.0)]],
		RIGHT_ELBOW_ROTATION: [[0.0, Vector3(0.34, 0.0, 0.0)], [length * 0.5, Vector3(0.2, 0.0, 0.0)], [length, Vector3(0.34, 0.0, 0.0)]],
		LEFT_HIP_ROTATION: [[0.0, Vector3(stride, 0.0, 0.0)], [length * 0.5, Vector3(-stride, 0.0, 0.0)], [length, Vector3(stride, 0.0, 0.0)]],
		RIGHT_HIP_ROTATION: [[0.0, Vector3(-stride, 0.0, 0.0)], [length * 0.5, Vector3(stride, 0.0, 0.0)], [length, Vector3(-stride, 0.0, 0.0)]],
		LEFT_KNEE_ROTATION: [[0.0, Vector3(0.0, 0.0, 0.0)], [length * 0.25, Vector3(0.48, 0.0, 0.0)], [length * 0.5, Vector3(0.05, 0.0, 0.0)], [length, Vector3.ZERO]],
		RIGHT_KNEE_ROTATION: [[0.0, Vector3(0.05, 0.0, 0.0)], [length * 0.5, Vector3.ZERO], [length * 0.75, Vector3(0.48, 0.0, 0.0)], [length, Vector3(0.05, 0.0, 0.0)]]
	})


func _author_sprint() -> void:
	var length := 0.54
	var stride := 0.76 * _stride_scale
	var arm := 0.7 * _arm_swing_scale
	var bob := 0.064 * _bob_scale
	_add_clip("sprint", length, true, {
		ROOT_POSITION: [[0.0, Vector3.ZERO], [length * 0.25, Vector3(0.0, bob, -0.018)], [length * 0.5, Vector3.ZERO], [length * 0.75, Vector3(0.0, bob, -0.018)], [length, Vector3.ZERO]],
		TORSO_ROTATION: [[0.0, Vector3(-0.16, -0.07, -0.03)], [length * 0.5, Vector3(-0.16, 0.07, 0.03)], [length, Vector3(-0.16, -0.07, -0.03)]],
		HEAD_ROTATION: [[0.0, Vector3(0.1, 0.035, 0.0)], [length * 0.5, Vector3(0.1, -0.035, 0.0)], [length, Vector3(0.1, 0.035, 0.0)]],
		LEFT_SHOULDER_ROTATION: [[0.0, Vector3(-arm, 0.0, -0.08)], [length * 0.5, Vector3(arm, 0.0, -0.08)], [length, Vector3(-arm, 0.0, -0.08)]],
		RIGHT_SHOULDER_ROTATION: [[0.0, Vector3(arm, 0.0, 0.08)], [length * 0.5, Vector3(-arm, 0.0, 0.08)], [length, Vector3(arm, 0.0, 0.08)]],
		LEFT_ELBOW_ROTATION: [[0.0, Vector3(0.5, 0.0, 0.0)], [length * 0.5, Vector3(0.22, 0.0, 0.0)], [length, Vector3(0.5, 0.0, 0.0)]],
		RIGHT_ELBOW_ROTATION: [[0.0, Vector3(0.22, 0.0, 0.0)], [length * 0.5, Vector3(0.5, 0.0, 0.0)], [length, Vector3(0.22, 0.0, 0.0)]],
		LEFT_HIP_ROTATION: [[0.0, Vector3(stride, 0.0, 0.0)], [length * 0.5, Vector3(-stride, 0.0, 0.0)], [length, Vector3(stride, 0.0, 0.0)]],
		RIGHT_HIP_ROTATION: [[0.0, Vector3(-stride, 0.0, 0.0)], [length * 0.5, Vector3(stride, 0.0, 0.0)], [length, Vector3(-stride, 0.0, 0.0)]],
		LEFT_KNEE_ROTATION: [[0.0, Vector3(0.0, 0.0, 0.0)], [length * 0.25, Vector3(0.7, 0.0, 0.0)], [length * 0.5, Vector3(0.1, 0.0, 0.0)], [length, Vector3.ZERO]],
		RIGHT_KNEE_ROTATION: [[0.0, Vector3(0.1, 0.0, 0.0)], [length * 0.5, Vector3.ZERO], [length * 0.75, Vector3(0.7, 0.0, 0.0)], [length, Vector3(0.1, 0.0, 0.0)]]
	})


func _author_dribble(left_side: bool) -> void:
	var length := 0.64
	var reach := 0.58 * _dribble_reach
	var side_sign := -1.0 if left_side else 1.0
	var clip := "dribble_left" if left_side else "dribble_right"
	var active_shoulder := LEFT_SHOULDER_ROTATION if left_side else RIGHT_SHOULDER_ROTATION
	var active_elbow := LEFT_ELBOW_ROTATION if left_side else RIGHT_ELBOW_ROTATION
	var support_shoulder := RIGHT_SHOULDER_ROTATION if left_side else LEFT_SHOULDER_ROTATION
	var curves := {
		ROOT_POSITION: [[0.0, Vector3(0.0, -0.02, 0.0)], [length * 0.5, Vector3(0.0, 0.012 * _bob_scale, 0.0)], [length, Vector3(0.0, -0.02, 0.0)]],
		TORSO_ROTATION: [[0.0, Vector3(-0.08, side_sign * 0.08, side_sign * 0.045)], [length * 0.5, Vector3(-0.12, side_sign * 0.1, side_sign * 0.08)], [length, Vector3(-0.08, side_sign * 0.08, side_sign * 0.045)]],
		HEAD_ROTATION: [[0.0, Vector3(0.07, -side_sign * 0.04, 0.0)], [length * 0.5, Vector3(0.1, -side_sign * 0.06, 0.0)], [length, Vector3(0.07, -side_sign * 0.04, 0.0)]],
		LEFT_HIP_ROTATION: [[0.0, Vector3(0.14, 0.0, -0.04)], [length * 0.5, Vector3(-0.1, 0.0, -0.04)], [length, Vector3(0.14, 0.0, -0.04)]],
		RIGHT_HIP_ROTATION: [[0.0, Vector3(-0.1, 0.0, 0.04)], [length * 0.5, Vector3(0.14, 0.0, 0.04)], [length, Vector3(-0.1, 0.0, 0.04)]]
	}
	curves[active_shoulder] = [[0.0, Vector3(reach, 0.0, side_sign * 0.18)], [length * 0.5, Vector3(0.92 * _dribble_reach, 0.0, side_sign * 0.28)], [length, Vector3(reach, 0.0, side_sign * 0.18)]]
	curves[active_elbow] = [[0.0, Vector3(0.22, 0.0, 0.0)], [length * 0.5, Vector3(0.58, 0.0, 0.0)], [length, Vector3(0.22, 0.0, 0.0)]]
	curves[support_shoulder] = [[0.0, Vector3(0.22, 0.0, -side_sign * 0.28)], [length * 0.5, Vector3(0.32, 0.0, -side_sign * 0.34)], [length, Vector3(0.22, 0.0, -side_sign * 0.28)]]
	_add_clip(clip, length, true, curves)


func _author_crossover(left_side: bool) -> void:
	var length := 0.46
	var sign_value := -1.0 if left_side else 1.0
	var clip := "crossover_left" if left_side else "crossover_right"
	var source_shoulder := RIGHT_SHOULDER_ROTATION if left_side else LEFT_SHOULDER_ROTATION
	var target_shoulder := LEFT_SHOULDER_ROTATION if left_side else RIGHT_SHOULDER_ROTATION
	var curves := {
		ROOT_POSITION: [[0.0, Vector3.ZERO], [0.18, Vector3(-sign_value * 0.12 * _crossover_lean, -0.075, 0.0)], [0.34, Vector3(sign_value * 0.08 * _crossover_lean, -0.025, 0.0)], [length, Vector3.ZERO]],
		TORSO_ROTATION: [[0.0, Vector3(-0.08, 0.0, 0.0)], [0.18, Vector3(-0.2, sign_value * 0.18, -sign_value * 0.24 * _crossover_lean)], [0.34, Vector3(-0.12, -sign_value * 0.12, sign_value * 0.12)], [length, Vector3(-0.06, 0.0, 0.0)]],
		HEAD_ROTATION: [[0.0, Vector3(0.06, 0.0, 0.0)], [0.18, Vector3(0.14, -sign_value * 0.12, sign_value * 0.08)], [length, Vector3(0.04, 0.0, 0.0)]],
		LEFT_ELBOW_ROTATION: [[0.0, Vector3(0.36, 0.0, 0.0)], [0.23, Vector3(0.58, 0.0, 0.0)], [length, Vector3(0.28, 0.0, 0.0)]],
		RIGHT_ELBOW_ROTATION: [[0.0, Vector3(0.36, 0.0, 0.0)], [0.23, Vector3(0.58, 0.0, 0.0)], [length, Vector3(0.28, 0.0, 0.0)]],
		LEFT_HIP_ROTATION: [[0.0, Vector3(0.12, 0.0, -0.08)], [0.2, Vector3(0.34, 0.0, -0.18)], [length, Vector3(0.04, 0.0, 0.0)]],
		RIGHT_HIP_ROTATION: [[0.0, Vector3(0.12, 0.0, 0.08)], [0.2, Vector3(0.34, 0.0, 0.18)], [length, Vector3(0.04, 0.0, 0.0)]],
		LEFT_KNEE_ROTATION: [[0.0, Vector3(-0.12, 0.0, 0.0)], [0.2, Vector3(-0.38, 0.0, 0.0)], [length, Vector3.ZERO]],
		RIGHT_KNEE_ROTATION: [[0.0, Vector3(-0.12, 0.0, 0.0)], [0.2, Vector3(-0.38, 0.0, 0.0)], [length, Vector3.ZERO]]
	}
	curves[source_shoulder] = [[0.0, Vector3(0.72, 0.0, -sign_value * 0.2)], [0.22, Vector3(0.94, -sign_value * 0.35, sign_value * 0.62 * _dribble_reach)], [length, Vector3(0.34, 0.0, -sign_value * 0.12)]]
	curves[target_shoulder] = [[0.0, Vector3(0.24, 0.0, sign_value * 0.12)], [0.26, Vector3(0.56, sign_value * 0.18, -sign_value * 0.38)], [length, Vector3(0.72, 0.0, sign_value * 0.2)]]
	_add_clip(clip, length, false, curves)


func _author_shot_gather() -> void:
	var length := 1.0
	var height_adjust := 0.18 * (_release_height - 1.0)
	_add_clip("shot_gather", length, false, {
		ROOT_POSITION: [[0.0, Vector3.ZERO], [0.55, Vector3(0.0, -0.115 * _stance_scale, 0.0)], [length, Vector3(0.0, -0.04, 0.0)]],
		TORSO_ROTATION: [[0.0, Vector3.ZERO], [0.55, Vector3(-0.14, 0.0, 0.0)], [length, Vector3(-0.04, 0.0, 0.0)]],
		HEAD_ROTATION: [[0.0, Vector3.ZERO], [0.55, Vector3(0.1, 0.0, 0.0)], [length, Vector3(0.04, 0.0, 0.0)]],
		LEFT_SHOULDER_ROTATION: [[0.0, Vector3(0.3, 0.0, -0.18)], [0.55, Vector3(1.12, 0.0, -0.2)], [length, Vector3(1.82 + height_adjust, 0.0, -0.18)]],
		RIGHT_SHOULDER_ROTATION: [[0.0, Vector3(0.3, 0.0, 0.18)], [0.55, Vector3(1.12, 0.0, 0.2)], [length, Vector3(1.82 + height_adjust, 0.0, 0.18)]],
		LEFT_ELBOW_ROTATION: [[0.0, Vector3(0.2, 0.0, 0.0)], [0.55, Vector3(-0.5, 0.0, 0.0)], [length, Vector3(-0.64, 0.0, 0.0)]],
		RIGHT_ELBOW_ROTATION: [[0.0, Vector3(0.2, 0.0, 0.0)], [0.55, Vector3(-0.5, 0.0, 0.0)], [length, Vector3(-0.56, 0.0, 0.0)]],
		LEFT_HIP_ROTATION: [[0.0, Vector3.ZERO], [0.55, Vector3(0.26, 0.0, -0.04)], [length, Vector3(0.1, 0.0, 0.0)]],
		RIGHT_HIP_ROTATION: [[0.0, Vector3.ZERO], [0.55, Vector3(0.26, 0.0, 0.04)], [length, Vector3(0.1, 0.0, 0.0)]],
		LEFT_KNEE_ROTATION: [[0.0, Vector3.ZERO], [0.55, Vector3(-0.42, 0.0, 0.0)], [length, Vector3(-0.16, 0.0, 0.0)]],
		RIGHT_KNEE_ROTATION: [[0.0, Vector3.ZERO], [0.55, Vector3(-0.42, 0.0, 0.0)], [length, Vector3(-0.16, 0.0, 0.0)]]
	})


func _author_shot_release() -> void:
	var length := 0.64
	var jump_height := 0.24 * _jump_scale
	var release_angle := 2.62 + 0.16 * (_release_height - 1.0)
	_add_clip("shot_release", length, false, {
		ROOT_POSITION: [[0.0, Vector3(0.0, -0.04, 0.0)], [0.18, Vector3(0.0, jump_height, 0.0)], [0.38, Vector3(0.0, jump_height * 0.9, 0.0)], [length, Vector3.ZERO]],
		TORSO_ROTATION: [[0.0, Vector3(-0.04, 0.0, 0.0)], [0.2, Vector3(-0.12, 0.0, 0.0)], [0.42, Vector3(0.045, 0.0, 0.0)], [length, Vector3.ZERO]],
		HEAD_ROTATION: [[0.0, Vector3(0.04, 0.0, 0.0)], [0.25, Vector3(0.1, 0.0, 0.0)], [length, Vector3(0.05, 0.0, 0.0)]],
		LEFT_SHOULDER_ROTATION: [[0.0, Vector3(1.82, 0.0, -0.18)], [0.2, Vector3(release_angle, 0.0, -0.12 * _follow_through)], [0.46, Vector3(2.48, 0.0, -0.08 * _follow_through)], [length, Vector3(1.25, 0.0, -0.08)]],
		RIGHT_SHOULDER_ROTATION: [[0.0, Vector3(1.82, 0.0, 0.18)], [0.2, Vector3(release_angle + 0.04, 0.0, 0.12 * _follow_through)], [0.46, Vector3(2.56, 0.0, 0.08 * _follow_through)], [length, Vector3(1.28, 0.0, 0.08)]],
		LEFT_ELBOW_ROTATION: [[0.0, Vector3(-0.64, 0.0, 0.0)], [0.2, Vector3(-0.08, 0.0, 0.0)], [0.46, Vector3(0.08, 0.0, 0.0)], [length, Vector3(0.2, 0.0, 0.0)]],
		RIGHT_ELBOW_ROTATION: [[0.0, Vector3(-0.56, 0.0, 0.0)], [0.2, Vector3(0.06, 0.0, 0.0)], [0.46, Vector3(0.24 * _follow_through, 0.0, 0.0)], [length, Vector3(0.2, 0.0, 0.0)]],
		LEFT_HIP_ROTATION: [[0.0, Vector3(0.1, 0.0, 0.0)], [0.2, Vector3(-0.08, 0.0, 0.0)], [length, Vector3.ZERO]],
		RIGHT_HIP_ROTATION: [[0.0, Vector3(0.1, 0.0, 0.0)], [0.2, Vector3(-0.08, 0.0, 0.0)], [length, Vector3.ZERO]],
		LEFT_KNEE_ROTATION: [[0.0, Vector3(-0.16, 0.0, 0.0)], [0.2, Vector3(0.08, 0.0, 0.0)], [0.48, Vector3(-0.12, 0.0, 0.0)], [length, Vector3.ZERO]],
		RIGHT_KNEE_ROTATION: [[0.0, Vector3(-0.16, 0.0, 0.0)], [0.2, Vector3(0.08, 0.0, 0.0)], [0.48, Vector3(-0.12, 0.0, 0.0)], [length, Vector3.ZERO]]
	})


func _author_defense_idle() -> void:
	var length := 1.3
	_add_clip("defense_idle", length, true, {
		ROOT_POSITION: [[0.0, Vector3(0.0, -0.07 * _stance_scale, 0.0)], [length * 0.5, Vector3(0.0, -0.055 * _stance_scale, 0.0)], [length, Vector3(0.0, -0.07 * _stance_scale, 0.0)]],
		TORSO_ROTATION: [[0.0, Vector3(-0.13, 0.0, 0.0)], [length * 0.5, Vector3(-0.11, 0.02, 0.0)], [length, Vector3(-0.13, 0.0, 0.0)]],
		HEAD_ROTATION: [[0.0, Vector3(0.11, 0.0, 0.0)], [length * 0.5, Vector3(0.09, -0.02, 0.0)], [length, Vector3(0.11, 0.0, 0.0)]],
		LEFT_SHOULDER_ROTATION: [[0.0, Vector3(0.28, 0.0, -1.05)], [length * 0.5, Vector3(0.24, 0.0, -1.1)], [length, Vector3(0.28, 0.0, -1.05)]],
		RIGHT_SHOULDER_ROTATION: [[0.0, Vector3(0.28, 0.0, 1.05)], [length * 0.5, Vector3(0.24, 0.0, 1.1)], [length, Vector3(0.28, 0.0, 1.05)]],
		LEFT_ELBOW_ROTATION: [[0.0, Vector3(-0.16, 0.0, 0.0)], [length, Vector3(-0.16, 0.0, 0.0)]],
		RIGHT_ELBOW_ROTATION: [[0.0, Vector3(-0.16, 0.0, 0.0)], [length, Vector3(-0.16, 0.0, 0.0)]],
		LEFT_HIP_ROTATION: [[0.0, Vector3(0.16, 0.0, -0.1)], [length, Vector3(0.16, 0.0, -0.1)]],
		RIGHT_HIP_ROTATION: [[0.0, Vector3(0.16, 0.0, 0.1)], [length, Vector3(0.16, 0.0, 0.1)]],
		LEFT_KNEE_ROTATION: [[0.0, Vector3(-0.3, 0.0, 0.0)], [length, Vector3(-0.3, 0.0, 0.0)]],
		RIGHT_KNEE_ROTATION: [[0.0, Vector3(-0.3, 0.0, 0.0)], [length, Vector3(-0.3, 0.0, 0.0)]]
	})


func _author_defense_shuffle() -> void:
	var length := 0.62
	var shuffle := 0.38 * _stride_scale
	_add_clip("defense_shuffle", length, true, {
		ROOT_POSITION: [[0.0, Vector3(0.0, -0.08 * _stance_scale, 0.0)], [length * 0.25, Vector3(0.035, -0.045, 0.0)], [length * 0.5, Vector3.ZERO], [length * 0.75, Vector3(-0.035, -0.045, 0.0)], [length, Vector3(0.0, -0.08 * _stance_scale, 0.0)]],
		TORSO_ROTATION: [[0.0, Vector3(-0.14, -0.06, -0.04)], [length * 0.5, Vector3(-0.14, 0.06, 0.04)], [length, Vector3(-0.14, -0.06, -0.04)]],
		HEAD_ROTATION: [[0.0, Vector3(0.11, 0.04, 0.0)], [length * 0.5, Vector3(0.11, -0.04, 0.0)], [length, Vector3(0.11, 0.04, 0.0)]],
		LEFT_SHOULDER_ROTATION: [[0.0, Vector3(0.3, 0.0, -1.05)], [length * 0.5, Vector3(0.2, 0.0, -1.15)], [length, Vector3(0.3, 0.0, -1.05)]],
		RIGHT_SHOULDER_ROTATION: [[0.0, Vector3(0.2, 0.0, 1.15)], [length * 0.5, Vector3(0.3, 0.0, 1.05)], [length, Vector3(0.2, 0.0, 1.15)]],
		LEFT_HIP_ROTATION: [[0.0, Vector3(0.16 + shuffle, 0.0, -0.12)], [length * 0.5, Vector3(0.16 - shuffle, 0.0, -0.08)], [length, Vector3(0.16 + shuffle, 0.0, -0.12)]],
		RIGHT_HIP_ROTATION: [[0.0, Vector3(0.16 - shuffle, 0.0, 0.08)], [length * 0.5, Vector3(0.16 + shuffle, 0.0, 0.12)], [length, Vector3(0.16 - shuffle, 0.0, 0.08)]],
		LEFT_KNEE_ROTATION: [[0.0, Vector3(-0.34, 0.0, 0.0)], [length * 0.5, Vector3(-0.18, 0.0, 0.0)], [length, Vector3(-0.34, 0.0, 0.0)]],
		RIGHT_KNEE_ROTATION: [[0.0, Vector3(-0.18, 0.0, 0.0)], [length * 0.5, Vector3(-0.34, 0.0, 0.0)], [length, Vector3(-0.18, 0.0, 0.0)]]
	})


func _pivot(parent: Node3D, pivot_name: String, local_position: Vector3) -> Node3D:
	var pivot := Node3D.new()
	pivot.name = pivot_name
	pivot.position = local_position
	parent.add_child(pivot)
	return pivot


func _mesh_capsule(parent: Node3D, mesh_name: String, local_position: Vector3, radius: float, height: float, material: Material, local_scale := Vector3.ONE, local_rotation := Vector3.ZERO) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.name = mesh_name
	var mesh := CapsuleMesh.new()
	mesh.radius = radius
	mesh.height = maxf(height, radius * 2.0)
	mesh.radial_segments = 24
	mesh.rings = 10
	instance.mesh = mesh
	instance.material_override = material
	instance.position = local_position
	instance.scale = local_scale
	instance.rotation = local_rotation
	parent.add_child(instance)
	return instance


func _mesh_sphere(parent: Node3D, mesh_name: String, local_position: Vector3, radius: float, height: float, material: Material, local_scale := Vector3.ONE, local_rotation := Vector3.ZERO) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.name = mesh_name
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = maxf(height, radius * 2.0)
	mesh.radial_segments = 24
	mesh.rings = 12
	instance.mesh = mesh
	instance.material_override = material
	instance.position = local_position
	instance.scale = local_scale
	instance.rotation = local_rotation
	parent.add_child(instance)
	return instance


func _mesh_cylinder(parent: Node3D, mesh_name: String, local_position: Vector3, top_radius: float, bottom_radius: float, height: float, material: Material, local_scale := Vector3.ONE, local_rotation := Vector3.ZERO) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.name = mesh_name
	var mesh := CylinderMesh.new()
	mesh.top_radius = top_radius
	mesh.bottom_radius = bottom_radius
	mesh.height = height
	mesh.radial_segments = 24
	mesh.rings = 4
	instance.mesh = mesh
	instance.material_override = material
	instance.position = local_position
	instance.scale = local_scale
	instance.rotation = local_rotation
	parent.add_child(instance)
	return instance


func _source_color(source: Material, fallback: Color) -> Color:
	if source is StandardMaterial3D:
		return (source as StandardMaterial3D).albedo_color
	return fallback


func _toon_material(color: Color, roughness: float, rim_strength: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = roughness
	material.diffuse_mode = BaseMaterial3D.DIFFUSE_TOON
	material.specular_mode = BaseMaterial3D.SPECULAR_TOON
	material.rim_enabled = true
	material.rim = rim_strength
	material.rim_tint = 0.55
	material.next_pass = _outline_material
	return material


func _make_outline_material() -> StandardMaterial3D:
	var outline := StandardMaterial3D.new()
	outline.albedo_color = Color("#111827")
	outline.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	outline.cull_mode = BaseMaterial3D.CULL_FRONT
	outline.grow_enabled = true
	outline.grow = 0.008
	return outline
