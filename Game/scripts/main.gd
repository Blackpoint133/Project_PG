extends Node2D

@onready var mission_controller: MissionController = $MissionController
@onready var mission_radio: MissionRadio = $World/MissionRadio
@onready var hud: GameHud = $HUD

func _ready() -> void:
	mission_radio.mission_activation_requested.connect(_on_mission_activation_requested)
	mission_controller.objective_changed.connect(_on_objective_changed)
	hud.set_mission_objective(mission_controller.get_objective_text())

func _on_mission_activation_requested(mission_id: String) -> void:
	if mission_controller.activate_mission(mission_id):
		mission_radio.set_available(false)

func _on_objective_changed(objective_text: String) -> void:
	hud.set_mission_objective(objective_text)
