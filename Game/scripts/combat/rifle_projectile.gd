class_name RifleProjectile
extends Area2D

var direction := Vector2.RIGHT
var speed := 900.0
var damage := 10
var lifetime := 1.5
var _movement_velocity := Vector2.ZERO
var _has_dealt_damage := false
var _configured := false

func _ready() -> void:
	if not _configured:
		push_error("RifleProjectile must be configured before it enters the scene tree.")
		set_physics_process(false)
		return
	rotation = direction.angle()
	_movement_velocity = direction * speed
	var timer := get_tree().create_timer(lifetime)
	timer.timeout.connect(queue_free)

func configure(new_direction: Vector2, new_speed: float, new_damage: int, new_lifetime: float) -> void:
	direction = new_direction
	speed = new_speed
	damage = new_damage
	lifetime = new_lifetime
	_configured = true

func _physics_process(delta: float) -> void:
	position += _movement_velocity * delta

func _on_body_entered(body: Node2D) -> void:
	if _has_dealt_damage:
		return
	if body.has_method("take_damage"):
		_has_dealt_damage = true
		body.take_damage(damage)
		queue_free()
	else:
		queue_free()
