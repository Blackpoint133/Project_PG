class_name WorldWeaponPickup
extends CharacterBody2D

const INTERACTION_COOLDOWN: float = 0.35
const FLOOR_FRICTION: float = 1200.0

@export var weapon_definition: WeaponDefinition

@onready var weapon_label: Label = $WeaponLabel

var _interaction_cooldown: float = 0.0

func _ready() -> void:
	_update_display()

func _physics_process(delta: float) -> void:
	if _interaction_cooldown > 0.0:
		_interaction_cooldown = maxf(_interaction_cooldown - delta, 0.0)
	if not is_on_floor():
		velocity += get_gravity() * delta
	move_and_slide()
	if is_on_floor():
		velocity.x = move_toward(velocity.x, 0.0, FLOOR_FRICTION * delta)
		if velocity.y > 0.0:
			velocity.y = 0.0

func _update_display() -> void:
	var display_name: String = "UNKNOWN WEAPON"
	if weapon_definition != null:
		display_name = weapon_definition.display_name
	weapon_label.text = display_name

func set_weapon_definition(definition: WeaponDefinition) -> void:
	weapon_definition = definition
	_update_display()

func get_weapon_definition() -> WeaponDefinition:
	return weapon_definition

func is_available() -> bool:
	return weapon_definition != null and _interaction_cooldown <= 0.0

func get_interaction_prompt(actor: Node) -> String:
	if not is_available() or actor == null or not actor.has_method(&"get_equipped_weapon_definition"):
		return ""
	var equipped_variant: Variant = actor.call(&"get_equipped_weapon_definition")
	var equipped_definition: WeaponDefinition = equipped_variant as WeaponDefinition
	if equipped_definition == weapon_definition:
		return ""
	return "F: EQUIP %s" % weapon_definition.display_name

func interact(actor: Node) -> void:
	if not is_available() or actor == null or not actor.has_method(&"swap_weapon_with_pickup"):
		return
	actor.call(&"swap_weapon_with_pickup", self)

func launch(initial_velocity: Vector2) -> void:
	velocity = initial_velocity
	_interaction_cooldown = INTERACTION_COOLDOWN

func start_interaction_cooldown() -> void:
	_interaction_cooldown = INTERACTION_COOLDOWN
