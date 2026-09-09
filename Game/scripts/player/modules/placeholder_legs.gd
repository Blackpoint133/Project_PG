extends Node2D

@onready var standing_visual: CanvasItem = $StandingVisual
@onready var crouching_visual: CanvasItem = $CrouchingVisual

func set_crouching(crouching: bool) -> void:
	standing_visual.visible = not crouching
	crouching_visual.visible = crouching
