class_name ShieldController
extends Node2D

signal shield_state_changed(available: bool, active: bool, current_energy: float, maximum_energy: float, waiting_for_recharge: bool, release_required: bool)

@onready var shield_area: Area2D = $ShieldArea
@onready var shield_fill: Polygon2D = $ShieldFill
@onready var shield_outline: Line2D = $ShieldOutline

var _left_arm_instance: LeftArmInstance
var _input_pressed: bool = false
var _is_active: bool = false

func set_left_arm_instance(instance: LeftArmInstance) -> void:
	if _is_active:
		_deactivate()
	_left_arm_instance = instance
	_input_pressed = false
	_apply_presentation(false)
	_emit_state()

func set_input_pressed(is_pressed: bool) -> void:
	if _input_pressed == is_pressed:
		return
	_input_pressed = is_pressed
	if not is_pressed:
		if _is_active:
			_deactivate()
		var ability_definition: LeftArmAbilityDefinition = _get_ability_definition()
		if ability_definition != null and _left_arm_instance != null:
			_left_arm_instance.ability_release_required = false
			_start_recharge_delay()
		_emit_state()
		return
	if _can_activate():
		_is_active = true
		_apply_presentation(true)
	_emit_state()

func advance(delta: float) -> void:
	var ability_definition: LeftArmAbilityDefinition = _get_ability_definition()
	if ability_definition == null or _left_arm_instance == null:
		return
	var maximum_energy: float = maxf(ability_definition.max_energy, 0.0)
	_left_arm_instance.ability_energy = clampf(_left_arm_instance.ability_energy, 0.0, maximum_energy)
	_left_arm_instance.ability_recharge_delay_remaining = maxf(_left_arm_instance.ability_recharge_delay_remaining, 0.0)
	if _is_active:
		_left_arm_instance.ability_energy = maxf(_left_arm_instance.ability_energy - ability_definition.active_drain_per_second * delta, 0.0)
		if _left_arm_instance.ability_energy <= 0.0:
			_left_arm_instance.ability_energy = 0.0
			_left_arm_instance.ability_release_required = true
			_deactivate()
			_start_recharge_delay()
		_emit_state()
		return
	if _left_arm_instance.ability_recharge_delay_remaining > 0.0:
		_left_arm_instance.ability_recharge_delay_remaining = maxf(_left_arm_instance.ability_recharge_delay_remaining - delta, 0.0)
		if _left_arm_instance.ability_recharge_delay_remaining > 0.0:
			_emit_state()
			return
	if not _input_pressed and not _left_arm_instance.ability_release_required and _left_arm_instance.ability_energy < maximum_energy:
		_left_arm_instance.ability_energy = minf(_left_arm_instance.ability_energy + ability_definition.recharge_per_second * delta, maximum_energy)
	_emit_state()

func is_active() -> bool:
	return _is_active

func get_current_energy() -> float:
	return 0.0 if _left_arm_instance == null else _left_arm_instance.ability_energy

func get_maximum_energy() -> float:
	var ability_definition: LeftArmAbilityDefinition = _get_ability_definition()
	return 0.0 if ability_definition == null else maxf(ability_definition.max_energy, 0.0)

func is_waiting_for_recharge() -> bool:
	return _left_arm_instance != null and _left_arm_instance.ability_recharge_delay_remaining > 0.0

func requires_release() -> bool:
	return _left_arm_instance != null and _left_arm_instance.ability_release_required

func _get_ability_definition() -> LeftArmAbilityDefinition:
	if _left_arm_instance == null or _left_arm_instance.definition == null:
		return null
	return _left_arm_instance.definition.ability_definition

func _can_activate() -> bool:
	var ability_definition: LeftArmAbilityDefinition = _get_ability_definition()
	return ability_definition != null and ability_definition.ability_id == "shield" and not requires_release() and get_current_energy() > 0.0

func _start_recharge_delay() -> void:
	var ability_definition: LeftArmAbilityDefinition = _get_ability_definition()
	if ability_definition == null or _left_arm_instance == null:
		return
	_left_arm_instance.ability_recharge_delay_remaining = maxf(ability_definition.recharge_delay, 0.0)

func _deactivate() -> void:
	_is_active = false
	_apply_presentation(false)

func _apply_presentation(active: bool) -> void:
	shield_area.collision_layer = 64 if active else 0
	shield_area.monitoring = active
	shield_fill.visible = active
	shield_outline.visible = active

func _emit_state() -> void:
	var ability_definition: LeftArmAbilityDefinition = _get_ability_definition()
	var available: bool = ability_definition != null and ability_definition.ability_id == "shield"
	var maximum_energy: float = 0.0 if ability_definition == null else maxf(ability_definition.max_energy, 0.0)
	shield_state_changed.emit(available, _is_active, get_current_energy(), maximum_energy, is_waiting_for_recharge(), requires_release())
