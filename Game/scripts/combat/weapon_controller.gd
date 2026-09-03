class_name WeaponController
extends Node

signal fired
signal reload_started
signal reload_completed
signal weapon_ammo_changed(loaded_ammo: int, reserve_ammo: int)
signal weapon_changed(definition: WeaponDefinition)
signal weapon_slots_changed(slot_1: WeaponInstance, slot_2: WeaponInstance, active_slot_index: int)

var _weapon_slots: Array[WeaponInstance] = [null, null]
var _active_slot_index: int = 0
var _fire_cooldown: float = 0.0
var _reload_timer: float = 0.0
var _is_reloading: bool = false
var _can_fire: bool = false

var weapon_definition: WeaponDefinition:
	get:
		return get_active_definition()

func setup(definition: WeaponDefinition) -> void:
	_weapon_slots = [null, null]
	_active_slot_index = 0
	_cancel_reload()
	_fire_cooldown = 0.0
	if definition != null:
		_weapon_slots[0] = WeaponInstance.new(definition)
	weapon_changed.emit(weapon_definition)
	weapon_ammo_changed.emit(get_loaded_ammo(), get_reserve_ammo())
	_emit_slot_state()

func select_slot(slot_index: int) -> bool:
	if slot_index < 0 or slot_index >= _weapon_slots.size() or _weapon_slots[slot_index] == null or slot_index == _active_slot_index:
		return false
	_cancel_reload()
	_fire_cooldown = 0.0
	_active_slot_index = slot_index
	weapon_changed.emit(weapon_definition)
	weapon_ammo_changed.emit(get_loaded_ammo(), get_reserve_ammo())
	_start_reload_if_empty()
	_emit_slot_state()
	return true

func replace_slot_instance(slot_index: int, instance: WeaponInstance) -> WeaponInstance:
	if slot_index < 0 or slot_index >= _weapon_slots.size() or instance == null:
		return null
	var outgoing: WeaponInstance = _weapon_slots[slot_index]
	if slot_index == _active_slot_index:
		_cancel_reload()
		_fire_cooldown = 0.0
	_weapon_slots[slot_index] = instance
	if slot_index == _active_slot_index:
		weapon_changed.emit(weapon_definition)
		weapon_ammo_changed.emit(get_loaded_ammo(), get_reserve_ammo())
		_start_reload_if_empty()
	_emit_slot_state()
	return outgoing

func get_slot_instance(slot_index: int) -> WeaponInstance:
	if slot_index < 0 or slot_index >= _weapon_slots.size():
		return null
	return _weapon_slots[slot_index]

func get_first_empty_slot() -> int:
	for slot_index: int in range(_weapon_slots.size()):
		if _weapon_slots[slot_index] == null:
			return slot_index
	return -1

func get_active_slot_index() -> int:
	return _active_slot_index

func get_active_definition() -> WeaponDefinition:
	var active_instance: WeaponInstance = _weapon_slots[_active_slot_index]
	return null if active_instance == null else active_instance.definition

func _emit_slot_state() -> void:
	weapon_slots_changed.emit(_weapon_slots[0], _weapon_slots[1], _active_slot_index)

func _process(delta: float) -> void:
	if _fire_cooldown > 0.0:
		_fire_cooldown = maxf(_fire_cooldown - delta, 0.0)
	if _is_reloading:
		_reload_timer -= delta
		if _reload_timer <= 0.0:
			_is_reloading = false
			_finish_reload()

func try_fire() -> void:
	var active_instance: WeaponInstance = _weapon_slots[_active_slot_index]
	if active_instance == null or not _can_fire or _is_reloading:
		return
	if active_instance.loaded_ammo <= 0:
		_start_reload()
		return
	if _fire_cooldown > 0.0:
		return
	active_instance.loaded_ammo -= 1
	_fire_cooldown = 1.0 / active_instance.definition.fire_rate
	fired.emit()
	weapon_ammo_changed.emit(active_instance.loaded_ammo, active_instance.reserve_ammo)
	if active_instance.loaded_ammo == 0:
		_start_reload()

func try_reload() -> void:
	_start_reload()

func _start_reload_if_empty() -> void:
	var active_instance: WeaponInstance = _weapon_slots[_active_slot_index]
	if active_instance == null or active_instance.loaded_ammo != 0:
		return
	_start_reload()

func _start_reload() -> void:
	var active_instance: WeaponInstance = _weapon_slots[_active_slot_index]
	if active_instance == null or _is_reloading or active_instance.loaded_ammo >= active_instance.definition.magazine_size or active_instance.reserve_ammo <= 0:
		return
	_is_reloading = true
	_reload_timer = active_instance.definition.reload_time
	reload_started.emit()

func _finish_reload() -> void:
	var active_instance: WeaponInstance = _weapon_slots[_active_slot_index]
	if active_instance == null:
		return
	var needed: int = active_instance.definition.magazine_size - active_instance.loaded_ammo
	var transfer: int = mini(needed, active_instance.reserve_ammo)
	active_instance.loaded_ammo += transfer
	active_instance.reserve_ammo -= transfer
	weapon_ammo_changed.emit(active_instance.loaded_ammo, active_instance.reserve_ammo)
	reload_completed.emit()

func _cancel_reload() -> void:
	_is_reloading = false
	_reload_timer = 0.0

func set_firing_enabled(enabled: bool) -> void:
	_can_fire = enabled

func is_reloading() -> bool:
	return _is_reloading

func uses_automatic_fire() -> bool:
	var definition: WeaponDefinition = get_active_definition()
	return definition != null and definition.automatic_fire

func get_display_name() -> String:
	var definition: WeaponDefinition = get_active_definition()
	return "" if definition == null else definition.display_name

func get_loaded_ammo() -> int:
	var active_instance: WeaponInstance = _weapon_slots[_active_slot_index]
	return 0 if active_instance == null else active_instance.loaded_ammo

func get_reserve_ammo() -> int:
	var active_instance: WeaponInstance = _weapon_slots[_active_slot_index]
	return 0 if active_instance == null else active_instance.reserve_ammo
