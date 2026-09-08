class_name HookProjectile
extends Area2D

signal hook_hit(collider: Node2D)
signal hook_finished

var direction: Vector2 = Vector2.RIGHT
var speed: float = 0.0
var maximum_range: float = 0.0
var _traveled_distance: float = 0.0
var _resolved: bool = false
var _configured: bool = false

func _ready() -> void:
	if not _configured:
		push_error("HookProjectile must be configured before it enters the scene tree.")
		set_physics_process(false)
		return
	rotation = direction.angle()

func configure(new_direction: Vector2, new_speed: float, new_maximum_range: float) -> void:
	direction = new_direction.normalized() if new_direction.length_squared() > 0.0 else Vector2.RIGHT
	speed = new_speed
	maximum_range = new_maximum_range
	_configured = true

func _physics_process(delta: float) -> void:
	if _resolved:
		return
	var previous_position: Vector2 = global_position
	var step_distance: float = speed * delta
	var remaining_range: float = maximum_range - _traveled_distance
	if remaining_range <= 0.0:
		_finish()
		return
	step_distance = minf(step_distance, remaining_range)
	var next_position: Vector2 = previous_position + direction * step_distance
	var excluded_rids: Array[RID] = [get_rid()]
	var query: PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.create(previous_position, next_position, 5, excluded_rids)
	var result: Dictionary = get_world_2d().direct_space_state.intersect_ray(query)
	if not result.is_empty():
		var collision_position: Vector2 = Vector2(result.get("position", next_position))
		global_position = collision_position
		var collider: Node2D = result.get("collider") as Node2D
		_resolved = true
		hook_hit.emit(collider)
		_finished()
		return
	global_position = next_position
	_traveled_distance += step_distance
	if _traveled_distance >= maximum_range:
		_finish()

func cancel() -> void:
	_finish()

func _finish() -> void:
	if _resolved:
		return
	_resolved = true
	_finished()

func _finished() -> void:
	hook_finished.emit()
	queue_free()
