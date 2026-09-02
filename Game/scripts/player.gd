class_name Player
extends CharacterBody2D

signal movement_state_changed(new_state: String)

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

var movement_state := "grounded"
var _jetpack_authorized := false
var facing_direction := 1

@onready var body_slot: Node2D = $BodyRoot/BodySlot
@onready var legs_slot: Node2D = $BodyRoot/LegsSlot
@onready var legs_module: Node = legs_slot.get_child(0)
@onready var jetpack_slot: Node2D = $BodyRoot/JetpackSlot
@onready var aim_pivot: Node2D = $BodyRoot/AimPivot
@onready var muzzle_marker: Marker2D = $BodyRoot/AimPivot/WeaponSlot/PlaceholderWeapon/Muzzle
@onready var weapon_controller: WeaponController = $WeaponController
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var _rectangle_shape: RectangleShape2D = RectangleShape2D.new()

func _ready() -> void:
	weapon_controller.setup(load("res://resources/weapons/automatic_rifle.tres"))
	weapon_controller.fired.connect(_spawn_projectile)
	_rectangle_shape.size = Vector2(40, STAND_HEIGHT)
	collision_shape.shape = _rectangle_shape
	_update_crouch(false)

func _physics_process(delta: float) -> void:
	var was_on_floor := is_on_floor()
	var input_direction := Input.get_axis("move_left", "move_right")
	var crouching := Input.is_action_pressed("crouch") and was_on_floor

	if Input.is_action_just_pressed("jump") and was_on_floor:
		_jetpack_authorized = true
		velocity.y = JUMP_VELOCITY
	elif was_on_floor:
		# Landing always clears the previous authorization, even if Space is held.
		_jetpack_authorized = false

	var jetpack_active := _jetpack_authorized and not was_on_floor and Input.is_action_pressed("jump")
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
	if Input.is_action_pressed("fire"):
		weapon_controller.try_fire()
	if Input.is_action_just_pressed("reload"):
		weapon_controller.try_reload()

func _spawn_projectile() -> void:
	var spawned_node = weapon_controller.weapon_definition.projectile_scene.instantiate()
	var projectile := spawned_node as RifleProjectile
	if projectile == null:
		push_error("Weapon projectile scene is not a RifleProjectile.")
		spawned_node.free()
		return
	var aim_direction := get_global_mouse_position() - muzzle_marker.global_position
	if aim_direction.length_squared() <= 0.0:
		aim_direction = muzzle_marker.global_transform.x
	aim_direction = aim_direction.normalized()
	projectile.configure(
		aim_direction,
		weapon_controller.weapon_definition.projectile_speed,
		weapon_controller.weapon_definition.damage,
		weapon_controller.weapon_definition.projectile_lifetime
	)
	get_parent().add_child(projectile)
	projectile.global_position = muzzle_marker.global_position

func _update_crouch(crouching: bool) -> void:
	var target_height := CROUCH_HEIGHT if crouching else STAND_HEIGHT
	var upper_body_offset: float = CROUCH_VISUAL_OFFSET if crouching else 0.0
	_rectangle_shape.size = Vector2(_rectangle_shape.size.x, target_height)
	collision_shape.position.y = -target_height * 0.5
	body_slot.position.y = upper_body_offset
	if legs_module.has_method(&"set_crouching"):
		legs_module.call(&"set_crouching", crouching)
	jetpack_slot.position.y = upper_body_offset
	aim_pivot.position.y = -72.0 + upper_body_offset

func _update_visuals(_input_direction: float, _jetpack_active: bool) -> void:
	var mouse_position := get_global_mouse_position()
	aim_pivot.look_at(mouse_position)
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
	if not is_on_floor():
		new_state = "jetpack" if jetpack_active else "airborne"
	if is_on_floor() and Input.is_action_pressed("crouch"):
		new_state = "crouching"
	if new_state != movement_state:
		movement_state = new_state
		movement_state_changed.emit(new_state)
