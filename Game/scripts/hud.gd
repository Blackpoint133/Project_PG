class_name GameHud
extends CanvasLayer

@onready var movement_label: Label = $MovementLabel
@onready var weapon_label: Label = $WeaponLabel
@onready var weapon_slots_label: Label = $WeaponSlotsLabel
@onready var leg_status_label: Label = $LegStatusLabel
@onready var left_arm_status_label: Label = $LeftArmStatusLabel
@onready var shield_energy_bar: ProgressBar = $ShieldEnergyBar
@onready var right_arm_status_label: Label = $RightArmStatusLabel
@onready var health_label: Label = $HealthLabel
@onready var interaction_label: Label = $InteractionLabel
@onready var jetpack_status_label: Label = $JetpackStatusLabel
@onready var jetpack_heat_bar: ProgressBar = $JetpackHeatBar
@onready var slide_status_label: Label = $SlideStatusLabel
@onready var mission_objective_label: Label = $MissionObjectiveLabel
@onready var helicopter_health_label: Label = $HelicopterHealthLabel
@onready var helicopter_health_bar: ProgressBar = $HelicopterHealthBar
var _is_reloading := false
var _loaded_ammo := 0
var _reserve_ammo := 0
var _weapon_name: String = ""
var _leg_dash_active: bool = false
var _leg_cooldown_remaining: float = 0.0
var _left_arm_name: String = "UNKNOWN"
var _left_arm_ability_name: String = "NONE"
var _shield_available: bool = false
var _shield_active: bool = false
var _shield_charge: float = 0.0
var _shield_max_charge: float = 0.0
var _shield_saturated: bool = false
var _shield_cooldown_remaining: float = 0.0
var _right_arm_name: String = "UNKNOWN"
var _right_arm_ability_name: String = "NONE"
var _right_arm_cooldown_remaining: float = 0.0
var _hook_state: String = "idle"
var _current_health: float = 100.0
var _maximum_health: float = 100.0
var _jetpack_heat: float = 0.0
var _jetpack_maximum_heat: float = 100.0
var _jetpack_overheated: bool = false
var _jetpack_active: bool = false
var _slide_active: bool = false
var _slide_cooldown_remaining: float = 0.0

func set_mission_objective(objective_text: String) -> void:
	mission_objective_label.text = "OBJECTIVE: %s" % objective_text

func set_helicopter_health(current_health: int, maximum_health: int) -> void:
	helicopter_health_label.text = "HELICOPTER %d / %d" % [current_health, maximum_health]
	helicopter_health_bar.max_value = maximum_health
	helicopter_health_bar.value = current_health
	helicopter_health_label.visible = true
	helicopter_health_bar.visible = true

func hide_helicopter_health() -> void:
	helicopter_health_label.visible = false
	helicopter_health_bar.visible = false

