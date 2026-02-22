extends Node

enum Ending {
	GOOD,
	BAD,
}

signal stat_changed(player_id: int, stat_name: String, new_value: int)
signal evidence_changed(player_id: int, new_amount: int)
signal game_over(ending_type: Ending)

var p1_evidence: int = 0
var p2_evidence: int = 0
var is_game_over: bool = false

func add_evidence(player_id: int, amount: int) -> void:
	if is_game_over: return

	if player_id == 1:
		p1_evidence += amount
		evidence_changed.emit(1, p1_evidence)
		if p1_evidence >= 10:
			is_game_over = true
			# CHANGE 3: Emit the enum instead of the string!
			game_over.emit(Ending.BAD)
	elif player_id == 2:
		p2_evidence += amount
		evidence_changed.emit(2, p2_evidence)
		if p2_evidence >= 10:
			is_game_over = true
			# CHANGE 4: Emit the enum instead of the string!
			game_over.emit(Ending.BAD)

var p1_first_talks: int = 0:
	set(value):
		p1_first_talks = value
		stat_changed.emit(1, "first_talks", value)

var p2_first_talks: int = 0:
	set(value):
		p2_first_talks = value
		stat_changed.emit(2, "first_talks", value)

var buildings_visited: int = 0:
	set(value):
		buildings_visited = value
		if buildings_visited >= 3 and not is_game_over:
			is_game_over = true
			# CHANGE 2: Emit the enum instead of the string!
			game_over.emit(Ending.GOOD)
