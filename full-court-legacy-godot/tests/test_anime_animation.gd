extends SceneTree

const AnimePlayerModel = preload("res://scripts/anime_player_model.gd")
const AnimationCatalog = preload("res://scripts/animation_catalog.gd")


func _initialize() -> void:
	var jersey := StandardMaterial3D.new()
	jersey.albedo_color = Color("#0B74BB")
	var trim := StandardMaterial3D.new()
	trim.albedo_color = Color("#061735")

	var model = AnimePlayerModel.new()
	root.add_child(model)
	model.build(jersey, trim, true, 7)
	model.set_animation_profile(AnimationCatalog.get_profile(1379))

	var animation_player: AnimationPlayer = model.get_animation_player()
	assert(animation_player != null, "Anime player must contain an AnimationPlayer, not direct per-frame limb posing.")
	var clip_names: PackedStringArray = model.get_authored_animation_names()
	assert(clip_names.size() == 11, "The production anime rig must expose all eleven authored gameplay clips.")
	for clip_name in clip_names:
		assert(animation_player.has_animation(clip_name), "Missing authored clip: %s" % clip_name)
		var animation := animation_player.get_animation(clip_name)
		assert(animation != null and animation.get_track_count() == 11, "%s must key every animated body control." % clip_name)
		assert(animation.track_get_interpolation_type(1) == Animation.INTERPOLATION_CUBIC_ANGLE, "%s rotations must use smooth cubic-angle interpolation." % clip_name)

	assert(not _contains_box_mesh(model), "Anime body and uniform geometry must remain rounded; BoxMesh primitives are not allowed in the player model.")
	model.update_player_animation(0.016, 0.8, false, true, false, 0.0, 1)
	animation_player.advance(0.2)
	var right_hand := model.get_hand_position(1)
	var left_hand := model.get_hand_position(-1)
	assert(right_hand.is_finite() and left_hand.is_finite(), "Animated hand anchors must provide valid ball attachment positions.")
	assert(right_hand.distance_to(left_hand) > 0.2, "Left and right hand anchors must remain spatially distinct.")

	model.play_crossover(-1)
	animation_player.advance(0.12)
	model.play_shot_release()
	animation_player.advance(0.18)
	model.free()
	print("ANIME ANIMATION TESTS PASSED: 11 authored clips / cubic blends / rounded toon geometry")
	quit(0)


func _contains_box_mesh(node: Node) -> bool:
	if node is MeshInstance3D and (node as MeshInstance3D).mesh is BoxMesh:
		return true
	for child in node.get_children():
		if _contains_box_mesh(child):
			return true
	return false
