extends CanvasLayer

@onready var movement_label: Label = $MovementLabel
@onready var weapon_label: Label = $WeaponLabel
@onready var weapon_slots_label: Label = $WeaponSlotsLabel
@onready var leg_status_label: Label = $LegStatusLabel
@onready var left_arm_status_label: Label = $LeftArmStatusLabel
@onready var interaction_label: Label = $InteractionLabel
var _is_reloading := false
var _loaded_ammo := 0
var _reserve_ammo := 0
var _weapon_name: String = ""
var _leg_dash_active: bool = false
var _leg_cooldown_remaining: float = 0.0
var _left_arm_name: String = "UNKNOWN"
var _left_arm_ability_name: String = "NONE"
var _left_arm_input_held: bool = false

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
		_render_weapon_state()
		_render_weapon_slots(player)
		_render_leg_status(player)
		_render_left_arm_status()
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
		player.left_arm_equipment_controller.left_arm_ability_input_changed.connect(_on_left_arm_ability_input_changed)
		player.knee_dash_controller.dash_started.connect(_on_dash_started)
		player.knee_dash_controller.dash_ended.connect(_on_dash_ended)
		player.interaction_prompt_changed.connect(_on_interaction_prompt_changed)

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
	if not _left_arm_ability_name.is_empty():
		ability_name = "%s INPUT HELD" % _left_arm_ability_name if _left_arm_input_held else "%s READY" % _left_arm_ability_name
	left_arm_status_label.text = "LEFT ARM: %s\nQ: %s" % [_left_arm_name, ability_name]

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
	_left_arm_input_held = false
	_render_left_arm_status()

func _on_left_arm_ability_changed(ability_definition: LeftArmAbilityDefinition) -> void:
	_left_arm_ability_name = "" if ability_definition == null else ability_definition.display_name
	_left_arm_input_held = false
	_render_left_arm_status()

func _on_left_arm_ability_input_changed(_ability_definition: LeftArmAbilityDefinition, is_pressed: bool) -> void:
	_left_arm_input_held = is_pressed
	_render_left_arm_status()

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
