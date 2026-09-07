class_name PlayerDamageReceiver
extends Node

signal health_changed(current_health: float, maximum_health: float)
signal damaged(amount: float)
signal defeated

const MAXIMUM_HEALTH: float = 100.0

var _current_health: float = MAXIMUM_HEALTH

func get_current_health() -> float:
	return _current_health

func get_maximum_health() -> float:
	return MAXIMUM_HEALTH

func apply_damage(amount: float) -> float:
	var safe_damage: float = maxf(amount, 0.0)
	if safe_damage <= 0.0 or _current_health <= 0.0:
		return 0.0
	var applied_damage: float = minf(safe_damage, _current_health)
	_current_health = clampf(_current_health - applied_damage, 0.0, MAXIMUM_HEALTH)
	damaged.emit(applied_damage)
	health_changed.emit(_current_health, MAXIMUM_HEALTH)
	if _current_health <= 0.0:
		defeated.emit()
	return applied_damage
