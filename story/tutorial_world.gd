extends Node2D

signal tutorial_complete

enum TutorialStep { MOVE, APPROACH_NPC, DONE }

var p1_step: TutorialStep = TutorialStep.MOVE
var p2_step: TutorialStep = TutorialStep.MOVE

var p1_has_moved: bool = false
var p2_has_moved: bool = false

var p1_completed: bool = false
var p2_completed: bool = false

@onready var player1: Player = $Player
@onready var player2: Player = $Player2

var p1_start_pos: Vector2
var p2_start_pos: Vector2

const MOVE_THRESHOLD: float = 50.0

func _ready() -> void:
	p1_start_pos = player1.position
	p2_start_pos = player2.position

	# Override camera limits for the small tutorial room
	for player in [player1, player2]:
		var cam = player.get_node("Camera2D")
		cam.limit_left = 0
		cam.limit_top = 0
		cam.limit_right = 800
		cam.limit_bottom = 600

	GlobalStats.evidence_changed.connect(_on_evidence_changed)

	await get_tree().create_timer(0.5).timeout
	EventBus.show_prompt.emit(1, "P1: Use WASD to move!")
	EventBus.show_prompt.emit(2, "P2: Use IJKL or arrow keys to move!")

func _physics_process(_delta: float) -> void:
	if p1_step == TutorialStep.MOVE and not p1_has_moved:
		if player1.position.distance_to(p1_start_pos) > MOVE_THRESHOLD:
			p1_has_moved = true
			_advance_player(1)

	if p2_step == TutorialStep.MOVE and not p2_has_moved:
		if player2.position.distance_to(p2_start_pos) > MOVE_THRESHOLD:
			p2_has_moved = true
			_advance_player(2)

func _advance_player(player_id: int) -> void:
	if player_id == 1:
		p1_step = TutorialStep.APPROACH_NPC
		EventBus.hide_prompt.emit(1)
		await get_tree().create_timer(0.3).timeout
		EventBus.show_prompt.emit(1, "Walk up to the NPC!")
	else:
		p2_step = TutorialStep.APPROACH_NPC
		EventBus.hide_prompt.emit(2)
		await get_tree().create_timer(0.3).timeout
		EventBus.show_prompt.emit(2, "Walk up to the NPC!")

func _on_evidence_changed(player_id: int, _new_amount: int) -> void:
	if player_id == 1 and not p1_completed:
		p1_completed = true
		p1_step = TutorialStep.DONE
		_check_both_done()
	elif player_id == 2 and not p2_completed:
		p2_completed = true
		p2_step = TutorialStep.DONE
		_check_both_done()

func _check_both_done() -> void:
	if p1_completed and p2_completed:
		await get_tree().create_timer(1.5).timeout
		EventBus.show_prompt.emit(1, "Tutorial complete!")
		EventBus.show_prompt.emit(2, "Tutorial complete!")
		await get_tree().create_timer(2.0).timeout
		EventBus.hide_prompt.emit(1)
		EventBus.hide_prompt.emit(2)
		tutorial_complete.emit()
