extends CanvasLayer

@onready var movement_label: Label = $MovementLabel
@onready var weapon_label: Label = $WeaponLabel
var _is_reloading := false
var _loaded_ammo := 0
var _reserve_ammo := 0
var _weapon_name: String = ""

func _ready() -> void:
	set_process(true)
	var player: Player = get_tree().get_first_node_in_group("player")
	if player != null:
		_loaded_ammo = player.weapon_controller.get_loaded_ammo()
		_reserve_ammo = player.weapon_controller.get_reserve_ammo()
		_weapon_name = player.weapon_controller.get_display_name()
		_render_weapon_state()
		player.weapon_controller.reload_started.connect(_on_reload_started)
		player.weapon_controller.reload_completed.connect(_on_reload_completed)
		player.weapon_controller.weapon_ammo_changed.connect(_on_ammo_changed)
		player.weapon_controller.weapon_changed.connect(_on_weapon_changed)

func _process(_delta: float) -> void:
	var player: Player = get_tree().get_first_node_in_group("player")
	if player != null:
		movement_label.text = "MOVEMENT: %s" % player.movement_state

func _on_ammo_changed(loaded: int, reserve: int) -> void:
	_loaded_ammo = loaded
	_reserve_ammo = reserve
	if not _is_reloading:
		_render_weapon_state()

func _render_weapon_state() -> void:
	weapon_label.text = "%s %d / %d" % [_weapon_name, _loaded_ammo, _reserve_ammo]

func _on_reload_started() -> void:
	_is_reloading = true
	weapon_label.text = "RELOADING %s" % _weapon_name

func _on_reload_completed() -> void:
	_is_reloading = false
	_render_weapon_state()

func _on_weapon_changed(definition: WeaponDefinition) -> void:
	_weapon_name = definition.display_name
	_is_reloading = false
	_render_weapon_state()
