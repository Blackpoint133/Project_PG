class_name TargetDummy
extends StaticBody2D

@export var max_health: int = 50
var current_health: int

@onready var visual: ColorRect = $Visual

func _ready() -> void:
	current_health = max_health

func take_damage(amount: int) -> void:
	current_health = maxi(current_health - amount, 0)
	_update_visual_feedback()
	if current_health == 0:
		_disable_target()

func _update_visual_feedback() -> void:
	var health_ratio := float(current_health) / float(max_health)
	visual.modulate = Color(1.0, 0.4 + health_ratio * 0.6, 0.4)

func _disable_target() -> void:
	set_collision_layer_value(3, false)
	visual.modulate = Color(0.3, 0.3, 0.3)
