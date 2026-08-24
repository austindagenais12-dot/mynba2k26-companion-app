extends SceneTree

const BasketballPhysics = preload("res://scripts/basketball_physics.gd")
const NetPhysics = preload("res://scripts/net_physics.gd")

func _initialize() -> void:
	var origin := Vector3(0.0, 1.8, -3.0)
	var target := Vector3(0.0, 3.13, 5.0)
	var horizontal_direction := target - origin
	horizontal_direction.y = 0.0
	horizontal_direction = horizontal_direction.normalized()
	var spin := horizontal_direction.cross(Vector3.UP) * 17.0
	var launch := BasketballPhysics.solve_launch_velocity(origin, target, 0.86, spin)
	var predicted := BasketballPhysics.predict_position(origin, launch, spin, 0.86, 160)
	assert(predicted.distance_to(target) < 0.035, "Aerodynamic shot solver must converge on the basket target.")
	var drag := BasketballPhysics.aerodynamic_acceleration(Vector3(0.0, 2.0, 10.0), Vector3.ZERO)
	assert(drag.z < 0.0, "Air drag must oppose forward ball velocity.")
	var lift := BasketballPhysics.aerodynamic_acceleration(Vector3(0.0, 2.0, 10.0), Vector3(-17.0, 0.0, 0.0))
	assert(lift.y > drag.y, "Backspin must add upward Magnus lift.")
	var net = NetPhysics.new()
	root.add_child(net)
	net.build(Vector3.ZERO, null)
	assert(net.get_particle_count() == 84, "Dynamic net must contain 84 simulated particles.")
	assert(net.get_constraint_count() > 200, "Dynamic net must retain its structural constraint lattice.")
	net.free()
	print("PHYSICS TESTS PASSED: drag/backspin/shot solver/84-particle net")
	quit(0)
