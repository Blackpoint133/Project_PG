class_name LegInstance
extends RefCounted

var definition: LegDefinition
var ability_cooldown: float = 0.0

func _init(source_definition: LegDefinition) -> void:
	definition = source_definition
