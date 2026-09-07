class_name KineticCounterProjectile
extends Area2D

var direction: Vector2 = Vector2.RIGHT
var speed: float = 900.0
var damage: float = 0.0
var lifetime: float = 2.0
var _movement_velocity: Vector2 = Vector2.ZERO
var _has_dealt_damage: bool = false
var _configured: bool = false

func configure(new_direction: Vector2, new_speed: float, new_damage: float, new_lifetime: float) -> void:
	direction = new_direction.normalized() if new_direction.length_squared() > 0.0 else Vector2.RIGHT
	speed = maxf(new_speed, 0.0)
	damage = maxf(new_damage, 0.0)
	lifetime = maxf(new_lifetime, 0.0)
	_configured = true

func _ready() -> void:
	if not _configured:
		push_error("KineticCounterProjectile must be configured before it enters the scene tree.")
		set_physics_process(false)
		return
	rotation = direction.angle()
	_movement_velocity = direction * speed
	var timer: SceneTreeTimer = get_tree().create_timer(lifetime)
	timer.timeout.connect(queue_free)

func _physics_process(delta: float) -> void:
	position += _movement_velocity * delta

func _on_body_entered(body: Node2D) -> void:
	if _has_dealt_damage:
		return
	if body.has_method(&"take_damage"):
		_has_dealt_damage = true
		var damage_amount: int = maxi(int(round(damage)), 0)
		body.call(&"take_damage", damage_amount)
		queue_free()
	else:
		queue_free()
