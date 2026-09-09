class_name MissionExtractionZone
extends Area2D

signal extraction_requested(actor: Node)

@onready var visual_field: ColorRect = $VisualField
@onready var outline: Line2D = $Outline
@onready var beacon: ColorRect = $Beacon
@onready var zone_label: Label = $ZoneLabel

var _is_active: bool = false
var _is_completed: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	visible = false
	monitoring = false
	collision_layer = 0
	collision_mask = 2

func activate() -> bool:
	if _is_active or _is_completed:
		return false
	_is_active = true
	visible = true
	visual_field.color = Color(0.1, 0.85, 1.0, 0.24)
	outline.default_color = Color(0.25, 0.9, 1.0, 1.0)
	beacon.color = Color(0.25, 0.9, 1.0, 1.0)
	zone_label.text = "EXTRACTION"
	set_deferred("monitoring", true)
	call_deferred("_check_existing_bodies_after_physics")
	return true

func complete() -> bool:
	if not _is_active or _is_completed:
		return false
	_is_active = false
	_is_completed = true
	set_deferred("monitoring", false)
	visual_field.color = Color(0.2, 1.0, 0.35, 0.24)
	outline.default_color = Color(0.35, 1.0, 0.45, 1.0)
	beacon.color = Color(0.35, 1.0, 0.45, 1.0)
	zone_label.text = "COMPLETE"
	return true

func is_active() -> bool:
	return _is_active

func is_completed() -> bool:
	return _is_completed

func _check_existing_bodies_after_physics() -> void:
	await get_tree().physics_frame
	await get_tree().physics_frame
	if not _is_active or _is_completed or not monitoring:
		return
	for body: Node2D in get_overlapping_bodies():
		_request_extraction(body)

func _on_body_entered(body: Node2D) -> void:
	if not _is_active or _is_completed:
		return
	_request_extraction(body)

func _request_extraction(actor: Node) -> void:
	if actor == null or not is_instance_valid(actor):
		return
	extraction_requested.emit(actor)
