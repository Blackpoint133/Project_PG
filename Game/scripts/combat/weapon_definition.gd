class_name WeaponDefinition
extends Resource

@export var display_name: String = "AUTOMATIC RIFLE"
@export var automatic_fire: bool = true
@export var projectiles_per_shot: int = 1
@export var spread_degrees: float = 0.0
@export var fire_rate: float = 10.0
@export var magazine_size: int = 30
@export var reserve_ammo: int = 90
@export var reload_time: float = 1.2
@export var projectile_speed: float = 900.0
@export var projectile_lifetime: float = 1.5
@export var damage: int = 10
@export var projectile_scene: PackedScene
