class_name WeaponController
extends Node

signal fired
signal reload_started
signal reload_completed
signal weapon_ammo_changed(loaded_ammo: int, reserve_ammo: int)

var weapon_definition: WeaponDefinition
var _loaded_ammo := 0
var _reserve_ammo := 0
var _fire_cooldown := 0.0
var _reload_timer := 0.0
var _is_reloading := false
var _can_fire := false
var loaded_ammo := 0
var reserve_ammo := 0

func setup(definition: WeaponDefinition) -> void:
	weapon_definition = definition
	loaded_ammo = definition.magazine_size
	reserve_ammo = definition.reserve_ammo
	weapon_ammo_changed.emit(loaded_ammo, reserve_ammo)

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
	if not _can_fire or _is_reloading or loaded_ammo <= 0 or _fire_cooldown > 0.0:
		return
	loaded_ammo -= 1
	_fire_cooldown = 1.0 / weapon_definition.fire_rate
	fired.emit()
	weapon_ammo_changed.emit(loaded_ammo, reserve_ammo)

func try_reload() -> void:
	if _is_reloading or loaded_ammo >= weapon_definition.magazine_size or reserve_ammo <= 0:
		return
	_is_reloading = true
	_reload_timer = weapon_definition.reload_time
	reload_started.emit()

func _finish_reload() -> void:
	var needed := weapon_definition.magazine_size - loaded_ammo
	var transfer := mini(needed, reserve_ammo)
	loaded_ammo += transfer
	reserve_ammo -= transfer
	weapon_ammo_changed.emit(loaded_ammo, reserve_ammo)
	reload_completed.emit()

func is_reloading() -> bool:
	return _is_reloading
