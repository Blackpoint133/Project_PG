class_name MissionHelicopter
extends CharacterBody2D

signal health_changed(current_health: int, maximum_health: int)
signal destroyed

@export var maximum_health: int = 300
@export var horizontal_speed: float = 120.0
@export var patrol_min_x: float = 360.0
@export var patrol_max_x: float = 2200.0
@export var initial_direction: int = -1

var _current_health: int = 300
var _active: bool = false
var _destroyed: bool = false
var _patrol_direction: int = -1

func _ready() -> void:
	_current_health = maxi(maximum_health, 0)
	_patrol_direction = -1 if initial_direction < 0 else 1
	visible = false
	set_collision_layer_value(3, false)
	health_changed.emit(_current_health, maximum_health)

func _physics_process(_delta: float) -> void:
	if not _active or _destroyed:
		return
	velocity = Vector2(horizontal_speed * float(_patrol_direction), 0.0)
	move_and_slide()
	if global_position.x <= patrol_min_x:
		_patrol_direction = 1
	elif global_position.x >= patrol_max_x:
		_patrol_direction = -1

func activate() -> bool:
	if _active or _destroyed or maximum_health <= 0:
		return false
	_active = true
	visible = true
	set_collision_layer_value(3, true)
	health_changed.emit(_current_health, maximum_health)
	return true

func take_damage(amount: int) -> void:
	if not _active or _destroyed or amount <= 0:
		return
	_current_health = maxi(_current_health - amount, 0)
	health_changed.emit(_current_health, maximum_health)
	if _current_health == 0:
		_destroy()

func is_active() -> bool:
	return _active and not _destroyed

func is_destroyed() -> bool:
	return _destroyed

func get_current_health() -> int:
	return _current_health

func get_maximum_health() -> int:
	return maximum_health

func _destroy() -> void:
	if _destroyed:
		return
	_destroyed = true
	_active = false
	velocity = Vector2.ZERO
	set_collision_layer_value(3, false)
	modulate = Color(0.55, 0.55, 0.55, 1.0)
	destroyed.emit()
