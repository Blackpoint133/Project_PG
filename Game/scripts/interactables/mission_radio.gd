class_name MissionRadio
extends CharacterBody2D

signal mission_activation_requested(mission_id: String)

@export var mission_id: String = "destroy_helicopter"
var _available: bool = true

func get_interaction_prompt(_actor: Node) -> String:
	if not _available:
		return ""
	return "F: USE RADIO"

func interact(_actor: Node) -> void:
	if not _available:
		return
	mission_activation_requested.emit(mission_id)

func set_available(available: bool) -> void:
	_available = available

func is_available() -> bool:
	return _available
