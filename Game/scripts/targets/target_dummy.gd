class_name TargetDummy
extends CharacterBody2D

@export var max_health: int = 50
const KNOCKBACK_MAX_SPEED: float = 640.0
var current_health: int
var _knockback_velocity_x: float = 0.0
var _knockback_remaining: float = 0.0
var _hook_pull_active: bool = false
var _hook_pull_anchor: Node2D
var _hook_pull_speed: float = 0.0
var _hook_stop_distance: float = 0.0
var _hook_stunned_remaining: float = 0.0

@onready var visual: ColorRect = $Visual
@onready var bleeding_controller: BleedingStatusController = $BleedingStatusController

func _ready() -> void:
	current_health = max_health

func _physics_process(delta: float) -> void:
	_hook_stunned_remaining = maxf(_hook_stunned_remaining - delta, 0.0)
	var bleeding_damage: int = bleeding_controller.advance(delta)
	if bleeding_damage > 0:
		take_damage(bleeding_damage)
		if current_health <= 0:
			_update_visual_feedback()
			return
	if _hook_pull_active:
		_process_hook_pull(delta)
	elif _knockback_remaining > 0.0:
		velocity = Vector2(_knockback_velocity_x, 0.0)
		move_and_slide()
		_knockback_remaining = maxf(_knockback_remaining - delta, 0.0)
		_knockback_velocity_x = move_toward(_knockback_velocity_x, 0.0, 1800.0 * delta)
	else:
		velocity = Vector2.ZERO
	_update_visual_feedback()

func take_damage(amount: int) -> void:
	current_health = maxi(current_health - amount, 0)
	_update_visual_feedback()
	if current_health == 0:
		_disable_target()

func apply_knockback(impulse: Vector2) -> void:
	_knockback_velocity_x = clampf(impulse.x, -KNOCKBACK_MAX_SPEED, KNOCKBACK_MAX_SPEED)
	_knockback_remaining = 0.18

func apply_bleeding(damage_per_tick: int, tick_interval: float, tick_count: int) -> bool:
	if current_health <= 0:
		return false
	return bleeding_controller.apply_bleeding(damage_per_tick, tick_interval, tick_count)

func is_bleeding() -> bool:
	return bleeding_controller.is_active()

func begin_hook_pull(pull_anchor: Node2D, pull_speed: float, stop_distance: float, stun_duration: float) -> bool:
	if pull_anchor == null or current_health <= 0 or _hook_pull_active:
		return false
	_hook_pull_anchor = pull_anchor
	_hook_pull_speed = maxf(pull_speed, 0.0)
	_hook_stop_distance = maxf(stop_distance, 0.0)
	_hook_pull_active = true
	_hook_stunned_remaining = maxf(stun_duration, 0.0)
	_knockback_remaining = 0.0
	velocity = Vector2.ZERO
	_update_visual_feedback()
	return _hook_pull_active

func cancel_hook_pull() -> void:
	_hook_pull_active = false
	_hook_pull_anchor = null
	velocity = Vector2.ZERO

func is_hook_pull_active() -> bool:
	return _hook_pull_active

func get_hook_anchor_position() -> Vector2:
	return global_position + Vector2(0, -40)

func is_hook_stunned() -> bool:
	return _hook_stunned_remaining > 0.0

func _process_hook_pull(delta: float) -> void:
	if _hook_pull_anchor == null or not is_instance_valid(_hook_pull_anchor) or current_health <= 0:
		cancel_hook_pull()
		return
	var offset_to_player: Vector2 = _hook_pull_anchor.global_position - get_hook_anchor_position()
	var distance_to_player: float = offset_to_player.length()
	if distance_to_player <= _hook_stop_distance:
		cancel_hook_pull()
		return
	var pull_direction: Vector2 = offset_to_player.normalized()
	var step_speed: float = minf(_hook_pull_speed, (distance_to_player - _hook_stop_distance) / maxf(delta, 0.0001))
	var previous_distance: float = distance_to_player
	velocity = pull_direction * step_speed
	move_and_slide()
	var distance_after_move: float = (_hook_pull_anchor.global_position - get_hook_anchor_position()).length()
	if distance_after_move >= previous_distance - 0.1:
		cancel_hook_pull()

func _update_visual_feedback() -> void:
	if current_health <= 0:
		visual.modulate = Color(0.3, 0.3, 0.3)
		return
	if is_hook_stunned():
		visual.modulate = Color(0.25, 0.85, 1.0)
		return
	if is_bleeding():
		visual.modulate = Color(1.0, 0.1, 0.1)
		return
	var health_ratio := float(current_health) / float(max_health)
	visual.modulate = Color(1.0, 0.4 + health_ratio * 0.6, 0.4)

func _disable_target() -> void:
	cancel_hook_pull()
	bleeding_controller.clear()
	set_collision_layer_value(3, false)
	visual.modulate = Color(0.3, 0.3, 0.3)
