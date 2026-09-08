extends Node2D

const WORLD_LOOT_CASE_SCENE: PackedScene = preload("res://scenes/interactables/world_loot_case.tscn")
const SHOTGUN_PICKUP_SCENE: PackedScene = preload("res://scenes/equipment/world_weapon_pickup.tscn")
const SHIELD_PICKUP_SCENE: PackedScene = preload("res://scenes/equipment/world_left_arm_pickup.tscn")
const HOOK_PICKUP_SCENE: PackedScene = preload("res://scenes/equipment/world_right_arm_pickup.tscn")
const LEGS_PICKUP_SCENE: PackedScene = preload("res://scenes/equipment/world_leg_pickup.tscn")
const SHOTGUN_DEFINITION: WeaponDefinition = preload("res://resources/weapons/shotgun.tres")
const SHIELD_DEFINITION: LeftArmDefinition = preload("res://resources/equipment/shield_left_arm.tres")
const HOOK_DEFINITION: RightArmDefinition = preload("res://resources/equipment/hook_right_arm.tres")
const LEGS_DEFINITION: LegDefinition = preload("res://resources/equipment/knee_dash_legs.tres")
const LOOT_CASE_SPAWN_OFFSET: Vector2 = Vector2(0, 32)
const REWARD_SPAWN_OFFSET: Vector2 = Vector2(0, -48)

@onready var mission_controller: MissionController = $MissionController
@onready var mission_radio: MissionRadio = $World/MissionRadio
@onready var mission_helicopter: MissionHelicopter = $World/MissionHelicopter
@onready var player: Player = $World/Player
@onready var hud: GameHud = $HUD

var _loot_case: WorldLootCase = null
var _loot_case_spawned: bool = false
var _rewards_spawned: bool = false
var _shotgun_reward: WorldWeaponPickup = null
var _shield_reward: WorldLeftArmPickup = null
var _hook_reward: WorldRightArmPickup = null
var _legs_reward: WorldLegPickup = null

func _ready() -> void:
	mission_radio.mission_activation_requested.connect(_on_mission_activation_requested)
	mission_controller.mission_activated.connect(_on_mission_activated)
	mission_controller.objective_changed.connect(_on_objective_changed)
	mission_helicopter.health_changed.connect(_on_helicopter_health_changed)
	mission_helicopter.destroyed.connect(_on_helicopter_destroyed)
	hud.set_mission_objective(mission_controller.get_objective_text())
	hud.hide_helicopter_health()

func _on_mission_activation_requested(mission_id: String) -> void:
	if mission_controller.activate_mission(mission_id):
		mission_radio.set_available(false)

func _on_objective_changed(objective_text: String) -> void:
	hud.set_mission_objective(objective_text)

func _on_mission_activated(mission_id: String) -> void:
	if mission_id == MissionController.DESTROY_HELICOPTER_ID:
		mission_helicopter.activate()

func _on_helicopter_health_changed(current_health: int, maximum_health: int) -> void:
	hud.set_helicopter_health(current_health, maximum_health)

func _on_helicopter_destroyed(drop_position: Vector2, ejection_velocity: Vector2) -> void:
	if _loot_case_spawned:
		return
	_loot_case_spawned = true
	mission_controller.complete_mission(MissionController.DESTROY_HELICOPTER_ID)
	hud.hide_helicopter_health()
	_loot_case = WORLD_LOOT_CASE_SCENE.instantiate() as WorldLootCase
	if _loot_case == null:
		return
	$World.add_child(_loot_case)
	_loot_case.global_position = drop_position + LOOT_CASE_SPAWN_OFFSET
	_loot_case.landed.connect(_on_loot_case_landed)
	_loot_case.opened.connect(_on_loot_case_opened)
	_loot_case.launch(ejection_velocity)

func _on_loot_case_landed() -> void:
	if _loot_case == null or not _loot_case.is_landed():
		return
	mission_controller.mark_loot_case_ready(MissionController.DESTROY_HELICOPTER_ID)

