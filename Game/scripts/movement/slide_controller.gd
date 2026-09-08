class_name SlideController
extends Node

signal slide_state_changed(active: bool, cooldown_remaining: float)

const MINIMUM_ENTRY_SPEED: float = 260.0
const MINIMUM_INITIAL_SPEED: float = 600.0
const SLIDE_DURATION: float = 0.65
const SLIDE_DECELERATION: float = 720.0
const MINIMUM_ACTIVE_SPEED: float = 180.0
const SLIDE_COOLDOWN: float = 1.0

var _active: bool = false
var _slide_velocity: float = 0.0
var _remaining_duration: float = 0.0
var _cooldown_remaining: float = 0.0

func _ready() -> void:
	_emit_state()

func advance(delta: float) -> void:
	_cooldown_remaining = maxf(_cooldown_remaining - delta, 0.0)
	if _active:
		_remaining_duration = maxf(_remaining_duration - delta, 0.0)
		var slide_direction: float = signf(_slide_velocity)
		var slide_speed: float = maxf(absf(_slide_velocity) - SLIDE_DECELERATION * delta, MINIMUM_ACTIVE_SPEED)
		_slide_velocity = slide_direction * slide_speed
		if _remaining_duration <= 0.0:
			_finish_slide()
	_emit_state()

func try_start(horizontal_velocity: float, fallback_direction: int) -> bool:
	if _active or _cooldown_remaining > 0.0 or absf(horizontal_velocity) < MINIMUM_ENTRY_SPEED:
		return false
	var slide_direction: float = signf(horizontal_velocity)
	if slide_direction == 0.0:
		slide_direction = 1.0 if fallback_direction >= 0 else -1.0
	var initial_speed: float = maxf(absf(horizontal_velocity), MINIMUM_INITIAL_SPEED)
	_slide_velocity = slide_direction * initial_speed
	_remaining_duration = SLIDE_DURATION
	_active = true
	_emit_state()
	return true

func cancel_slide(start_cooldown: bool = true) -> void:
	if not _active:
		return
	_active = false
	_remaining_duration = 0.0
	if start_cooldown:
		_cooldown_remaining = maxf(_cooldown_remaining, SLIDE_COOLDOWN)
	_emit_state()

func is_active() -> bool:
	return _active

func is_ready() -> bool:
	return not _active and _cooldown_remaining <= 0.0

func get_horizontal_velocity() -> float:
	return _slide_velocity

func get_cooldown_remaining() -> float:
	return _cooldown_remaining

func _finish_slide() -> void:
	_active = false
	_remaining_duration = 0.0
	_cooldown_remaining = maxf(_cooldown_remaining, SLIDE_COOLDOWN)

func _emit_state() -> void:
	slide_state_changed.emit(_active, _cooldown_remaining)
