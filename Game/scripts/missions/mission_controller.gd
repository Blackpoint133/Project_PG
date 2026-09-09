class_name MissionController
extends Node

signal mission_state_changed(state: int, mission_id: String)
signal objective_changed(objective_text: String)
signal mission_activated(mission_id: String)
signal mission_completed(mission_id: String)
signal loot_case_ready(mission_id: String)
signal loot_case_opened(mission_id: String)
signal reward_collected(reward_id: StringName, collected_count: int, required_count: int)
signal reward_collection_completed(mission_id: String)
signal mercenary_encounter_started(mission_id: String)
signal mercenary_defeated(enemy_id: StringName, defeated_count: int, required_count: int)
signal mercenary_encounter_completed(mission_id: String)
signal extraction_available(mission_id: String)
signal extraction_completed(mission_id: String)

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
const SHOTGUN_REWARD_ID: StringName = &"shotgun"
const SHIELD_LEFT_ARM_REWARD_ID: StringName = &"shield_left_arm"
const HOOK_RIGHT_ARM_REWARD_ID: StringName = &"hook_right_arm"
const KNEE_DASH_LEGS_REWARD_ID: StringName = &"knee_dash_legs"
const REQUIRED_REWARD_COUNT: int = 4
const UPPER_RANGED_MERCENARY_ID: StringName = &"upper_ranged"
const MID_RANGED_MERCENARY_ID: StringName = &"mid_ranged"
const HEAVY_MERCENARY_ID: StringName = &"heavy"
const REQUIRED_MERCENARY_COUNT: int = 3
const DEFEAT_ENEMIES_OBJECTIVE: String = "DEFEAT THE ENEMIES"
const REACH_EXTRACTION_OBJECTIVE: String = "REACH THE EXTRACTION"
const MISSION_COMPLETE_OBJECTIVE: String = "MISSION COMPLETE"

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
var _mercenary_encounter_started: bool = false
var _mercenary_encounter_completed: bool = false
var _upper_ranged_mercenary_defeated: bool = false
var _mid_ranged_mercenary_defeated: bool = false
var _heavy_mercenary_defeated: bool = false
var _defeated_mercenary_count: int = 0
var _extraction_is_available: bool = false
var _extraction_is_completed: bool = false

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
	_objective_text = _format_reward_progress(0)
	objective_changed.emit(_objective_text)
	loot_case_opened.emit(_active_mission_id)
	return true

func register_reward_collected(mission_id: String, reward_id: StringName) -> bool:
	if _state != MissionState.COMPLETED or mission_id != _active_mission_id or mission_id != DESTROY_HELICOPTER_ID or not _loot_case_opened:
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
		_objective_text = _format_reward_progress(_collected_reward_count)
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

func has_collected_reward(reward_id: StringName) -> bool:
	return _has_collected_reward(reward_id)

func start_mercenary_encounter(mission_id: String) -> bool:
	if _state != MissionState.COMPLETED or mission_id != _active_mission_id or mission_id != DESTROY_HELICOPTER_ID:
		return false
	if not _loot_case_opened or _collected_reward_count != REQUIRED_REWARD_COUNT:
		return false
	if _mercenary_encounter_started or _mercenary_encounter_completed:
		return false
	_mercenary_encounter_started = true
	_objective_text = _format_mercenary_progress(0)
	objective_changed.emit(_objective_text)
	mercenary_encounter_started.emit(_active_mission_id)
	return true

func register_mercenary_defeated(mission_id: String, enemy_id: StringName) -> bool:
	if _state != MissionState.COMPLETED or mission_id != _active_mission_id or mission_id != DESTROY_HELICOPTER_ID:
		return false
	if not _mercenary_encounter_started or _mercenary_encounter_completed:
		return false
	if not _is_valid_mercenary_id(enemy_id) or _has_defeated_mercenary(enemy_id):
		return false
	_set_mercenary_defeated(enemy_id)
	_defeated_mercenary_count += 1
	mercenary_defeated.emit(enemy_id, _defeated_mercenary_count, REQUIRED_MERCENARY_COUNT)
	if _defeated_mercenary_count == REQUIRED_MERCENARY_COUNT:
		_mercenary_encounter_completed = true
		_objective_text = REACH_EXTRACTION_OBJECTIVE
		objective_changed.emit(_objective_text)
		mercenary_encounter_completed.emit(_active_mission_id)
	else:
		_objective_text = _format_mercenary_progress(_defeated_mercenary_count)
		objective_changed.emit(_objective_text)
	return true

