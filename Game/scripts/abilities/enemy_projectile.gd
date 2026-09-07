class_name EnemyProjectile
extends Area2D

var direction: Vector2 = Vector2.LEFT
var speed: float = 720.0
var damage: float = 20.0
var lifetime: float = 3.0
var _movement_velocity: Vector2 = Vector2.ZERO
var _configured: bool = false
var _damage_resolved: bool = false
var _shield_processed: bool = false

func configure(new_direction: Vector2, new_speed: float, new_damage: float, new_lifetime: float) -> void:
	direction = new_direction.normalized() if new_direction.length_squared() > 0.0 else Vector2.LEFT
	speed = maxf(new_speed, 0.0)
	damage = maxf(new_damage, 0.0)
	lifetime = maxf(new_lifetime, 0.0)
	_configured = true

func _ready() -> void:
	if not _configured:
		push_error("EnemyProjectile must be configured before it enters the scene tree.")
		set_physics_process(false)
		return
	rotation = direction.angle()
	_movement_velocity = direction * speed
	var timer: SceneTreeTimer = get_tree().create_timer(lifetime)
	timer.timeout.connect(queue_free)

func _physics_process(delta: float) -> void:
	if _damage_resolved:
		return
	position += _movement_velocity * delta
	if not _shield_processed:
		for area: Area2D in get_overlapping_areas():
			var shield_controller: ShieldController = area.get_parent() as ShieldController
			if shield_controller == null:
				continue
			_shield_processed = true
			var remainder: float = shield_controller.absorb_damage(damage)
			if remainder <= 0.0:
				_damage_resolved = true
				queue_free()
				return
			damage = remainder
			break
	for body: Node2D in get_overlapping_bodies():
		if body.has_method(&"receive_damage"):
			_damage_resolved = true
			body.call(&"receive_damage", damage)
			queue_free()
			return
		if body.collision_layer & 1:
			_damage_resolved = true
			queue_free()
			return
