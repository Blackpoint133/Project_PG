class_name MissionController
extends Node

signal mission_state_changed(state: int, mission_id: String)
signal objective_changed(objective_text: String)
signal mission_activated(mission_id: String)
signal mission_completed(mission_id: String)
signal loot_case_ready(mission_id: String)
signal loot_case_opened(mission_id: String)
signal reward_collected(reward_id: String, collected_count: int, required_count: int)
signal reward_collection_completed(mission_id: String)

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
const COLLECT_EQUIPMENT_OBJECTIVE: String = "COLLECT THE EQUIPMENT"
const EQUIPMENT_COLLECTED_OBJECTIVE: String = "EQUIPMENT COLLECTED"
const SHOTGUN_REWARD_ID: String = "shotgun"
const SHIELD_LEFT_ARM_REWARD_ID: String = "shield_left_arm"
const HOOK_RIGHT_ARM_REWARD_ID: String = "hook_right_arm"
const KNEE_DASH_LEGS_REWARD_ID: String = "knee_dash_legs"
const REQUIRED_REWARD_COUNT: int = 4

var _state: int = MissionState.AVAILABLE
var _active_mission_id: String = ""
var _objective_text: String = FIND_RADIO_OBJECTIVE
var _loot_case_ready: bool = false
var _loot_case_opened: bool = false
var _shotgun_reward_collected: bool = false
var _shield_left_arm_reward_collected: bool = false
var _hook_right_arm_reward_collected: bool = false
var _knee_dash_legs_reward_collected: bool = false
var _collected_reward_count: int = 0

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

func mark_loot_case_opened(mission_id: String) -> bool:
	if _state != MissionState.COMPLETED or mission_id != _active_mission_id or not _loot_case_ready or _loot_case_opened:
		return false
	_loot_case_opened = true
	_objective_text = COLLECT_EQUIPMENT_OBJECTIVE
	objective_changed.emit(_objective_text)
	loot_case_opened.emit(_active_mission_id)
	return true

func register_reward_collected(reward_id: String) -> bool:
	if _state != MissionState.COMPLETED or _active_mission_id != DESTROY_HELICOPTER_ID or not _loot_case_opened:
		return false
	if not _is_valid_reward_id(reward_id) or _has_collected_reward(reward_id):
		return false
	_set_reward_collected(reward_id)
	_collected_reward_count += 1
	reward_collected.emit(reward_id, _collected_reward_count, REQUIRED_REWARD_COUNT)
	if _collected_reward_count == REQUIRED_REWARD_COUNT:
		_objective_text = EQUIPMENT_COLLECTED_OBJECTIVE
		objective_changed.emit(_objective_text)
		reward_collection_completed.emit(_active_mission_id)
	else:
		_objective_text = "%s (%d/%d)" % [COLLECT_EQUIPMENT_OBJECTIVE, _collected_reward_count, REQUIRED_REWARD_COUNT]
		objective_changed.emit(_objective_text)
	return true

func get_state() -> int:
	return _state

func get_active_mission_id() -> String:
	return _active_mission_id

func get_objective_text() -> String:
	return _objective_text

func get_collected_reward_count() -> int:
	return _collected_reward_count

func has_collected_reward(reward_id: String) -> bool:
	return _has_collected_reward(reward_id)

func _is_valid_reward_id(reward_id: String) -> bool:
	return reward_id == SHOTGUN_REWARD_ID or reward_id == SHIELD_LEFT_ARM_REWARD_ID or reward_id == HOOK_RIGHT_ARM_REWARD_ID or reward_id == KNEE_DASH_LEGS_REWARD_ID

func _has_collected_reward(reward_id: String) -> bool:
	match reward_id:
		SHOTGUN_REWARD_ID:
			return _shotgun_reward_collected
		SHIELD_LEFT_ARM_REWARD_ID:
			return _shield_left_arm_reward_collected
		HOOK_RIGHT_ARM_REWARD_ID:
			return _hook_right_arm_reward_collected
		KNEE_DASH_LEGS_REWARD_ID:
			return _knee_dash_legs_reward_collected
	return false

func _set_reward_collected(reward_id: String) -> void:
	match reward_id:
		SHOTGUN_REWARD_ID:
			_shotgun_reward_collected = true
		SHIELD_LEFT_ARM_REWARD_ID:
			_shield_left_arm_reward_collected = true
		HOOK_RIGHT_ARM_REWARD_ID:
			_hook_right_arm_reward_collected = true
		KNEE_DASH_LEGS_REWARD_ID:
			_knee_dash_legs_reward_collected = true
