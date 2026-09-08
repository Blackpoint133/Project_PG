class_name MissionHelicopter
extends CharacterBody2D

signal health_changed(current_health: int, maximum_health: int)
signal destroyed(drop_position: Vector2, ejection_velocity: Vector2)

@export var maximum_health: int = 300
@export var horizontal_speed: float = 120.0
@export var patrol_min_x: float = 360.0
@export var patrol_max_x: float = 2200.0
@export var initial_direction: int = -1

var _current_health: int = 300
var _active: bool = false
var _destroyed: bool = false
var _patrol_direction: int = -1

@onready var visuals: Node2D = $Visuals
@onready var explosion_flash: Polygon2D = $ExplosionFlash
@onready var explosion_timer: Timer = $ExplosionTimer

func _ready() -> void:
	_current_health = maxi(maximum_health, 0)
	_patrol_direction = -1 if initial_direction < 0 else 1
	visible = false
	set_collision_layer_value(3, false)
	explosion_timer.timeout.connect(_on_explosion_timer_timeout)
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
	var destruction_position: Vector2 = global_position
	var inherited_velocity: Vector2 = velocity
	_destroyed = true
	_active = false
	velocity = Vector2.ZERO
	set_collision_layer_value(3, false)
	visuals.visible = false
	explosion_flash.visible = true
	explosion_timer.start(0.4)
	var ejection_velocity: Vector2 = Vector2(inherited_velocity.x * 0.5, -260.0)
	destroyed.emit(destruction_position, ejection_velocity)

func _on_explosion_timer_timeout() -> void:
	explosion_flash.visible = false
	visible = false
