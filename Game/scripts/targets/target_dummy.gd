class_name TargetDummy
extends AnimatableBody2D

@export var max_health: int = 50
const KNOCKBACK_MAX_SPEED: float = 640.0
var current_health: int
var _knockback_velocity_x: float = 0.0
var _knockback_remaining: float = 0.0

@onready var visual: ColorRect = $Visual

func _ready() -> void:
	current_health = max_health

func _physics_process(delta: float) -> void:
	if _knockback_remaining <= 0.0:
		return
	position.x += _knockback_velocity_x * delta
	_knockback_remaining = maxf(_knockback_remaining - delta, 0.0)
	_knockback_velocity_x = move_toward(_knockback_velocity_x, 0.0, 1800.0 * delta)

func take_damage(amount: int) -> void:
	current_health = maxi(current_health - amount, 0)
	_update_visual_feedback()
	if current_health == 0:
		_disable_target()

func apply_knockback(impulse: Vector2) -> void:
	_knockback_velocity_x = clampf(impulse.x, -KNOCKBACK_MAX_SPEED, KNOCKBACK_MAX_SPEED)
	_knockback_remaining = 0.18

func _update_visual_feedback() -> void:
	var health_ratio := float(current_health) / float(max_health)
	visual.modulate = Color(1.0, 0.4 + health_ratio * 0.6, 0.4)

func _disable_target() -> void:
	set_collision_layer_value(3, false)
	visual.modulate = Color(0.3, 0.3, 0.3)
