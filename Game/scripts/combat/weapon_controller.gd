class_name WeaponController
extends Node

signal fired
signal reload_started
signal reload_completed
signal weapon_ammo_changed(loaded_ammo: int, reserve_ammo: int)
signal weapon_changed(definition: WeaponDefinition)

class AmmoState:
	var loaded_ammo: int
	var reserve_ammo: int

	func _init(initial_loaded_ammo: int, initial_reserve_ammo: int) -> void:
		loaded_ammo = initial_loaded_ammo
		reserve_ammo = initial_reserve_ammo

var weapon_definition: WeaponDefinition
var _loaded_ammo: int = 0
var _reserve_ammo: int = 0
var _fire_cooldown: float = 0.0
var _reload_timer: float = 0.0
var _is_reloading: bool = false
var _can_fire: bool = false
var _ammo_states: Dictionary[WeaponDefinition, AmmoState] = {}

func setup(definition: WeaponDefinition) -> void:
	_ammo_states.clear()
	weapon_definition = null
	equip_weapon(definition)

func equip_weapon(definition: WeaponDefinition) -> void:
	if definition == null:
		return
	if weapon_definition == definition:
		return
	if weapon_definition != null:
		_store_current_ammo()
	_cancel_reload()
	_fire_cooldown = 0.0
	weapon_definition = definition
	var ammo_state: AmmoState
	if _ammo_states.has(definition):
		ammo_state = _ammo_states[definition] as AmmoState
	else:
		ammo_state = AmmoState.new(definition.magazine_size, definition.reserve_ammo)
		_ammo_states[definition] = ammo_state
	_loaded_ammo = ammo_state.loaded_ammo
	_reserve_ammo = ammo_state.reserve_ammo
	weapon_changed.emit(weapon_definition)
	weapon_ammo_changed.emit(_loaded_ammo, _reserve_ammo)

func _store_current_ammo() -> void:
	var ammo_state: AmmoState = _ammo_states[weapon_definition] as AmmoState
	ammo_state.loaded_ammo = _loaded_ammo
	ammo_state.reserve_ammo = _reserve_ammo

func _cancel_reload() -> void:
	_is_reloading = false
	_reload_timer = 0.0

func set_firing_enabled(enabled: bool) -> void:
	_can_fire = enabled

func _process(delta: float) -> void:
	if _fire_cooldown > 0.0:
		_fire_cooldown = maxf(_fire_cooldown - delta, 0.0)
	if _is_reloading:
		_reload_timer -= delta
		if _reload_timer <= 0.0:
			_is_reloading = false
			_finish_reload()

func try_fire() -> void:
	if weapon_definition == null or not _can_fire or _is_reloading or _loaded_ammo <= 0 or _fire_cooldown > 0.0:
		return
	_loaded_ammo -= 1
	_fire_cooldown = 1.0 / weapon_definition.fire_rate
	fired.emit()
	weapon_ammo_changed.emit(_loaded_ammo, _reserve_ammo)

func try_reload() -> void:
	if _is_reloading or _loaded_ammo >= weapon_definition.magazine_size or _reserve_ammo <= 0:
		return
	_is_reloading = true
	_reload_timer = weapon_definition.reload_time
	reload_started.emit()

func _finish_reload() -> void:
	var needed := weapon_definition.magazine_size - _loaded_ammo
	var transfer := mini(needed, _reserve_ammo)
	_loaded_ammo += transfer
	_reserve_ammo -= transfer
	weapon_ammo_changed.emit(_loaded_ammo, _reserve_ammo)
	reload_completed.emit()

func is_reloading() -> bool:
	return _is_reloading

func uses_automatic_fire() -> bool:
	return weapon_definition != null and weapon_definition.automatic_fire

func get_display_name() -> String:
	return "" if weapon_definition == null else weapon_definition.display_name

func get_loaded_ammo() -> int:
	return _loaded_ammo

func get_reserve_ammo() -> int:
	return _reserve_ammo
