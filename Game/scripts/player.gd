class_name Player
extends CharacterBody2D

signal movement_state_changed(new_state: String)

const RUN_SPEED := 180.0
const CROUCH_SPEED := 90.0
const GROUND_ACCELERATION := 1400.0
const AIR_ACCELERATION := 900.0
const GROUND_FRICTION := 1600.0
const JUMP_VELOCITY := -420.0
const JETPACK_THRUST := 620.0
const MAX_FALL_SPEED := 420.0
const MAX_JETPACK_RISE_SPEED := 140.0
const STAND_HEIGHT := 28.0
const CROUCH_HEIGHT := 18.0

var movement_state := "grounded"
var _jetpack_allowed := false

@onready var body_root: Node2D = $BodyRoot
@onready var aim_pivot: Node2D = $BodyRoot/AimPivot
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var _rectangle_shape: RectangleShape2D = RectangleShape2D.new()

func _ready() -> void:
	_rectangle_shape.size = Vector2(12, STAND_HEIGHT)
	collision_shape.shape = _rectangle_shape

func _physics_process(delta: float) -> void:
	var was_on_floor := is_on_floor()
	var input_direction := Input.get_axis("move_left", "move_right")
	var crouching := Input.is_action_pressed("crouch") and was_on_floor
	if Input.is_action_just_pressed("jump") and was_on_floor:
		_jetpack_allowed = true
	elif was_on_floor and not Input.is_action_pressed("jump"):
		_jetpack_allowed = false
	var jetpack_active := _jetpack_allowed and not was_on_floor and Input.is_action_pressed("jump")

	if not was_on_floor:
		velocity.y = minf(velocity.y + get_gravity().y * delta, MAX_FALL_SPEED)
	if jetpack_active:
		velocity.y = maxf(velocity.y - JETPACK_THRUST * delta, -MAX_JETPACK_RISE_SPEED)

	var target_speed := CROUCH_SPEED if crouching else RUN_SPEED
	var horizontal_velocity := input_direction * target_speed
	var acceleration := GROUND_ACCELERATION if was_on_floor else AIR_ACCELERATION
	if absf(horizontal_velocity) > 0.0:
		velocity.x = move_toward(velocity.x, horizontal_velocity, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, GROUND_FRICTION * delta)

	if Input.is_action_just_pressed("jump") and was_on_floor:
		velocity.y = JUMP_VELOCITY

	move_and_slide()
	_update_crouch(crouching)
	_update_visuals(input_direction, jetpack_active)
	_update_state()

func _update_crouch(crouching: bool) -> void:
	var target_height := CROUCH_HEIGHT if crouching else STAND_HEIGHT
	_rectangle_shape.size = Vector2(_rectangle_shape.size.x, target_height)
	collision_shape.position.y = (STAND_HEIGHT - target_height) * 0.5
	body_root.position.y = target_height - STAND_HEIGHT

func _update_visuals(_input_direction: float, _jetpack_active: bool) -> void:
	aim_pivot.look_at(get_global_mouse_position())

func _update_state() -> void:
	var new_state := "grounded"
	if not is_on_floor():
		new_state = "jetpack" if Input.is_action_pressed("jump") else "airborne"
	if is_on_floor() and Input.is_action_pressed("crouch"):
		new_state = "crouching"
	if new_state != movement_state:
		movement_state = new_state
		movement_state_changed.emit(new_state)
