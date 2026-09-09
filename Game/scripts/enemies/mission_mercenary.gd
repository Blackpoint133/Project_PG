class_name MissionMercenary
extends TargetDummy

signal defeated(enemy: MissionMercenary)

@export var starts_active: bool = false
@export var ranged_attack_enabled: bool = true
@export var attack_interval: float = 1.5
@export var projectile_speed: float = 720.0
@export var projectile_damage: float = 10.0
@export var projectile_lifetime: float = 4.0
@export var base_visual_color: Color = Color(0.45, 0.55, 0.65, 1.0)

@onready var hostile_projectile_emitter: HostileProjectileEmitter = $HostileProjectileEmitter

var _is_active: bool = false
var _defeat_reported: bool = false

func _ready() -> void:
	super._ready()
	visual.color = base_visual_color
	hostile_projectile_emitter.interval = attack_interval
	hostile_projectile_emitter.projectile_speed = projectile_speed
	hostile_projectile_emitter.projectile_damage = projectile_damage
	hostile_projectile_emitter.projectile_lifetime = projectile_lifetime
	visible = false
	set_collision_layer(0)
	_set_emitter_enabled(false)
	set_physics_process(false)
	if starts_active:
		activate()

func activate() -> bool:
	if _is_active or current_health <= 0 or _defeat_reported:
		return false
	_is_active = true
	visible = true
	set_collision_layer_value(3, true)
	set_collision_mask(1)
	set_physics_process(true)
	_set_emitter_enabled(ranged_attack_enabled)
	return true

func take_damage(amount: int) -> void:
	if amount <= 0 or not _is_active or current_health <= 0:
		return
	super.take_damage(amount)
	if current_health <= 0 and not _defeat_reported:
		_defeat_reported = true
		_is_active = false
		_set_emitter_enabled(false)
		set_collision_layer(0)
		set_physics_process(false)
		defeated.emit(self)

func is_active() -> bool:
	return _is_active

func is_destroyed() -> bool:
	return _defeat_reported

func _physics_process(delta: float) -> void:
	_set_emitter_enabled(ranged_attack_enabled and not is_hook_stunned() and not is_hook_pull_active())
	super._physics_process(delta)

func _set_emitter_enabled(enabled: bool) -> void:
	hostile_projectile_emitter.process_mode = Node.PROCESS_MODE_INHERIT if enabled else Node.PROCESS_MODE_DISABLED
