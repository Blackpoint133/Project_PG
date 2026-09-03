class_name WorldWeaponPickup
extends CharacterBody2D

const INTERACTION_COOLDOWN: float = 0.35
const FLOOR_FRICTION: float = 1200.0

@export var weapon_definition: WeaponDefinition

@onready var world_visual_slot: Node2D = $WorldVisualSlot
@onready var weapon_label: Label = $WeaponLabel

var _interaction_cooldown: float = 0.0
var _weapon_instance: WeaponInstance

func _ready() -> void:
	if weapon_definition != null:
		_weapon_instance = WeaponInstance.new(weapon_definition)
	_update_display()
	_rebuild_world_visual()

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
	if _weapon_instance != null and _weapon_instance.definition != null:
		display_name = _weapon_instance.definition.display_name
	weapon_label.text = display_name

func _rebuild_world_visual() -> void:
	for child: Node in world_visual_slot.get_children():
		child.free()
	if _weapon_instance == null or _weapon_instance.definition == null or _weapon_instance.definition.held_visual_scene == null:
		return
	var visual_node: Node = _weapon_instance.definition.held_visual_scene.instantiate()
	var visual_transform: Node2D = visual_node as Node2D
	if visual_transform == null:
		visual_node.free()
		return
	world_visual_slot.add_child(visual_transform)
	visual_transform.position = Vector2(-12, -10)

func set_weapon_definition(definition: WeaponDefinition) -> void:
	weapon_definition = definition
	_weapon_instance = WeaponInstance.new(definition) if definition != null else null
	_update_display()
	_rebuild_world_visual()

func set_weapon_instance(instance: WeaponInstance) -> void:
	_weapon_instance = instance
	weapon_definition = null if instance == null else instance.definition
	_update_display()
	_rebuild_world_visual()

func get_weapon_instance() -> WeaponInstance:
	return _weapon_instance

func take_weapon_instance() -> WeaponInstance:
	var instance: WeaponInstance = _weapon_instance
	set_weapon_instance(null)
	return instance

func get_weapon_definition() -> WeaponDefinition:
	return null if _weapon_instance == null else _weapon_instance.definition

func is_available() -> bool:
	return _weapon_instance != null and _weapon_instance.definition != null and _interaction_cooldown <= 0.0

func get_interaction_prompt(actor: Node) -> String:
	if not is_available() or actor == null or not actor.has_method(&"get_equipped_weapon_definition"):
		return ""
	return "F: EQUIP %s" % _weapon_instance.definition.display_name

func interact(actor: Node) -> void:
	if not is_available() or actor == null or not actor.has_method(&"swap_weapon_with_pickup"):
		return
	actor.call(&"swap_weapon_with_pickup", self)

func launch(initial_velocity: Vector2) -> void:
	velocity = initial_velocity
	_interaction_cooldown = INTERACTION_COOLDOWN

func start_interaction_cooldown() -> void:
	_interaction_cooldown = INTERACTION_COOLDOWN
