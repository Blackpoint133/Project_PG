class_name Player
extends CharacterBody2D

signal movement_state_changed(new_state: String)
signal interaction_prompt_changed(prompt_text: String)

const RUN_SPEED := 360.0
const CROUCH_SPEED := 180.0
const GROUND_ACCELERATION := 2800.0
const AIR_ACCELERATION := 1800.0
const GROUND_FRICTION := 3200.0

# Vertical tuning
const JUMP_VELOCITY := -840.0
const JETPACK_TARGET_RISE_VELOCITY := -480.0
const JETPACK_ACCELERATION := 4800.0
const MAX_FALL_SPEED := 840.0
const STAND_HEIGHT := 96.0
const CROUCH_HEIGHT := 64.0
const CROUCH_VISUAL_OFFSET := 32
const FACING_DEAD_ZONE := 8.0
const AUTOMATIC_RIFLE: WeaponDefinition = preload("res://resources/weapons/automatic_rifle.tres")
const STANDARD_LEGS: LegDefinition = preload("res://resources/equipment/standard_legs.tres")

var movement_state := "grounded"
var _jetpack_authorized := false
var facing_direction := 1

@onready var body_slot: Node2D = $BodyRoot/BodySlot
@onready var legs_slot: Node2D = $BodyRoot/LegsSlot
@onready var jetpack_slot: Node2D = $BodyRoot/JetpackSlot
@onready var aim_pivot: Node2D = $BodyRoot/AimPivot
@onready var weapon_slot: Node2D = $BodyRoot/AimPivot/WeaponSlot
@onready var weapon_controller: WeaponController = $WeaponController
@onready var leg_equipment_controller: LegEquipmentController = $LegEquipmentController
@onready var knee_dash_controller: KneeDashController = $KneeDashController
@onready var interaction_controller: InteractionController = $InteractionSensor
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var _rectangle_shape: RectangleShape2D = RectangleShape2D.new()
var muzzle_marker: Marker2D = null
var legs_module: Node = null

func _ready() -> void:
	leg_equipment_controller.legs_changed.connect(_on_legs_changed)
	leg_equipment_controller.leg_ability_requested.connect(_on_leg_ability_requested)
	weapon_controller.weapon_changed.connect(_on_weapon_changed)
	weapon_controller.fired.connect(_spawn_projectile)
	interaction_controller.prompt_changed.connect(_on_interaction_prompt_changed)
	leg_equipment_controller.setup(STANDARD_LEGS)
	weapon_controller.setup(AUTOMATIC_RIFLE)
	_rectangle_shape.size = Vector2(40, STAND_HEIGHT)
	collision_shape.shape = _rectangle_shape
	_update_crouch(false)

func _physics_process(delta: float) -> void:
	var was_on_floor := is_on_floor()
	if Input.is_action_just_pressed("leg_ability"):
		leg_equipment_controller.activate_ability()
	var dash_active: bool = knee_dash_controller.is_active()
	var input_direction := Input.get_axis("move_left", "move_right")
	var crouching := Input.is_action_pressed("crouch") and was_on_floor and not dash_active

	var jetpack_active: bool = false
	if dash_active:
		_update_crouch(false)
		velocity = knee_dash_controller.get_dash_velocity()
		move_and_slide()
		knee_dash_controller.process_contacts()
		knee_dash_controller.advance(delta)
	else:
		if Input.is_action_just_pressed("jump") and was_on_floor:
			_jetpack_authorized = true
			velocity.y = JUMP_VELOCITY
		elif was_on_floor:
			# Landing always clears the previous authorization, even if Space is held.
			_jetpack_authorized = false

		jetpack_active = _jetpack_authorized and not was_on_floor and Input.is_action_pressed("jump")
		if jetpack_active:
			# Smoothly approach the rise target without fighting gravity in the same frame.
			velocity.y = move_toward(velocity.y, JETPACK_TARGET_RISE_VELOCITY, JETPACK_ACCELERATION * delta)
		elif not was_on_floor:
			velocity.y = minf(velocity.y + get_gravity().y * delta, MAX_FALL_SPEED)

		var target_speed := CROUCH_SPEED if crouching else RUN_SPEED
		var horizontal_velocity := input_direction * target_speed
		var acceleration := GROUND_ACCELERATION if was_on_floor else AIR_ACCELERATION
		if absf(horizontal_velocity) > 0.0:
			velocity.x = move_toward(velocity.x, horizontal_velocity, acceleration * delta)
		else:
			velocity.x = move_toward(velocity.x, 0.0, GROUND_FRICTION * delta)

		move_and_slide()

	_update_crouch(crouching)
	_update_visuals(input_direction, jetpack_active)
	_update_state(jetpack_active)
	weapon_controller.set_firing_enabled(true)
	if Input.is_action_just_pressed("weapon_1"):
		weapon_controller.select_slot(0)
	if Input.is_action_just_pressed("weapon_2"):
		weapon_controller.select_slot(1)
	if Input.is_action_just_pressed("interact"):
		interaction_controller.try_interact(self)
	var fire_requested: bool = Input.is_action_pressed("fire") if weapon_controller.uses_automatic_fire() else Input.is_action_just_pressed("fire")
	if fire_requested:
		weapon_controller.try_fire()
	if Input.is_action_just_pressed("reload"):
		weapon_controller.try_reload()

