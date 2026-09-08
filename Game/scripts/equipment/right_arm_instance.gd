class_name RightArmInstance
extends RefCounted

var definition: RightArmDefinition
var ability_cooldown_remaining: float = 0.0

func _init(source_definition: RightArmDefinition) -> void:
	definition = source_definition
