extends Node3D

const RING_COUNT := 7
const SEGMENT_COUNT := 12
const NET_HEIGHT := 0.5
const TOP_RADIUS := 0.222
const BOTTOM_RADIUS := 0.125
const CORD_RADIUS := 0.014
const SOLVER_ITERATIONS := 5

var _positions: Array[Vector3] = []
var _previous_positions: Array[Vector3] = []
var _anchors: Array[Vector3] = []
var _constraint_a: PackedInt32Array = PackedInt32Array()
var _constraint_b: PackedInt32Array = PackedInt32Array()
var _rest_lengths: PackedFloat32Array = PackedFloat32Array()
var _render_edges: Array[Vector2i] = []
var _mesh: ImmediateMesh
var _mesh_instance: MeshInstance3D
var _cord_material: StandardMaterial3D
var _ball: RigidBody3D

func build(rim_center: Vector3, basketball: RigidBody3D) -> void:
	var net_position := rim_center + Vector3.DOWN * 0.03
	if is_inside_tree():
		global_position = net_position
	else:
		position = net_position
	_ball = basketball
	_build_particles()
	_build_constraints()
	_build_renderer()
	if _ball != null and _ball.has_method("set_net_region"):
		_ball.set_net_region(rim_center)

func _physics_process(delta: float) -> void:
	if _positions.is_empty():
		return
	var step := minf(delta, 1.0 / 30.0)
	var acceleration := Vector3.DOWN * 5.8
	for index in range(SEGMENT_COUNT, _positions.size()):
		var current := _positions[index]
		var velocity := (current - _previous_positions[index]) * 0.982
		_previous_positions[index] = current
		_positions[index] = current + velocity + acceleration * step * step

	_collide_with_ball(step)
	for _iteration in range(SOLVER_ITERATIONS):
		_solve_constraints()
		_pin_top_ring()
	_update_mesh()

func get_particle_count() -> int:
	return _positions.size()

func get_constraint_count() -> int:
	return _constraint_a.size()

func _build_particles() -> void:
	_positions.clear()
	_previous_positions.clear()
	_anchors.clear()
	for ring in range(RING_COUNT):
		var progress := float(ring) / float(RING_COUNT - 1)
		var radius := lerpf(TOP_RADIUS, BOTTOM_RADIUS, pow(progress, 0.82))
		var y := -NET_HEIGHT * progress
		for segment in range(SEGMENT_COUNT):
			var angle := TAU * float(segment) / float(SEGMENT_COUNT)
			var point := Vector3(cos(angle) * radius, y, sin(angle) * radius)
			_positions.append(point)
			_previous_positions.append(point)
			_anchors.append(point)

func _build_constraints() -> void:
	_constraint_a = PackedInt32Array()
	_constraint_b = PackedInt32Array()
	_rest_lengths = PackedFloat32Array()
	_render_edges.clear()
	for ring in range(RING_COUNT):
		for segment in range(SEGMENT_COUNT):
			var current := _index(ring, segment)
			var next_segment := _index(ring, (segment + 1) % SEGMENT_COUNT)
			_add_constraint(current, next_segment, true)
			if ring < RING_COUNT - 1:
				var below := _index(ring + 1, segment)
				var diagonal := _index(ring + 1, (segment + 1) % SEGMENT_COUNT)
				_add_constraint(current, below, true)
				_add_constraint(current, diagonal, true)

func _add_constraint(a: int, b: int, render_edge: bool) -> void:
	_constraint_a.append(a)
	_constraint_b.append(b)
	_rest_lengths.append(_positions[a].distance_to(_positions[b]))
	if render_edge:
		_render_edges.append(Vector2i(a, b))

func _build_renderer() -> void:
	_mesh = ImmediateMesh.new()
	_mesh_instance = MeshInstance3D.new()
	_mesh_instance.name = "DynamicNylonNet"
	_mesh_instance.mesh = _mesh
	_mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(_mesh_instance)
	_cord_material = StandardMaterial3D.new()
	_cord_material.albedo_color = Color(0.93, 0.97, 1.0, 0.96)
	_cord_material.roughness = 0.88
	_cord_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_cord_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_update_mesh()

func _solve_constraints() -> void:
	for constraint_index in range(_constraint_a.size()):
		var a := _constraint_a[constraint_index]
		var b := _constraint_b[constraint_index]
		var delta := _positions[b] - _positions[a]
		var distance := delta.length()
		if distance < 0.00001:
			continue
		var correction := delta * ((distance - _rest_lengths[constraint_index]) / distance)
		var a_pinned := a < SEGMENT_COUNT
		var b_pinned := b < SEGMENT_COUNT
		if a_pinned and not b_pinned:
			_positions[b] -= correction
		elif b_pinned and not a_pinned:
			_positions[a] += correction
		elif not a_pinned and not b_pinned:
			_positions[a] += correction * 0.5
			_positions[b] -= correction * 0.5

func _pin_top_ring() -> void:
	for index in range(SEGMENT_COUNT):
		_positions[index] = _anchors[index]
		_previous_positions[index] = _anchors[index]

func _collide_with_ball(step: float) -> void:
	if _ball == null or _ball.freeze:
		return
	var local_ball := to_local(_ball.global_position)
	if local_ball.y > 0.16 or local_ball.y < -0.72 or Vector2(local_ball.x, local_ball.z).length() > 0.5:
		return
	var total_correction := Vector3.ZERO
	var collision_count := 0
	var collision_radius := 0.12 + CORD_RADIUS
	for index in range(SEGMENT_COUNT, _positions.size()):
		var delta := _positions[index] - local_ball
		var distance := delta.length()
		if distance >= collision_radius or distance < 0.0001:
			continue
		var correction := delta.normalized() * (collision_radius - distance)
		_positions[index] += correction * 0.82
		total_correction += correction
		collision_count += 1
	if collision_count > 0:
		var local_force := -total_correction / float(collision_count) * (7.5 / maxf(step, 0.001))
		_ball.apply_central_force(global_transform.basis * local_force)

func _update_mesh() -> void:
	if _mesh == null:
		return
	_mesh.clear_surfaces()
	_mesh.surface_begin(Mesh.PRIMITIVE_LINES, _cord_material)
	for edge in _render_edges:
		_mesh.surface_add_vertex(_positions[edge.x])
		_mesh.surface_add_vertex(_positions[edge.y])
	_mesh.surface_end()

func _index(ring: int, segment: int) -> int:
	return ring * SEGMENT_COUNT + segment
