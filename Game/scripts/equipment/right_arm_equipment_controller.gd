class_name RightArmEquipmentController
extends Node

signal right_arm_changed(definition: RightArmDefinition)
signal right_arm_ability_changed(ability_definition: RightArmAbilityDefinition)
signal right_arm_ability_requested(ability_definition: RightArmAbilityDefinition)

var _current_instance: RightArmInstance
var current_instance: RightArmInstance:
	get:
		return _current_instance
var current_definition: RightArmDefinition:
	get:
		return null if current_instance == null else current_instance.definition
var current_ability_definition: RightArmAbilityDefinition:
	get:
		var definition: RightArmDefinition = current_definition
		return null if definition == null else definition.ability_definition

func setup(definition: RightArmDefinition) -> void:
	_current_instance = RightArmInstance.new(definition) if definition != null else null
	_emit_current_state()

func replace_right_arm_instance(instance: RightArmInstance) -> RightArmInstance:
	if instance == null or instance.definition == null:
		return null
	var outgoing_instance: RightArmInstance = current_instance
	_current_instance = instance
	_emit_current_state()
	return outgoing_instance

func activate_ability() -> bool:
	var ability_definition: RightArmAbilityDefinition = current_ability_definition
	if ability_definition == null or current_instance == null:
		return false
	right_arm_ability_requested.emit(ability_definition)
	return true

func _emit_current_state() -> void:
	right_arm_changed.emit(current_definition)
	right_arm_ability_changed.emit(current_ability_definition)