func _spawn_projectile() -> void:
	if muzzle_marker == null:
		return
	var active_definition: WeaponDefinition = weapon_controller.weapon_definition
	if active_definition == null:
		return
	var projectile_scene: PackedScene = active_definition.projectile_scene
	var projectile_count: int = maxi(active_definition.projectiles_per_shot, 1)
	var spread_degrees: float = active_definition.spread_degrees
	var spread_step_degrees: float = 0.0
	if projectile_count > 1:
		spread_step_degrees = spread_degrees / float(projectile_count - 1)
	var aim_direction: Vector2 = get_global_mouse_position() - muzzle_marker.global_position
	if aim_direction.length_squared() <= 0.0:
		aim_direction = muzzle_marker.global_transform.x
	aim_direction = aim_direction.normalized()
	for pellet_index: int in range(projectile_count):
		var spread_offset_degrees: float = 0.0
		if projectile_count > 1:
			spread_offset_degrees = -spread_degrees * 0.5 + spread_step_degrees * float(pellet_index)
		var projectile_direction: Vector2 = aim_direction.rotated(deg_to_rad(spread_offset_degrees))
		var spawned_node: Node = projectile_scene.instantiate()
		var projectile: RifleProjectile = spawned_node as RifleProjectile
		if projectile == null:
			push_error("Weapon projectile scene is not a RifleProjectile.")
			spawned_node.free()
			continue
		projectile.configure(
			projectile_direction,
			active_definition.projectile_speed,
			active_definition.damage,
			active_definition.projectile_lifetime
		)
		get_parent().add_child(projectile)
		projectile.global_position = muzzle_marker.global_position

func _on_weapon_changed(definition: WeaponDefinition) -> void:
	for child: Node in weapon_slot.get_children():
		child.free()
	muzzle_marker = null
	if definition.held_visual_scene == null:
		push_error("Weapon definition has no held visual scene.")
		return
	var visual_node: Node = definition.held_visual_scene.instantiate()
	weapon_slot.add_child(visual_node)
	var muzzle_node: Node = visual_node.get_node_or_null(NodePath("Muzzle"))
	var installed_muzzle: Marker2D = muzzle_node as Marker2D
	if installed_muzzle == null or installed_muzzle.get_parent() != visual_node:
		push_error("Held weapon visual must have a direct Marker2D child named Muzzle.")
		return
	muzzle_marker = installed_muzzle

func _on_interaction_prompt_changed(prompt_text: String) -> void:
	interaction_prompt_changed.emit(prompt_text)

func _on_legs_changed(definition: LegDefinition) -> void:
	if definition == null or definition.ability_definition == null or definition.ability_definition.ability_id != "knee_dash":
		knee_dash_controller.cancel_dash()
	for child: Node in legs_slot.get_children():
		child.free()
	legs_module = null
	if definition == null or definition.held_visual_scene == null:
		return
	var visual_node: Node = definition.held_visual_scene.instantiate()
	var visual_transform: Node2D = visual_node as Node2D
	if visual_transform == null:
		visual_node.free()
		return
	legs_slot.add_child(visual_transform)
	legs_module = visual_transform
	var crouching: bool = Input.is_action_pressed("crouch") and is_on_floor()
	if legs_module.has_method(&"set_crouching"):
		legs_module.call(&"set_crouching", crouching)

func _on_leg_ability_requested(ability_definition: LegAbilityDefinition) -> void:
	if ability_definition == null or ability_definition.ability_id != "knee_dash":
		return
	var dash_direction: Vector2 = _get_knee_dash_direction(ability_definition)
	knee_dash_controller.start_dash(ability_definition, dash_direction)

func _get_knee_dash_direction(ability_definition: LegAbilityDefinition) -> Vector2:
	var mouse_offset: Vector2 = get_global_mouse_position() - global_position
	var horizontal_side: int = facing_direction
	if absf(mouse_offset.x) > FACING_DEAD_ZONE:
		horizontal_side = 1 if mouse_offset.x > 0.0 else -1
	var desired_angle: float = 0.0
	if mouse_offset.length_squared() > 1.0:
		desired_angle = atan2(mouse_offset.y, absf(mouse_offset.x))
	var max_angle_degrees: float = clampf(ability_definition.max_aim_angle_degrees, 0.0, 60.0)
	var max_angle_radians: float = deg_to_rad(max_angle_degrees)
	desired_angle = clampf(desired_angle, -max_angle_radians, max_angle_radians)
	var dash_direction: Vector2 = Vector2(float(horizontal_side), 0.0).rotated(desired_angle)
	facing_direction = horizontal_side
	return dash_direction.normalized()

