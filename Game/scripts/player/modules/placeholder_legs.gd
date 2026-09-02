extends Node2D

@onready var standing_visual: ColorRect = $StandingVisual
@onready var crouching_visual: ColorRect = $CrouchingVisual

func set_crouching(crouching: bool) -> void:
	standing_visual.visible = not crouching
	crouching_visual.visible = crouching
