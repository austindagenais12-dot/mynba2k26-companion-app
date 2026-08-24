extends SceneTree

const AnimationCatalog = preload("res://scripts/animation_catalog.gd")

func _initialize() -> void:
	assert(AnimationCatalog.TOTAL_STYLES == 2304, "Motion Studio must expose 2,304 signature combinations.")
	var first := AnimationCatalog.get_profile(0)
	var last := AnimationCatalog.get_profile(AnimationCatalog.TOTAL_STYLES - 1)
	var wrapped := AnimationCatalog.get_profile(AnimationCatalog.TOTAL_STYLES)
	assert(str(first.name) != str(last.name), "First and final motion profiles must differ.")
	assert(int(wrapped.index) == 0, "Animation style indices must wrap safely.")
	assert(float(first.cadence_scale) > 0.0 and float(last.release_speed) > 0.0, "Motion profile parameters must remain valid.")
	print("ANIMATION TESTS PASSED: %d selectable signature profiles" % AnimationCatalog.TOTAL_STYLES)
	quit(0)
