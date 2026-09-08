class_name JetpackController
extends Node

signal jetpack_state_changed(current_heat: float, maximum_heat: float, overheated: bool, active: bool)

const MAXIMUM_HEAT: float = 100.0
const HEAT_GAIN_PER_SECOND: float = 40.0
const GROUNDED_COOLING_PER_SECOND: float = 50.0

var _current_heat: float = 0.0
var _overheated: bool = false
var _active: bool = false

func _ready() -> void:
	_emit_state()

func advance(delta: float, grounded: bool, thrust_requested: bool) -> bool:
	_active = false
	if grounded:
		_current_heat = maxf(_current_heat - GROUNDED_COOLING_PER_SECOND * delta, 0.0)
		if _current_heat <= 0.0:
			_current_heat = 0.0
			_overheated = false
	else:
		if thrust_requested and not _overheated:
			_active = true
			_current_heat = minf(_current_heat + HEAT_GAIN_PER_SECOND * delta, MAXIMUM_HEAT)
			if _current_heat >= MAXIMUM_HEAT:
				_current_heat = MAXIMUM_HEAT
				_overheated = true
				_active = false
	_emit_state()
	return _active

func get_current_heat() -> float:
	return _current_heat

func get_maximum_heat() -> float:
	return MAXIMUM_HEAT

func is_overheated() -> bool:
	return _overheated

func is_active() -> bool:
	return _active

func _emit_state() -> void:
	jetpack_state_changed.emit(_current_heat, MAXIMUM_HEAT, _overheated, _active)