func get_interaction_prompt() -> String:
	return interaction_controller.get_current_prompt()

func get_equipped_weapon_definition() -> WeaponDefinition:
	return weapon_controller.weapon_definition

func get_equipped_leg_definition() -> LegDefinition:
	return leg_equipment_controller.current_definition

func swap_weapon_with_pickup(pickup: WorldWeaponPickup) -> void:
	if pickup == null:
		return
	var incoming_instance: WeaponInstance = pickup.take_weapon_instance()
	if incoming_instance == null:
		interaction_controller.refresh_prompt()
		return
	var target_slot: int = weapon_controller.get_first_empty_slot()
	if target_slot == -1:
		target_slot = weapon_controller.get_active_slot_index()
	var outgoing_instance: WeaponInstance = weapon_controller.replace_slot_instance(target_slot, incoming_instance)
	if target_slot != weapon_controller.get_active_slot_index():
		weapon_controller.select_slot(target_slot)
	if outgoing_instance != null:
		pickup.set_weapon_instance(outgoing_instance)
		pickup.global_position = global_position + Vector2(0, -32)
		pickup.launch(Vector2(-180.0 * float(facing_direction), -360.0))
	else:
		pickup.queue_free()
	interaction_controller.refresh_prompt()

func swap_legs_with_pickup(pickup: WorldLegPickup) -> void:
	if pickup == null:
		return
	var incoming_instance: LegInstance = pickup.take_leg_instance()
	if incoming_instance == null:
		interaction_controller.refresh_prompt()
		return
	var outgoing_instance: LegInstance = leg_equipment_controller.replace_leg_instance(incoming_instance)
	if outgoing_instance == null:
		pickup.set_leg_instance(incoming_instance)
		interaction_controller.refresh_prompt()
		return
	pickup.set_leg_instance(outgoing_instance)
	pickup.global_position = global_position + Vector2(0, -32)
	pickup.launch(Vector2(-180.0 * float(facing_direction), -360.0))
	interaction_controller.refresh_prompt()

func get_weapon_slot_summary(slot_index: int) -> String:
	var instance: WeaponInstance = weapon_controller.get_slot_instance(slot_index)
	if instance == null or instance.definition == null:
		return "%d: EMPTY" % (slot_index + 1)
	var marker: String = " *" if weapon_controller.get_active_slot_index() == slot_index else ""
	return "%d: %s %d/%d%s" % [slot_index + 1, instance.definition.display_name, instance.loaded_ammo, instance.reserve_ammo, marker]

func _update_crouch(crouching: bool) -> void:
	var target_height := CROUCH_HEIGHT if crouching else STAND_HEIGHT
	var upper_body_offset: float = CROUCH_VISUAL_OFFSET if crouching else 0.0
	_rectangle_shape.size = Vector2(_rectangle_shape.size.x, target_height)
	collision_shape.position.y = -target_height * 0.5
	body_slot.position.y = upper_body_offset
	if legs_module != null and legs_module.has_method(&"set_crouching"):
		legs_module.call(&"set_crouching", crouching)
	jetpack_slot.position.y = upper_body_offset
	aim_pivot.position.y = -72.0 + upper_body_offset

func _update_visuals(_input_direction: float, _jetpack_active: bool) -> void:
	var mouse_position := get_global_mouse_position()
	aim_pivot.look_at(mouse_position)
	if knee_dash_controller.is_active():
		facing_direction = 1 if knee_dash_controller.get_dash_direction().x >= 0.0 else -1
	else:
		var horizontal_offset := mouse_position.x - global_position.x
		if absf(horizontal_offset) > FACING_DEAD_ZONE:
			facing_direction = 1 if horizontal_offset > 0.0 else -1
	body_slot.scale.x = facing_direction
	legs_slot.scale.x = facing_direction
	jetpack_slot.scale.x = facing_direction
	if facing_direction < 0:
		aim_pivot.scale.y = -1.0
	else:
		aim_pivot.scale.y = 1.0

func _update_state(jetpack_active: bool) -> void:
	var new_state := "grounded"
	if knee_dash_controller.is_active():
		new_state = "knee_dash"
	elif not is_on_floor():
		new_state = "jetpack" if jetpack_active else "airborne"
	elif is_on_floor() and Input.is_action_pressed("crouch"):
		new_state = "crouching"
	if new_state != movement_state:
		movement_state = new_state
		movement_state_changed.emit(new_state)