func _ready() -> void:
	set_process(true)
	var player: Player = get_tree().get_first_node_in_group("player")
	if player != null:
		_loaded_ammo = player.weapon_controller.get_loaded_ammo()
		_reserve_ammo = player.weapon_controller.get_reserve_ammo()
		_weapon_name = player.weapon_controller.get_display_name()
		var left_arm_definition: LeftArmDefinition = player.left_arm_equipment_controller.current_definition
		var left_arm_ability: LeftArmAbilityDefinition = player.left_arm_equipment_controller.current_ability_definition
		_left_arm_name = "UNKNOWN" if left_arm_definition == null else left_arm_definition.display_name
		_left_arm_ability_name = "" if left_arm_ability == null else left_arm_ability.display_name
		_shield_available = player.shield_controller.get_maximum_charge() > 0.0
		_shield_active = player.shield_controller.is_active()
		_shield_charge = player.shield_controller.get_current_charge()
		_shield_max_charge = player.shield_controller.get_maximum_charge()
		_shield_saturated = player.shield_controller.is_saturated()
		_shield_cooldown_remaining = player.shield_controller.get_cooldown_remaining()
		var right_arm_definition: RightArmDefinition = player.right_arm_equipment_controller.current_definition
		var right_arm_ability: RightArmAbilityDefinition = player.right_arm_equipment_controller.current_ability_definition
		_right_arm_name = "UNKNOWN" if right_arm_definition == null else right_arm_definition.display_name
		_right_arm_ability_name = "NONE" if right_arm_ability == null else right_arm_ability.display_name
		_right_arm_cooldown_remaining = player.right_arm_equipment_controller.current_instance.ability_cooldown_remaining if player.right_arm_equipment_controller.current_instance != null else 0.0
		_hook_state = player.hook_controller.get_state()
		_current_health = player.get_current_health()
		_maximum_health = player.get_maximum_health()
		_jetpack_heat = player.jetpack_controller.get_current_heat()
		_jetpack_maximum_heat = player.jetpack_controller.get_maximum_heat()
		_jetpack_overheated = player.jetpack_controller.is_overheated()
		_jetpack_active = player.jetpack_controller.is_active()
		_slide_active = player.slide_controller.is_active()
		_slide_cooldown_remaining = player.slide_controller.get_cooldown_remaining()
		_render_weapon_state()
		_render_weapon_slots(player)
		_render_leg_status(player)
		_render_left_arm_status()
		_render_right_arm_status()
		_render_health()
		_render_jetpack_status(player)
		_render_slide_status()
		interaction_label.text = player.get_interaction_prompt()
		interaction_label.visible = not interaction_label.text.is_empty()
		player.weapon_controller.reload_started.connect(_on_reload_started)
		player.weapon_controller.reload_completed.connect(_on_reload_completed)
		player.weapon_controller.weapon_ammo_changed.connect(_on_ammo_changed)
		player.weapon_controller.weapon_changed.connect(_on_weapon_changed)
		player.weapon_controller.weapon_slots_changed.connect(_on_weapon_slots_changed)
		player.leg_equipment_controller.legs_changed.connect(_on_legs_changed)
		player.leg_equipment_controller.leg_ability_changed.connect(_on_leg_ability_changed)
		player.leg_equipment_controller.leg_ability_state_changed.connect(_on_leg_ability_state_changed)
		player.left_arm_equipment_controller.left_arm_changed.connect(_on_left_arm_changed)
		player.left_arm_equipment_controller.left_arm_ability_changed.connect(_on_left_arm_ability_changed)
		player.right_arm_equipment_controller.right_arm_changed.connect(_on_right_arm_changed)
		player.right_arm_equipment_controller.right_arm_ability_changed.connect(_on_right_arm_ability_changed)
		player.right_arm_equipment_controller.right_arm_ability_state_changed.connect(_on_right_arm_ability_state_changed)
		player.hook_controller.hook_state_changed.connect(_on_hook_state_changed)
		player.shield_controller.shield_state_changed.connect(_on_shield_state_changed)
		player.player_damage_receiver.health_changed.connect(_on_health_changed)
		player.knee_dash_controller.dash_started.connect(_on_dash_started)
		player.knee_dash_controller.dash_ended.connect(_on_dash_ended)
		player.interaction_prompt_changed.connect(_on_interaction_prompt_changed)
		player.jetpack_controller.jetpack_state_changed.connect(_on_jetpack_state_changed)
		player.slide_controller.slide_state_changed.connect(_on_slide_state_changed)

func _process(_delta: float) -> void:
	var player: Player = get_tree().get_first_node_in_group("player")
	if player != null:
		movement_label.text = "MOVEMENT: %s" % player.movement_state

func _on_ammo_changed(loaded: int, reserve: int) -> void:
	_loaded_ammo = loaded
	_reserve_ammo = reserve
	if not _is_reloading:
		_render_weapon_state()
	var player: Player = get_tree().get_first_node_in_group("player")
	if player != null:
		_render_weapon_slots(player)

func _render_weapon_state() -> void:
	weapon_label.text = "%s %d / %d" % [_weapon_name, _loaded_ammo, _reserve_ammo]

func _render_weapon_slots(player: Player) -> void:
	weapon_slots_label.text = "%s\n%s" % [player.get_weapon_slot_summary(0), player.get_weapon_slot_summary(1)]

