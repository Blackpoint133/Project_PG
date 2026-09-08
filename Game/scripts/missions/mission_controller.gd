class_name MissionController
extends Node

signal mission_state_changed(state: int, mission_id: String)
signal objective_changed(objective_text: String)
signal mission_activated(mission_id: String)
signal mission_completed(mission_id: String)
signal loot_case_ready(mission_id: String)

enum MissionState {
	AVAILABLE,
	ACTIVE,
	COMPLETED,
}

const DESTROY_HELICOPTER_ID: String = "destroy_helicopter"
const FIND_RADIO_OBJECTIVE: String = "FIND THE RADIO"
const DESTROY_HELICOPTER_OBJECTIVE: String = "DESTROY THE HELICOPTER"
const HELICOPTER_DESTROYED_OBJECTIVE: String = "HELICOPTER DESTROYED"
const OPEN_LOOT_CASE_OBJECTIVE: String = "OPEN THE LOOT CASE"

var _state: int = MissionState.AVAILABLE
var _active_mission_id: String = ""
var _objective_text: String = FIND_RADIO_OBJECTIVE
var _loot_case_ready: bool = false

func _ready() -> void:
	mission_state_changed.emit(_state, _active_mission_id)
	objective_changed.emit(_objective_text)

func activate_mission(mission_id: String) -> bool:
	if mission_id.is_empty() or _state != MissionState.AVAILABLE:
		return false
	if mission_id != DESTROY_HELICOPTER_ID:
		return false
	_active_mission_id = mission_id
	_state = MissionState.ACTIVE
	_objective_text = DESTROY_HELICOPTER_OBJECTIVE
	mission_state_changed.emit(_state, _active_mission_id)
	objective_changed.emit(_objective_text)
	mission_activated.emit(_active_mission_id)
	return true

func complete_mission(mission_id: String) -> bool:
	if _state != MissionState.ACTIVE or mission_id != _active_mission_id:
		return false
	_state = MissionState.COMPLETED
	_objective_text = HELICOPTER_DESTROYED_OBJECTIVE
	mission_state_changed.emit(_state, _active_mission_id)
	objective_changed.emit(_objective_text)
	mission_completed.emit(_active_mission_id)
	return true

func mark_loot_case_ready(mission_id: String) -> bool:
	if _state != MissionState.COMPLETED or mission_id != _active_mission_id or _loot_case_ready:
		return false
	_loot_case_ready = true
	_objective_text = OPEN_LOOT_CASE_OBJECTIVE
	objective_changed.emit(_objective_text)
	loot_case_ready.emit(_active_mission_id)
	return true

func get_state() -> int:
	return _state

func get_active_mission_id() -> String:
	return _active_mission_id

func get_objective_text() -> String:
	return _objective_text
