extends Node

signal evidence_changed(player_id: int, new_amount: int)

var p1_first_talks: int = 0
var p2_first_talks: int = 0
var p1_evidence: int = 0
var p2_evidence: int = 0

func add_evidence(player_id: int, amount: int) -> void:
	if player_id == 1:
		p1_evidence += amount
		evidence_changed.emit(1, p1_evidence)
	elif player_id == 2:
		p2_evidence += amount
		evidence_changed.emit(2, p2_evidence)