func _render_leg_status(player: Player) -> void:
	var definition: LegDefinition = player.leg_equipment_controller.current_definition
	var ability_definition: LegAbilityDefinition = player.leg_equipment_controller.current_ability_definition
	var leg_name: String = "UNKNOWN"
	var ability_name: String = "NONE"
	if definition != null:
		leg_name = definition.display_name
	if _leg_dash_active:
		ability_name = "KNEE DASH ACTIVE"
	elif ability_definition != null:
		ability_name = "%s %.1fs" % [ability_definition.display_name, _leg_cooldown_remaining] if _leg_cooldown_remaining > 0.0 else "%s READY" % ability_definition.display_name
	leg_status_label.text = "LEGS: %s\nC: %s" % [leg_name, ability_name]

func _render_left_arm_status() -> void:
	var ability_name: String = "NONE"
	shield_energy_bar.visible = _shield_available
	var percentage: float = 0.0
	if _shield_max_charge > 0.0:
		percentage = clampf(_shield_charge / _shield_max_charge * 100.0, 0.0, 100.0)
	shield_energy_bar.value = percentage
	if not _shield_available or _left_arm_ability_name.is_empty():
		ability_name = "NONE"
	elif _shield_cooldown_remaining > 0.0:
		ability_name = "SHIELD COOLDOWN %.1fs" % _shield_cooldown_remaining
	elif _shield_saturated:
		ability_name = "SHIELD SATURATED 100%"
	elif _shield_active:
		ability_name = "SHIELD ABSORBING %.0f%%" % percentage
	elif percentage > 0.0:
		ability_name = "SHIELD STORED %.0f%%" % percentage
	else:
		ability_name = "SHIELD READY 0%"
	left_arm_status_label.text = "LEFT ARM: %s\nQ: %s" % [_left_arm_name, ability_name]

func _render_health() -> void:
	health_label.text = "HEALTH: %.0f / %.0f" % [_current_health, _maximum_health]

func _render_jetpack_status(player: Player) -> void:
	var percentage: float = 0.0
	if _jetpack_maximum_heat > 0.0:
		percentage = clampf(_jetpack_heat / _jetpack_maximum_heat * 100.0, 0.0, 100.0)
	jetpack_heat_bar.value = percentage
	var state_text: String = "READY 0%"
	if _jetpack_active:
		state_text = "ACTIVE %.0f%%" % percentage
	elif _jetpack_overheated and not player.is_on_floor():
		state_text = "OVERHEATED 100%"
	elif player.is_on_floor() and _jetpack_heat > 0.0:
		state_text = "COOLING %.0f%%" % percentage
	elif _jetpack_heat > 0.0:
		state_text = "HEAT %.0f%%" % percentage
	jetpack_status_label.text = "JETPACK: %s" % state_text

func _render_right_arm_status() -> void:
	var ability_name: String = "NONE"
	if _right_arm_ability_name != "NONE":
		if _hook_state == "extending":
			ability_name = "HOOK FIRING"
		elif _hook_state == "pulling":
			ability_name = "HOOK PULLING"
		elif _hook_state == "grappling":
			ability_name = "HOOK GRAPPLING"
		elif _right_arm_cooldown_remaining > 0.0:
			ability_name = "HOOK %.1fs" % _right_arm_cooldown_remaining
		else:
			ability_name = "%s READY" % _right_arm_ability_name
	right_arm_status_label.text = "RIGHT ARM: %s\nE: %s" % [_right_arm_name, ability_name]

func _render_slide_status() -> void:
	if _slide_active:
		slide_status_label.text = "SLIDE: ACTIVE"
	elif _slide_cooldown_remaining > 0.0:
		slide_status_label.text = "SLIDE: COOLDOWN %.1fs" % _slide_cooldown_remaining
	else:
		slide_status_label.text = "SLIDE: READY"

func _on_reload_started() -> void:
	_is_reloading = true
	weapon_label.text = "RELOADING %s" % _weapon_name

