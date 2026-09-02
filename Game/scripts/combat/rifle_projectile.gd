extends Area2D

var direction := Vector2.RIGHT
var speed := 900.0
var damage := 10
var lifetime := 1.5
var _has_dealt_damage := false

func _ready() -> void:
	rotation = direction.angle()
	velocity = direction * speed
	var timer := get_tree().create_timer(lifetime)
	timer.timeout.connect(queue_free)

func _physics_process(delta: float) -> void:
	position += velocity * delta

func _on_body_entered(body: Node2D) -> void:
	if _has_dealt_damage:
		return
	if body.has_method("take_damage"):
		_has_dealt_damage = true
		body.take_damage(damage)
		queue_free()
	else:
		queue_free()
