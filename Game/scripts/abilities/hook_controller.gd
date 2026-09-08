class_name HookController
extends Node2D

signal hook_state_changed(state: String)

const STATE_IDLE: String = "idle"
const STATE_EXTENDING: String = "extending"
const STATE_PULLING: String = "pulling"

@onready var cable: Line2D = $Cable

var _player: Player
var _hook_origin: Marker2D
var _projectile: HookProjectile
var _target: TargetDummy
var _ability_definition: RightArmAbilityDefinition
var _state: String = STATE_IDLE
var _pull_remaining: float = 0.0

func _ready() -> void:
	_player = get_parent() as Player
	cable.visible = false

func set_hook_origin(origin: Marker2D) -> void:
	_hook_origin = origin
	_update_cable()

func get_hook_origin() -> Marker2D:
	return _hook_origin

func start_hook(ability_definition: RightArmAbilityDefinition, direction: Vector2) -> bool:
	if ability_definition == null or ability_definition.ability_id != "hook" or _state != STATE_IDLE:
		return false
	if ability_definition.projectile_scene == null or _hook_origin == null:
		return false
	var spawned_node: Node = ability_definition.projectile_scene.instantiate()
	var projectile: HookProjectile = spawned_node as HookProjectile
	if projectile == null:
		spawned_node.free()
		return false
	projectile.configure(direction, ability_definition.projectile_speed, ability_definition.maximum_range)
	var world_parent: Node = get_parent().get_parent()
	world_parent.add_child(projectile)
	projectile.global_position = _hook_origin.global_position
	projectile.hook_hit.connect(_on_projectile_hit)
	projectile.hook_finished.connect(_on_projectile_finished)
	_projectile = projectile
	_ability_definition = ability_definition
	_state = STATE_EXTENDING
	cable.visible = true
	hook_state_changed.emit(_state)
	_update_cable()
	return true

func cancel_hook() -> void:
	if _projectile != null:
		_projectile.cancel()
		_projectile = null
	if _target != null and _target.is_hook_pull_active():
		_target.cancel_hook_pull()
	_target = null
	_pull_remaining = 0.0
	_set_idle()

func get_state() -> String:
	return _state

func _physics_process(delta: float) -> void:
	if _state == STATE_EXTENDING:
		_update_cable()
	elif _state == STATE_PULLING:
		_pull_remaining = maxf(_pull_remaining - delta, 0.0)
		if _target == null or not is_instance_valid(_target) or not _target.is_hook_pull_active() or _pull_remaining <= 0.0:
			if _target != null and is_instance_valid(_target) and _target.is_hook_pull_active():
				_target.cancel_hook_pull()
			_target = null
			_set_idle()
		else:
			_update_cable()

func _on_projectile_hit(collider: Node2D) -> void:
	if _state != STATE_EXTENDING:
		return
	var target: TargetDummy = collider as TargetDummy
	if target == null or _ability_definition == null or not target.begin_hook_pull(_player, _ability_definition.pull_speed, _ability_definition.stop_distance, _ability_definition.stun_duration):
		return
	_target = target
	_pull_remaining = _ability_definition.maximum_pull_duration
	_state = STATE_PULLING
	hook_state_changed.emit(_state)
	_update_cable()

func _on_projectile_finished() -> void:
	_projectile = null
	if _state == STATE_EXTENDING:
		_set_idle()

func _set_idle() -> void:
	_state = STATE_IDLE
	_ability_definition = null
	cable.visible = false
	hook_state_changed.emit(_state)

func _update_cable() -> void:
	if _hook_origin == null or not cable.visible:
		return
	var end_position: Vector2 = _hook_origin.global_position
	if _state == STATE_EXTENDING and _projectile != null and is_instance_valid(_projectile):
		end_position = _projectile.global_position
	elif _state == STATE_PULLING and _target != null and is_instance_valid(_target):
		end_position = _target.get_hook_anchor_position()
	cable.points = PackedVector2Array([to_local(_hook_origin.global_position), to_local(end_position)])
