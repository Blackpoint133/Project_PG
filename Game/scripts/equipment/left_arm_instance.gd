class_name LeftArmInstance
extends RefCounted

var definition: LeftArmDefinition
var ability_charge: float = 0.0
var ability_cooldown_remaining: float = 0.0

func _init(source_definition: LeftArmDefinition) -> void:
	definition = source_definition
	ability_charge = 0.0
