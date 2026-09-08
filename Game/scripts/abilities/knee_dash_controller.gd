class_name KneeDashController
extends Node2D

signal dash_started(direction: Vector2)
signal target_hit(target: Node, damage: int)
signal dash_ended

var _is_active: bool = false
var _remaining_duration: float = 0.0
var _dash_direction: Vector2 = Vector2.RIGHT
var _dash_velocity: Vector2 = Vector2.ZERO
var _ability_definition: LegAbilityDefinition
var _hit_targets: Array[Node] = []

func start_dash(ability_definition: LegAbilityDefinition, direction: Vector2) -> bool:
	if ability_definition == null or ability_definition.ability_id != "knee_dash" or _is_active:
		return false
	if direction.length_squared() <= 0.0:
		return false
	_ability_definition = ability_definition
	_dash_direction = direction.normalized()
	_dash_velocity = _dash_direction * ability_definition.dash_speed
	_remaining_duration = ability_definition.dash_duration
	_hit_targets.clear()
	_is_active = true
	dash_started.emit(_dash_direction)
	return true

func advance(delta: float) -> void:
	if not _is_active:
		return
	_remaining_duration = maxf(_remaining_duration - delta, 0.0)
	if _remaining_duration <= 0.0:
		_end_dash()

func process_contact(contact: Node) -> void:
	if not _is_active or _ability_definition == null or contact == null or not is_instance_valid(contact):
		return
	var collision_object: CollisionObject2D = contact as CollisionObject2D
	if collision_object == null or (collision_object.collision_layer & 4) == 0:
		return
	if not contact.has_method(&"take_damage") or _hit_targets.has(contact):
		return
	_hit_targets.append(contact)
	contact.call(&"take_damage", _ability_definition.contact_damage)
	if (collision_object.collision_layer & 4) != 0 and contact.has_method(&"apply_bleeding"):
		contact.call(
			&"apply_bleeding",
			_ability_definition.bleed_damage_per_tick,
			_ability_definition.bleed_tick_interval,
			_ability_definition.bleed_tick_count
		)
	if contact.has_method(&"apply_knockback"):
		var impulse: Vector2 = _dash_direction * _ability_definition.knockback_strength
		contact.call(&"apply_knockback", impulse)
	target_hit.emit(contact, _ability_definition.contact_damage)

func cancel_dash() -> void:
	if not _is_active:
		return
	_end_dash()

func is_active() -> bool:
	return _is_active

func get_dash_velocity() -> Vector2:
	return _dash_velocity

func get_dash_direction() -> Vector2:
	return _dash_direction

func _end_dash() -> void:
	_is_active = false
	_remaining_duration = 0.0
	_dash_velocity = Vector2.ZERO
	dash_ended.emit()
