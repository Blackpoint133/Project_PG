class_name BleedingStatusController
extends Node

var _damage_per_tick: int = 0
var _tick_interval: float = 0.0
var _remaining_tick_count: int = 0
var _next_tick_time: float = 0.0

func apply_bleeding(damage_per_tick: int, tick_interval: float, tick_count: int) -> bool:
	if damage_per_tick <= 0 or tick_interval <= 0.0 or tick_count <= 0:
		return false
	_damage_per_tick = damage_per_tick
	_tick_interval = tick_interval
	_remaining_tick_count = tick_count
	_next_tick_time = tick_interval
	return true

func advance(delta: float) -> int:
	if not is_active():
		return 0
	_next_tick_time -= maxf(delta, 0.0)
	var damage_due: int = 0
	while _remaining_tick_count > 0 and _next_tick_time <= 0.0:
		damage_due += _damage_per_tick
		_remaining_tick_count -= 1
		if _remaining_tick_count > 0:
			_next_tick_time += _tick_interval
		else:
			_next_tick_time = 0.0
	return damage_due

func is_active() -> bool:
	return _remaining_tick_count > 0

func clear() -> void:
	_damage_per_tick = 0
	_tick_interval = 0.0
	_remaining_tick_count = 0
	_next_tick_time = 0.0
