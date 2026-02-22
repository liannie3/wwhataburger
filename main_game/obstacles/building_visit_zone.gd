extends Area2D

@export var building_name: String = "This Place"
@export var ghost_text: String = "Something meaningful happened here..."
@export var required_proximity: float = 200.0

var players_in_range: Array[Player] = []
var visited: bool = false
var visit_timer: float = 0.0
var timer_running: bool = false

const VISIT_DURATION: float = 2.0
const GHOST_TEXT_DURATION: float = 4.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if visited:
		return
	if body is Player and body not in players_in_range:
		players_in_range.append(body)

func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		players_in_range.erase(body)

func _physics_process(delta: float) -> void:
	if visited:
		return

	if _both_players_close():
		if not timer_running:
			timer_running = true
			visit_timer = 0.0
			EventBus.show_visit_prompt.emit("Stay close together...")
		visit_timer += delta
		if visit_timer >= VISIT_DURATION:
			_complete_visit()
	else:
		if timer_running:
			timer_running = false
			visit_timer = 0.0
			EventBus.hide_visit_prompt.emit()

func _both_players_close() -> bool:
	if players_in_range.size() < 2:
		return false
	var p1 = players_in_range[0]
	var p2 = players_in_range[1]
	return p1.global_position.distance_to(p2.global_position) <= required_proximity

func _complete_visit() -> void:
	visited = true
	timer_running = false
	monitoring = false
	EventBus.hide_visit_prompt.emit()

	GlobalStats.buildings_visited += 1

	# Show ghost text on both players' dialogue bubbles
	EventBus.show_dialogue.emit(1, building_name, ghost_text)
	EventBus.show_dialogue.emit(2, building_name, ghost_text)

	# Auto-hide after a few seconds
	await get_tree().create_timer(GHOST_TEXT_DURATION).timeout
	EventBus.hide_dialogue.emit(1)
	EventBus.hide_dialogue.emit(2)
