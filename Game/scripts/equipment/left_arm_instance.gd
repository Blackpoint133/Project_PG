class_name LeftArmInstance
extends RefCounted

var definition: LeftArmDefinition
var ability_energy: float = 0.0
var ability_recharge_delay_remaining: float = 0.0
var ability_release_required: bool = false

func _init(source_definition: LeftArmDefinition) -> void:
	definition = source_definition
	if definition != null and definition.ability_definition != null:
		var maximum_energy: float = maxf(definition.ability_definition.max_energy, 0.0)
		ability_energy = maximum_energy
