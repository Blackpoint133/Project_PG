class_name WorldRightArmPickup
extends CharacterBody2D

signal pickup_completed(actor: Node)

const INTERACTION_COOLDOWN: float = 0.35
const FLOOR_FRICTION: float = 1200.0

@export var right_arm_definition: RightArmDefinition

@onready var world_visual_slot: Node2D = $WorldVisualSlot
@onready var right_arm_label: Label = $RightArmLabel

var _interaction_cooldown: float = 0.0
var _right_arm_instance: RightArmInstance
var _pickup_completion_reported: bool = false

func _ready() -> void:
	if right_arm_definition != null:
		_right_arm_instance = RightArmInstance.new(right_arm_definition)
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
	var display_name: String = "UNKNOWN RIGHT ARM"
	if _right_arm_instance != null and _right_arm_instance.definition != null:
		display_name = _right_arm_instance.definition.display_name
	right_arm_label.text = display_name

func _rebuild_world_visual() -> void:
	for child: Node in world_visual_slot.get_children():
		child.free()
	if _right_arm_instance == null or _right_arm_instance.definition == null:
		return
	var visual_scene: PackedScene = _right_arm_instance.definition.held_visual_scene
	if visual_scene == null:
		return
	var visual_node: Node = visual_scene.instantiate()
	var visual_transform: Node2D = visual_node as Node2D
	if visual_transform == null:
		visual_node.free()
		return
	world_visual_slot.add_child(visual_transform)
	visual_transform.position = Vector2.ZERO

func set_right_arm_instance(instance: RightArmInstance) -> void:
	_right_arm_instance = instance
	right_arm_definition = null if instance == null else instance.definition
	_update_display()
	_rebuild_world_visual()

func get_right_arm_instance() -> RightArmInstance:
	return _right_arm_instance

func take_right_arm_instance() -> RightArmInstance:
	var instance: RightArmInstance = _right_arm_instance
	set_right_arm_instance(null)
	return instance

func get_right_arm_definition() -> RightArmDefinition:
	return null if _right_arm_instance == null else _right_arm_instance.definition

func is_available() -> bool:
	return _right_arm_instance != null and _right_arm_instance.definition != null and _interaction_cooldown <= 0.0

func get_interaction_prompt(actor: Node) -> String:
	if not is_available() or actor == null or not actor.has_method(&"get_equipped_right_arm_definition"):
		return ""
	return "F: EQUIP %s" % _right_arm_instance.definition.display_name

func interact(actor: Node) -> void:
	if not is_available() or actor == null or not actor.has_method(&"swap_right_arm_with_pickup"):
		return
	var transfer_result: Variant = actor.call(&"swap_right_arm_with_pickup", self)
	if transfer_result is bool and bool(transfer_result) and not _pickup_completion_reported:
		_pickup_completion_reported = true
		pickup_completed.emit(actor)

func launch(initial_velocity: Vector2) -> void:
	velocity = initial_velocity
	_interaction_cooldown = INTERACTION_COOLDOWN

func start_interaction_cooldown() -> void:
	_interaction_cooldown = INTERACTION_COOLDOWN
