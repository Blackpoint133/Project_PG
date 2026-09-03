class_name InteractionController
extends Area2D

signal prompt_changed(prompt_text: String)

var _candidates: Array[Node2D] = []
var _current_prompt: String = ""

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_refresh_prompt()

func _process(_delta: float) -> void:
	_refresh_prompt()

func _on_body_entered(body: Node2D) -> void:
	if _is_compatible_candidate(body) and not _candidates.has(body):
		_candidates.append(body)
	_refresh_prompt()

func _on_body_exited(body: Node2D) -> void:
	_candidates.erase(body)
	_refresh_prompt()

func _is_compatible_candidate(candidate: Node2D) -> bool:
	return candidate.has_method(&"get_interaction_prompt") and candidate.has_method(&"interact")

func _get_candidate_prompt(candidate: Node2D, actor: Node) -> String:
	if not is_instance_valid(candidate) or candidate.is_queued_for_deletion():
		return ""
	if not _is_compatible_candidate(candidate):
		return ""
	var prompt_variant: Variant = candidate.call(&"get_interaction_prompt", actor)
	if prompt_variant is String:
		return prompt_variant as String
	return ""

func _get_nearest_candidate(actor: Node) -> Node2D:
	var nearest_candidate: Node2D = null
	var nearest_distance_squared: float = INF
	var index: int = _candidates.size() - 1
	while index >= 0:
		var candidate: Node2D = _candidates[index]
		if not is_instance_valid(candidate) or candidate.is_queued_for_deletion():
			_candidates.remove_at(index)
			index -= 1
			continue
		var prompt_text: String = _get_candidate_prompt(candidate, actor)
		if prompt_text.is_empty():
			index -= 1
			continue
		var distance_squared: float = global_position.distance_squared_to(candidate.global_position)
		if distance_squared < nearest_distance_squared:
			nearest_distance_squared = distance_squared
			nearest_candidate = candidate
		index -= 1
	return nearest_candidate

func _refresh_prompt() -> void:
	var actor: Node = get_parent()
	var nearest_candidate: Node2D = _get_nearest_candidate(actor)
	var next_prompt: String = ""
	if nearest_candidate != null:
		next_prompt = _get_candidate_prompt(nearest_candidate, actor)
	if next_prompt != _current_prompt:
		_current_prompt = next_prompt
		prompt_changed.emit(_current_prompt)

func refresh_prompt() -> void:
	_refresh_prompt()

func get_current_prompt() -> String:
	return _current_prompt

func try_interact(actor: Node) -> void:
	var nearest_candidate: Node2D = _get_nearest_candidate(actor)
	if nearest_candidate == null or not nearest_candidate.has_method(&"interact"):
		_refresh_prompt()
		return
	nearest_candidate.call(&"interact", actor)
	_refresh_prompt()
