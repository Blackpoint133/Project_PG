class_name LeftArmInstance
extends RefCounted

var definition: LeftArmDefinition
var ability_charge: float = 0.0

func _init(source_definition: LeftArmDefinition) -> void:
	definition = source_definition
	if definition != null and definition.ability_definition != null:
		ability_charge = maxf(definition.ability_definition.max_charge, 0.0)
