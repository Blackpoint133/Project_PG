extends Node2D

@onready var mission_controller: MissionController = $MissionController
@onready var mission_radio: MissionRadio = $World/MissionRadio
@onready var mission_helicopter: MissionHelicopter = $World/MissionHelicopter
@onready var hud: GameHud = $HUD

func _ready() -> void:
	mission_radio.mission_activation_requested.connect(_on_mission_activation_requested)
	mission_controller.mission_activated.connect(_on_mission_activated)
	mission_controller.objective_changed.connect(_on_objective_changed)
	mission_helicopter.health_changed.connect(_on_helicopter_health_changed)
	mission_helicopter.destroyed.connect(_on_helicopter_destroyed)
	hud.set_mission_objective(mission_controller.get_objective_text())
	hud.hide_helicopter_health()

func _on_mission_activation_requested(mission_id: String) -> void:
	if mission_controller.activate_mission(mission_id):
		mission_radio.set_available(false)

func _on_objective_changed(objective_text: String) -> void:
	hud.set_mission_objective(objective_text)

func _on_mission_activated(mission_id: String) -> void:
	if mission_id == MissionController.DESTROY_HELICOPTER_ID:
		mission_helicopter.activate()

func _on_helicopter_health_changed(current_health: int, maximum_health: int) -> void:
	hud.set_helicopter_health(current_health, maximum_health)

func _on_helicopter_destroyed() -> void:
	if mission_controller.complete_mission(MissionController.DESTROY_HELICOPTER_ID):
		hud.hide_helicopter_health()
