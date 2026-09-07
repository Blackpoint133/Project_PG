class_name HostileProjectileEmitter
extends Node2D

@export var projectile_scene: PackedScene
@export var interval: float = 1.0
@export var projectile_speed: float = 720.0
@export var projectile_damage: float = 20.0
@export var projectile_lifetime: float = 3.0

var _time_until_shot: float = 0.0

func _physics_process(delta: float) -> void:
	_time_until_shot = maxf(_time_until_shot - delta, 0.0)
	if _time_until_shot > 0.0 or projectile_scene == null:
		return
	_time_until_shot = maxf(interval, 0.01)
	var player: Node2D = get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return
	var direction: Vector2 = Vector2(-1.0, 0.0) if player.global_position.x <= global_position.x else Vector2(1.0, 0.0)
	var spawned_node: Node = projectile_scene.instantiate()
	var projectile: EnemyProjectile = spawned_node as EnemyProjectile
	if projectile == null:
		spawned_node.free()
		return
	projectile.configure(direction, projectile_speed, projectile_damage, projectile_lifetime)
	get_tree().current_scene.add_child(projectile)
	projectile.global_position = global_position
