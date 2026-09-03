class_name LeftArmEquipmentController
extends Node

signal left_arm_changed(definition: LeftArmDefinition)
signal left_arm_ability_changed(ability_definition: LeftArmAbilityDefinition)
signal left_arm_ability_input_changed(ability_definition: LeftArmAbilityDefinition, is_pressed: bool)

var _current_instance: LeftArmInstance
var current_instance: LeftArmInstance:
	get:
		return _current_instance
var current_definition: LeftArmDefinition:
	get:
		return null if current_instance == null else current_instance.definition
var current_ability_definition: LeftArmAbilityDefinition:
	get:
		var definition: LeftArmDefinition = current_definition
		return null if definition == null else definition.ability_definition

var _ability_input_pressed: bool = false

func setup(definition: LeftArmDefinition) -> void:
	_current_instance = LeftArmInstance.new(definition) if definition != null else null
	_ability_input_pressed = false
	_emit_current_state()

func replace_left_arm_instance(instance: LeftArmInstance) -> LeftArmInstance:
	if instance == null or instance.definition == null:
		return null
	var outgoing_instance: LeftArmInstance = current_instance
	if _ability_input_pressed and current_ability_definition != null:
		left_arm_ability_input_changed.emit(current_ability_definition, false)
	_ability_input_pressed = false
	_current_instance = instance
	_emit_current_state()
	return outgoing_instance

func set_ability_input(is_pressed: bool) -> bool:
	var ability_definition: LeftArmAbilityDefinition = current_ability_definition
	if ability_definition == null:
		return false
	if _ability_input_pressed == is_pressed:
		return false
	_ability_input_pressed = is_pressed
	left_arm_ability_input_changed.emit(ability_definition, is_pressed)
	return true

func _emit_current_state() -> void:
	left_arm_changed.emit(current_definition)
	left_arm_ability_changed.emit(current_ability_definition)