func _on_loot_case_opened(open_position: Vector2) -> void:
	if _loot_case == null or _rewards_spawned:
		return
	if not _spawn_loot_case_rewards(open_position + REWARD_SPAWN_OFFSET):
		return
	_rewards_spawned = true
	mission_controller.mark_loot_case_opened(MissionController.DESTROY_HELICOPTER_ID)

func _spawn_loot_case_rewards(source_position: Vector2) -> bool:
	var shotgun_node: Node = SHOTGUN_PICKUP_SCENE.instantiate()
	var shield_node: Node = SHIELD_PICKUP_SCENE.instantiate()
	var hook_node: Node = HOOK_PICKUP_SCENE.instantiate()
	var legs_node: Node = LEGS_PICKUP_SCENE.instantiate()
	var shotgun_pickup: WorldWeaponPickup = shotgun_node as WorldWeaponPickup
	var shield_pickup: WorldLeftArmPickup = shield_node as WorldLeftArmPickup
	var hook_pickup: WorldRightArmPickup = hook_node as WorldRightArmPickup
	var legs_pickup: WorldLegPickup = legs_node as WorldLegPickup
	if shotgun_pickup == null or shield_pickup == null or hook_pickup == null or legs_pickup == null:
		push_error("Loot case reward scene type mismatch.")
		if shotgun_node != null:
			shotgun_node.free()
		if shield_node != null:
			shield_node.free()
		if hook_node != null:
			hook_node.free()
		if legs_node != null:
			legs_node.free()
		return false
	shotgun_pickup.weapon_definition = SHOTGUN_DEFINITION
	shield_pickup.left_arm_definition = SHIELD_DEFINITION
	hook_pickup.right_arm_definition = HOOK_DEFINITION
	legs_pickup.leg_definition = LEGS_DEFINITION
	_shotgun_reward = shotgun_pickup
	_shield_reward = shield_pickup
	_hook_reward = hook_pickup
	_legs_reward = legs_pickup
	shotgun_pickup.pickup_completed.connect(_on_shotgun_reward_collected)
	shield_pickup.pickup_completed.connect(_on_shield_reward_collected)
	hook_pickup.pickup_completed.connect(_on_hook_reward_collected)
	legs_pickup.pickup_completed.connect(_on_legs_reward_collected)
	$World.add_child(shotgun_pickup)
	$World.add_child(shield_pickup)
	$World.add_child(hook_pickup)
	$World.add_child(legs_pickup)
	shotgun_pickup.global_position = source_position
	shield_pickup.global_position = source_position
	hook_pickup.global_position = source_position
	legs_pickup.global_position = source_position
	shotgun_pickup.launch(Vector2(-360.0, -620.0))
	shield_pickup.launch(Vector2(-140.0, -760.0))
	hook_pickup.launch(Vector2(140.0, -760.0))
	legs_pickup.launch(Vector2(360.0, -620.0))
	return true

func _on_shotgun_reward_collected(actor: Node) -> void:
	_forward_reward_collection(actor, MissionController.SHOTGUN_REWARD_ID)

func _on_shield_reward_collected(actor: Node) -> void:
	_forward_reward_collection(actor, MissionController.SHIELD_LEFT_ARM_REWARD_ID)

func _on_hook_reward_collected(actor: Node) -> void:
	_forward_reward_collection(actor, MissionController.HOOK_RIGHT_ARM_REWARD_ID)

func _on_legs_reward_collected(actor: Node) -> void:
	_forward_reward_collection(actor, MissionController.KNEE_DASH_LEGS_REWARD_ID)

func _forward_reward_collection(actor: Node, reward_id: StringName) -> void:
	if actor != player:
		return
	mission_controller.register_reward_collected(MissionController.DESTROY_HELICOPTER_ID, reward_id)
