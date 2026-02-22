extends Area2D

# ==========================================
@export var npc_name: String = "Mysterious Stranger"
@export var ghost_text: String = "Press Interact to Listen"

@export_multiline var first_dialogue: String = "You're the first traveler I've seen in weeks!"
@export_multiline var second_dialogue: String = "Oh, another one? Your friend was just here."
@export_multiline var repeat_dialogue: String = "I have nothing more to say to you."
# ==========================================

var has_p1_talked: bool = false
var has_p2_talked: bool = false
var someone_talked_first: bool = false

# The Interaction Lock!
var is_talking: bool = false
var active_player: Player = null 
var players_in_range: Array[Player] = []

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		players_in_range.append(body)
		# Only show the ghost prompt if the NPC isn't currently busy talking to someone else
		if not is_talking:
			body.show_prompt(ghost_text)

func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		players_in_range.erase(body)
		body.hide_prompt()
		# Safety check: if they walk away mid-sentence, unlock the NPC
		if is_talking and active_player == body:
			end_interaction()

func _input(event: InputEvent) -> void:
	if players_in_range.is_empty(): return
	
	for player in players_in_range:
		var interact_action = "p" + str(player.player_id) + "_interact"
		var advance_action = "p" + str(player.player_id) + "_advance"
		
		# 1. TRY TO START TALKING
		if not is_talking and event.is_action_pressed(interact_action):
			start_interaction(player)
			return # Stop checking, lock acquired!
			
		# 2. TRY TO ADVANCE/CLOSE TEXT
		# Only the player holding the lock can press the advance button
		if is_talking and active_player == player and event.is_action_pressed(advance_action):
			end_interaction()
			return

func start_interaction(player: Player):
	is_talking = true
	active_player = player
	
	# Turn off ghost prompts for everyone in the circle
	for p in players_in_range:
		p.hide_prompt()
		
	var text_to_say = ""
	var id = player.player_id
	
	# Determine which of the 3 dialogues to use
	if (id == 1 and has_p1_talked) or (id == 2 and has_p2_talked):
		text_to_say = repeat_dialogue
		
	elif not someone_talked_first:
		text_to_say = first_dialogue
		someone_talked_first = true
		
		# Update the global stats singleton!
		if id == 1: 
			has_p1_talked = true
			GlobalStats.p1_first_talks += 1
		else: 
			has_p2_talked = true
			GlobalStats.p2_first_talks += 1
			
	else:
		text_to_say = second_dialogue
		if id == 1: has_p1_talked = true
		else: has_p2_talked = true
		
	# Send the final data to the active player's UI
	player.show_dialogue(npc_name, text_to_say)

func end_interaction():
	# Unlock the NPC
	is_talking = false
	if active_player:
		active_player.hide_dialogue()
	active_player = null
	
	# If anyone is still standing there waiting, turn their ghost prompt back on!
	for p in players_in_range:
		p.show_prompt(ghost_text)
