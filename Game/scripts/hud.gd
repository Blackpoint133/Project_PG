extends CanvasLayer

@onready var movement_label: Label = $MovementLabel

func _ready() -> void:
	set_process(true)

func _process(_delta: float) -> void:
	var player: Player = get_tree().get_first_node_in_group("player")
	if player != null:
		movement_label.text = "MOVEMENT: %s" % player.movement_state
