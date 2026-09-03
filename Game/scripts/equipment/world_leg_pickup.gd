class_name WorldLegPickup
extends CharacterBody2D

const INTERACTION_COOLDOWN: float = 0.35
const FLOOR_FRICTION: float = 1200.0

@export var leg_definition: LegDefinition

@onready var world_visual_slot: Node2D = $WorldVisualSlot
@onready var leg_label: Label = $LegLabel

var _interaction_cooldown: float = 0.0
var _leg_instance: LegInstance

func _ready() -> void:
	if leg_definition != null:
		_leg_instance = LegInstance.new(leg_definition)
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
	var display_name: String = "UNKNOWN LEGS"
	if _leg_instance != null and _leg_instance.definition != null:
		display_name = _leg_instance.definition.display_name
	leg_label.text = display_name

func _rebuild_world_visual() -> void:
	for child: Node in world_visual_slot.get_children():
		child.free()
	if _leg_instance == null or _leg_instance.definition == null or _leg_instance.definition.held_visual_scene == null:
		return
	var visual_node: Node = _leg_instance.definition.held_visual_scene.instantiate()
	var visual_transform: Node2D = visual_node as Node2D
	if visual_transform == null:
		visual_node.free()
		return
	world_visual_slot.add_child(visual_transform)
	visual_transform.position = Vector2(0, 0)

func set_leg_instance(instance: LegInstance) -> void:
	_leg_instance = instance
	leg_definition = null if instance == null else instance.definition
	_update_display()
	_rebuild_world_visual()

func get_leg_instance() -> LegInstance:
	return _leg_instance

func take_leg_instance() -> LegInstance:
	var instance: LegInstance = _leg_instance
	set_leg_instance(null)
	return instance

func get_leg_definition() -> LegDefinition:
	return null if _leg_instance == null else _leg_instance.definition

func is_available() -> bool:
	return _leg_instance != null and _leg_instance.definition != null and _interaction_cooldown <= 0.0

func get_interaction_prompt(actor: Node) -> String:
	if not is_available() or actor == null or not actor.has_method(&"get_equipped_leg_definition"):
		return ""
	return "F: EQUIP %s" % _leg_instance.definition.display_name

func interact(actor: Node) -> void:
	if not is_available() or actor == null or not actor.has_method(&"swap_legs_with_pickup"):
		return
	actor.call(&"swap_legs_with_pickup", self)

func launch(initial_velocity: Vector2) -> void:
	velocity = initial_velocity
	_interaction_cooldown = INTERACTION_COOLDOWN

func start_interaction_cooldown() -> void:
	_interaction_cooldown = INTERACTION_COOLDOWN
