class_name WorldLeftArmPickup
extends CharacterBody2D

const INTERACTION_COOLDOWN: float = 0.35
const FLOOR_FRICTION: float = 1200.0

@export var left_arm_definition: LeftArmDefinition

@onready var world_visual_slot: Node2D = $WorldVisualSlot
@onready var left_arm_label: Label = $LeftArmLabel

var _interaction_cooldown: float = 0.0
var _left_arm_instance: LeftArmInstance

func _ready() -> void:
	if left_arm_definition != null:
		_left_arm_instance = LeftArmInstance.new(left_arm_definition)
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
	var display_name: String = "UNKNOWN LEFT ARM"
	if _left_arm_instance != null and _left_arm_instance.definition != null:
		display_name = _left_arm_instance.definition.display_name
	left_arm_label.text = display_name

func _rebuild_world_visual() -> void:
	for child: Node in world_visual_slot.get_children():
		child.free()
	if _left_arm_instance == null or _left_arm_instance.definition == null:
		return
	var visual_scene: PackedScene = _left_arm_instance.definition.held_visual_scene
	if visual_scene == null:
		return
	var visual_node: Node = visual_scene.instantiate()
	var visual_transform: Node2D = visual_node as Node2D
	if visual_transform == null:
		visual_node.free()
		return
	world_visual_slot.add_child(visual_transform)
	visual_transform.position = Vector2.ZERO

func set_left_arm_instance(instance: LeftArmInstance) -> void:
	_left_arm_instance = instance
	left_arm_definition = null if instance == null else instance.definition
	_update_display()
	_rebuild_world_visual()

func get_left_arm_instance() -> LeftArmInstance:
	return _left_arm_instance

func take_left_arm_instance() -> LeftArmInstance:
	var instance: LeftArmInstance = _left_arm_instance
	set_left_arm_instance(null)
	return instance

func get_left_arm_definition() -> LeftArmDefinition:
	return null if _left_arm_instance == null else _left_arm_instance.definition

func is_available() -> bool:
	return _left_arm_instance != null and _left_arm_instance.definition != null and _interaction_cooldown <= 0.0

func get_interaction_prompt(actor: Node) -> String:
	if not is_available() or actor == null or not actor.has_method(&"get_equipped_left_arm_definition"):
		return ""
	return "F: EQUIP %s" % _left_arm_instance.definition.display_name

func interact(actor: Node) -> void:
	if not is_available() or actor == null or not actor.has_method(&"swap_left_arm_with_pickup"):
		return
	actor.call(&"swap_left_arm_with_pickup", self)

func launch(initial_velocity: Vector2) -> void:
	velocity = initial_velocity
	_interaction_cooldown = INTERACTION_COOLDOWN

func start_interaction_cooldown() -> void:
	_interaction_cooldown = INTERACTION_COOLDOWN
