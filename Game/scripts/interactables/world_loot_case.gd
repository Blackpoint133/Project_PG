class_name WorldLootCase
extends CharacterBody2D

signal landed

@export var maximum_fall_speed: float = 1200.0
@export var ground_friction: float = 1000.0

var _launched: bool = false
var _landed: bool = false

func _physics_process(delta: float) -> void:
	if not _launched:
		return
	if _landed:
		velocity.x = move_toward(velocity.x, 0.0, ground_friction * delta)
		move_and_slide()
		return
	velocity.y = minf(velocity.y + get_gravity().y * delta, maximum_fall_speed)
	move_and_slide()
	if is_on_floor():
		_landed = true
		velocity.y = 0.0
		landed.emit()

func launch(initial_velocity: Vector2) -> void:
	if _launched:
		return
	_launched = true
	_landed = false
	velocity = initial_velocity

func is_landed() -> bool:
	return _landed