func is_mercenary_encounter_started() -> bool:
	return _mercenary_encounter_started

func is_mercenary_encounter_completed() -> bool:
	return _mercenary_encounter_completed

func make_extraction_available(mission_id: String) -> bool:
	if _state != MissionState.COMPLETED or mission_id != _active_mission_id or mission_id != DESTROY_HELICOPTER_ID:
		return false
	if not _mercenary_encounter_started or not _mercenary_encounter_completed or _defeated_mercenary_count != REQUIRED_MERCENARY_COUNT:
		return false
	if _extraction_is_available or _extraction_is_completed:
		return false
	_extraction_is_available = true
	extraction_available.emit(_active_mission_id)
	return true

func complete_extraction(mission_id: String) -> bool:
	if _state != MissionState.COMPLETED or mission_id != _active_mission_id or mission_id != DESTROY_HELICOPTER_ID:
		return false
	if not _mercenary_encounter_completed or not _extraction_is_available or _extraction_is_completed:
		return false
	_extraction_is_completed = true
	_objective_text = MISSION_COMPLETE_OBJECTIVE
	objective_changed.emit(_objective_text)
	extraction_completed.emit(_active_mission_id)
	return true

func is_extraction_available() -> bool:
	return _extraction_is_available

func is_extraction_completed() -> bool:
	return _extraction_is_completed

func _is_valid_reward_id(reward_id: StringName) -> bool:
	return reward_id == SHOTGUN_REWARD_ID or reward_id == SHIELD_LEFT_ARM_REWARD_ID or reward_id == HOOK_RIGHT_ARM_REWARD_ID or reward_id == KNEE_DASH_LEGS_REWARD_ID

func _has_collected_reward(reward_id: StringName) -> bool:
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

func _set_reward_collected(reward_id: StringName) -> void:
	match reward_id:
		SHOTGUN_REWARD_ID:
			_shotgun_reward_collected = true
		SHIELD_LEFT_ARM_REWARD_ID:
			_shield_left_arm_reward_collected = true
		HOOK_RIGHT_ARM_REWARD_ID:
			_hook_right_arm_reward_collected = true
		KNEE_DASH_LEGS_REWARD_ID:
			_knee_dash_legs_reward_collected = true

func _format_reward_progress(collected_count: int) -> String:
	return "%s (%d/%d)" % [COLLECT_EQUIPMENT_OBJECTIVE, collected_count, REQUIRED_REWARD_COUNT]

func _format_mercenary_progress(defeated_count: int) -> String:
	return "%s (%d/%d)" % [DEFEAT_ENEMIES_OBJECTIVE, defeated_count, REQUIRED_MERCENARY_COUNT]

func _is_valid_mercenary_id(enemy_id: StringName) -> bool:
	return enemy_id == UPPER_RANGED_MERCENARY_ID or enemy_id == MID_RANGED_MERCENARY_ID or enemy_id == HEAVY_MERCENARY_ID

func _has_defeated_mercenary(enemy_id: StringName) -> bool:
	match enemy_id:
		UPPER_RANGED_MERCENARY_ID:
			return _upper_ranged_mercenary_defeated
		MID_RANGED_MERCENARY_ID:
			return _mid_ranged_mercenary_defeated
		HEAVY_MERCENARY_ID:
			return _heavy_mercenary_defeated
	return false

func _set_mercenary_defeated(enemy_id: StringName) -> void:
	match enemy_id:
		UPPER_RANGED_MERCENARY_ID:
			_upper_ranged_mercenary_defeated = true
		MID_RANGED_MERCENARY_ID:
			_mid_ranged_mercenary_defeated = true
		HEAVY_MERCENARY_ID:
			_heavy_mercenary_defeated = true
