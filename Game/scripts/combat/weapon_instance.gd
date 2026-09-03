class_name WeaponInstance
extends RefCounted

var definition: WeaponDefinition
var loaded_ammo: int
var reserve_ammo: int

func _init(source_definition: WeaponDefinition) -> void:
	definition = source_definition
	loaded_ammo = source_definition.magazine_size if source_definition != null else 0
	reserve_ammo = source_definition.reserve_ammo if source_definition != null else 0