func _on_reload_completed() -> void:
	_is_reloading = false
	_render_weapon_state()

func _on_weapon_changed(definition: WeaponDefinition) -> void:
	_weapon_name = definition.display_name
	_is_reloading = false
	_render_weapon_state()
	var player: Player = get_tree().get_first_node_in_group("player")
	if player != null:
		_render_weapon_slots(player)

func _on_weapon_slots_changed(_slot_1: WeaponInstance, _slot_2: WeaponInstance, _active_slot_index: int) -> void:
	var player: Player = get_tree().get_first_node_in_group("player")
	if player != null:
		_render_weapon_slots(player)

func _on_legs_changed(_definition: LegDefinition) -> void:
	var player: Player = get_tree().get_first_node_in_group("player")
	if player != null:
		_render_leg_status(player)

func _on_leg_ability_changed(_ability_definition: LegAbilityDefinition) -> void:
	var player: Player = get_tree().get_first_node_in_group("player")
	if player != null:
		_render_leg_status(player)

func _on_leg_ability_state_changed(_ability_definition: LegAbilityDefinition, cooldown_remaining: float) -> void:
	_leg_cooldown_remaining = cooldown_remaining
	var player: Player = get_tree().get_first_node_in_group("player")
	if player != null:
		_render_leg_status(player)

func _on_left_arm_changed(definition: LeftArmDefinition) -> void:
	_left_arm_name = "UNKNOWN" if definition == null else definition.display_name
	_render_left_arm_status()

func _on_left_arm_ability_changed(ability_definition: LeftArmAbilityDefinition) -> void:
	_left_arm_ability_name = "" if ability_definition == null else ability_definition.display_name
	_render_left_arm_status()

func _on_right_arm_changed(definition: RightArmDefinition) -> void:
	_right_arm_name = "UNKNOWN" if definition == null else definition.display_name
	_render_right_arm_status()

func _on_right_arm_ability_changed(ability_definition: RightArmAbilityDefinition) -> void:
	_right_arm_ability_name = "NONE" if ability_definition == null else ability_definition.display_name
	_render_right_arm_status()

func _on_right_arm_ability_state_changed(_ability_definition: RightArmAbilityDefinition, cooldown_remaining: float) -> void:
	_right_arm_cooldown_remaining = cooldown_remaining
	_render_right_arm_status()

func _on_hook_state_changed(state: String) -> void:
	_hook_state = state
	_render_right_arm_status()

func _on_shield_state_changed(available: bool, active: bool, current_charge: float, maximum_charge: float, saturated: bool, cooldown_remaining: float) -> void:
	_shield_available = available
	_shield_active = active
	_shield_charge = current_charge
	_shield_max_charge = maximum_charge
	_shield_saturated = saturated
	_shield_cooldown_remaining = cooldown_remaining
	_render_left_arm_status()

func _on_health_changed(current_health: float, maximum_health: float) -> void:
	_current_health = current_health
	_maximum_health = maximum_health
	_render_health()

func _on_dash_started(_direction: Vector2) -> void:
	_leg_dash_active = true
	var player: Player = get_tree().get_first_node_in_group("player")
	if player != null:
		_render_leg_status(player)

func _on_dash_ended() -> void:
	_leg_dash_active = false
	var player: Player = get_tree().get_first_node_in_group("player")
	if player != null:
		_render_leg_status(player)

func _on_interaction_prompt_changed(prompt_text: String) -> void:
	interaction_label.text = prompt_text
	interaction_label.visible = not prompt_text.is_empty()

func _on_jetpack_state_changed(current_heat: float, maximum_heat: float, overheated: bool, active: bool) -> void:
	_jetpack_heat = current_heat
	_jetpack_maximum_heat = maximum_heat
	_jetpack_overheated = overheated
	_jetpack_active = active
	var player: Player = get_tree().get_first_node_in_group("player")
	if player != null:
		_render_jetpack_status(player)

func _on_slide_state_changed(active: bool, cooldown_remaining: float) -> void:
	_slide_active = active
	_slide_cooldown_remaining = cooldown_remaining
	_render_slide_status()
