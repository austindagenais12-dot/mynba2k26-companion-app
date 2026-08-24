extends RigidBody3D

signal surface_impact(surface: String, impulse: float)

const AIR_DENSITY := 1.225
const BALL_RADIUS := 0.12
const CROSS_SECTION := PI * BALL_RADIUS * BALL_RADIUS
const DRAG_COEFFICIENT := 0.54
const GRAVITY := 9.80665
const SPIN_DECAY := 0.19
const MAX_LIFT_COEFFICIENT := 0.24

var _net_center := Vector3.ZERO
var _net_enabled := false
var _impact_cooldown := 0.0

func configure_realistic_physics() -> void:
	contact_monitor = true
	max_contacts_reported = 8
	continuous_cd = true
	can_sleep = true
	linear_damp = 0.0
	angular_damp = 0.04
	gravity_scale = 1.0

func set_net_region(center: Vector3) -> void:
	_net_center = center
	_net_enabled = true

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if freeze:
		return
	var step := state.step
	_impact_cooldown = maxf(0.0, _impact_cooldown - step)
	var velocity := state.linear_velocity
	var spin := state.angular_velocity
	velocity += aerodynamic_acceleration(velocity, spin, mass) * step
	spin *= exp(-SPIN_DECAY * step)

	if _net_enabled:
		var position := state.transform.origin
		var below_rim := _net_center.y - position.y
		var horizontal_distance := Vector2(position.x - _net_center.x, position.z - _net_center.z).length()
		if below_rim > -0.08 and below_rim < 0.68 and horizontal_distance < 0.34:
			var depth := 1.0 - clampf(horizontal_distance / 0.34, 0.0, 1.0)
			var vertical_weight := sin(clampf((below_rim + 0.08) / 0.76, 0.0, 1.0) * PI)
			var net_weight := depth * vertical_weight
			velocity *= exp(-2.45 * net_weight * step)
			var toward_center := Vector3(_net_center.x - position.x, 0.0, _net_center.z - position.z)
			velocity += toward_center * (4.2 * net_weight * step)

	state.linear_velocity = velocity
	state.angular_velocity = spin
	_report_contacts(state)

func _report_contacts(state: PhysicsDirectBodyState3D) -> void:
	if _impact_cooldown > 0.0:
		return
	var strongest_impulse := 0.0
	var strongest_surface := ""
	for index in range(state.get_contact_count()):
		var collider := state.get_contact_collider_object(index)
		if collider == null:
			continue
		var impulse := state.get_contact_impulse(index).length()
		if impulse <= strongest_impulse:
			continue
		strongest_impulse = impulse
		var collider_name := str(collider.name)
		if "Rim" in collider_name:
			strongest_surface = "rim"
		elif "Backboard" in collider_name or "Board" in collider_name:
			strongest_surface = "backboard"
		elif "Court" in collider_name:
			strongest_surface = "court"
		else:
			strongest_surface = "structure"
	if strongest_impulse > 0.16:
		_impact_cooldown = 0.045
		surface_impact.emit(strongest_surface, strongest_impulse)

static func aerodynamic_acceleration(velocity: Vector3, spin: Vector3, body_mass := 0.62) -> Vector3:
	var speed := velocity.length()
	if speed < 0.05:
		return Vector3.ZERO
	var dynamic_pressure := 0.5 * AIR_DENSITY * speed * speed
	var drag_force := -velocity.normalized() * dynamic_pressure * DRAG_COEFFICIENT * CROSS_SECTION
	var spin_ratio := BALL_RADIUS * spin.length() / maxf(speed, 0.05)
	var lift_coefficient := clampf(spin_ratio * 0.32, 0.0, MAX_LIFT_COEFFICIENT)
	var magnus_direction := spin.cross(velocity)
	var lift_force := Vector3.ZERO
	if magnus_direction.length_squared() > 0.00001:
		lift_force = magnus_direction.normalized() * dynamic_pressure * lift_coefficient * CROSS_SECTION
	return (drag_force + lift_force) / maxf(body_mass, 0.05)

static func predict_position(origin: Vector3, initial_velocity: Vector3, spin: Vector3, duration: float, steps := 120, body_mass := 0.62) -> Vector3:
	var position := origin
	var velocity := initial_velocity
	var angular_velocity := spin
	var safe_steps := maxi(8, steps)
	var step := maxf(duration, 0.05) / float(safe_steps)
	for _index in range(safe_steps):
		velocity += Vector3.DOWN * GRAVITY * step
		velocity += aerodynamic_acceleration(velocity, angular_velocity, body_mass) * step
		angular_velocity *= exp(-SPIN_DECAY * step)
		position += velocity * step
	return position

static func solve_launch_velocity(origin: Vector3, target: Vector3, flight_time: float, spin: Vector3, body_mass := 0.62) -> Vector3:
	var safe_time := maxf(0.42, flight_time)
	var displacement := target - origin
	var velocity := displacement / safe_time + Vector3.UP * (GRAVITY * safe_time * 0.5)
	for _iteration in range(7):
		var predicted := predict_position(origin, velocity, spin, safe_time, 100, body_mass)
		var miss := target - predicted
		velocity += miss / safe_time * 0.78
	return velocity
