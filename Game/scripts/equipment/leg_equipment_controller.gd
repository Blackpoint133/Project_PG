class_name LegEquipmentController
extends Node

signal legs_changed(definition: LegDefinition)
signal leg_ability_changed(ability_definition: LegAbilityDefinition)
signal leg_ability_requested(ability_definition: LegAbilityDefinition)

var current_instance: LegInstance
var current_definition: LegDefinition:
	get:
		return null if current_instance == null else current_instance.definition
var current_ability_definition: LegAbilityDefinition:
	get:
		var definition: LegDefinition = current_definition
		return null if definition == null else definition.ability_definition

func setup(definition: LegDefinition) -> void:
	current_instance = LegInstance.new(definition) if definition != null else null
	_emit_current_state()

func replace_leg_instance(instance: LegInstance) -> LegInstance:
	if instance == null or instance.definition == null:
		return null
	var outgoing_instance: LegInstance = current_instance
	current_instance = instance
	_emit_current_state()
	return outgoing_instance

func activate_ability() -> bool:
	var ability_definition: LegAbilityDefinition = current_ability_definition
	if ability_definition == null:
		return false
	leg_ability_requested.emit(ability_definition)
	return true

func _emit_current_state() -> void:
	legs_changed.emit(current_definition)
	leg_ability_changed.emit(current_ability_definition)
