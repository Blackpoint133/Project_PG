class_name ShieldController
extends Node2D

signal shield_state_changed(available: bool, active: bool, current_charge: float, maximum_charge: float, saturated: bool)

const SHIELD_ABILITY_ID: String = "shield"
const COUNTER_PROJECTILE_SCENE: PackedScene = preload("res://scenes/projectiles/kinetic_counter_projectile.tscn")

@onready var shield_area: Area2D = $ShieldArea
@onready var shield_collision_shape: CollisionShape2D = $ShieldArea/CollisionShape2D
@onready var shield_fill: Polygon2D = $ShieldFill
@onready var shield_outline: Line2D = $ShieldOutline

var _left_arm_instance: LeftArmInstance
var _input_pressed: bool = false
var _is_active: bool = false
var _protected_side: int = 1
var _is_crouching: bool = false

func set_left_arm_instance(instance: LeftArmInstance) -> void:
	_deactivate()
	_left_arm_instance = instance
	_input_pressed = false
	if _left_arm_instance != null:
		_left_arm_instance.ability_charge = clampf(_left_arm_instance.ability_charge, 0.0, get_maximum_charge())
	_apply_geometry()
	_emit_state()

func set_input_pressed(is_pressed: bool) -> void:
	if _input_pressed == is_pressed:
		return
	_input_pressed = is_pressed
	if not is_pressed:
		_deactivate()
		return
	if _can_activate():
		_is_active = true
		_apply_presentation(true)
		_emit_state()

func set_protected_side(horizontal_side: int) -> void:
	var next_side: int = 1 if horizontal_side >= 0 else -1
	if _protected_side == next_side:
		return
	_protected_side = next_side
	_apply_geometry()

func set_crouching(crouching: bool) -> void:
	if _is_crouching == crouching:
		return
	_is_crouching = crouching
	_apply_geometry()

func absorb_damage(incoming_damage: float) -> float:
	var safe_damage: float = maxf(incoming_damage, 0.0)
	if not _is_active or not _is_shield_available() or _left_arm_instance == null:
		return safe_damage
	var maximum_charge: float = get_maximum_charge()
	var available_capacity: float = maxf(maximum_charge - _left_arm_instance.ability_charge, 0.0)
	var absorbed_damage: float = minf(safe_damage, available_capacity)
	_left_arm_instance.ability_charge = clampf(_left_arm_instance.ability_charge + absorbed_damage, 0.0, maximum_charge)
	_emit_state()
	return safe_damage - absorbed_damage

func try_counter_blast() -> bool:
	if not _is_active or _left_arm_instance == null:
		return false
	var charge: float = get_current_charge()
	if charge <= 0.0:
		return false
	var ability_definition: LeftArmAbilityDefinition = _get_ability_definition()
	if ability_definition == null:
		return false
	var spawned_node: Node = COUNTER_PROJECTILE_SCENE.instantiate()
	var projectile: KineticCounterProjectile = spawned_node as KineticCounterProjectile
	if projectile == null:
		spawned_node.free()
		return false
	var player_node: Node2D = get_parent().get_parent() as Node2D
	if player_node == null or player_node.get_parent() == null:
		spawned_node.free()
		return false
	var projectile_direction: Vector2 = Vector2(float(_protected_side), 0.0)
	projectile.configure(projectile_direction, ability_definition.counter_projectile_speed, charge, ability_definition.counter_projectile_lifetime)
	player_node.get_parent().add_child(projectile)
	projectile.global_position = player_node.global_position + Vector2(0.0, -48.0)
	_left_arm_instance.ability_charge = 0.0
	_emit_state()
	return true

func is_active() -> bool:
	return _is_active

func get_current_charge() -> float:
	if _left_arm_instance == null:
		return 0.0
	return clampf(_left_arm_instance.ability_charge, 0.0, get_maximum_charge())

func get_maximum_charge() -> float:
	var ability_definition: LeftArmAbilityDefinition = _get_ability_definition()
	return 0.0 if ability_definition == null else maxf(ability_definition.max_charge, 0.0)

func is_saturated() -> bool:
	var maximum_charge: float = get_maximum_charge()
	return maximum_charge > 0.0 and get_current_charge() >= maximum_charge

func _get_ability_definition() -> LeftArmAbilityDefinition:
	if _left_arm_instance == null or _left_arm_instance.definition == null:
		return null
	return _left_arm_instance.definition.ability_definition

func _is_shield_available() -> bool:
	var ability_definition: LeftArmAbilityDefinition = _get_ability_definition()
	return ability_definition != null and ability_definition.ability_id == SHIELD_ABILITY_ID

func _can_activate() -> bool:
	return _is_shield_available()

func _deactivate() -> void:
	if not _is_active:
		_apply_presentation(false)
		return
	_is_active = false
	_apply_presentation(false)
	_emit_state()

func _apply_presentation(active: bool) -> void:
	shield_area.collision_layer = 64 if active else 0
	shield_area.monitoring = active
	shield_fill.visible = active
	shield_outline.visible = active
	_update_saturation_presentation()

func _apply_geometry() -> void:
	var shield_height: float = 64.0 if _is_crouching else 96.0
	var center_y: float = -shield_height * 0.5
	var edge_x: float = float(_protected_side) * 52.0
	var shape: RectangleShape2D = shield_collision_shape.shape as RectangleShape2D
	if shape != null:
		shape.size = Vector2(16.0, shield_height)
		shield_collision_shape.position = Vector2(edge_x, center_y)
	var inner_x: float = float(_protected_side) * 44.0
	var outer_x: float = float(_protected_side) * 60.0
	var half_height: float = shield_height * 0.5
	shield_fill.polygon = PackedVector2Array([
		Vector2(inner_x, center_y - half_height),
		Vector2(outer_x, center_y - half_height + 4.0),
		Vector2(outer_x, center_y + half_height - 4.0),
		Vector2(inner_x, center_y + half_height)
	])
	shield_outline.points = PackedVector2Array([
		Vector2(inner_x, center_y - half_height),
		Vector2(outer_x, center_y - half_height + 4.0),
		Vector2(outer_x, center_y + half_height - 4.0),
		Vector2(inner_x, center_y + half_height),
		Vector2(inner_x, center_y - half_height)
	])

func _update_saturation_presentation() -> void:
	if is_saturated():
		shield_fill.color = Color(0.2, 0.9, 1.0, 0.38)
		shield_outline.default_color = Color(0.65, 1.0, 1.0, 1.0)
	else:
		shield_fill.color = Color(0.1, 0.75, 0.95, 0.28)
		shield_outline.default_color = Color(0.35, 0.9, 1.0, 0.9)

func _emit_state() -> void:
	_update_saturation_presentation()
	shield_state_changed.emit(_is_shield_available(), _is_active, get_current_charge(), get_maximum_charge(), is_saturated())
