extends Area2D

# ==========================================
@export var npc_name: String = "Mysterious Stranger"
@export var ghost_text: String = "Press Interact to Listen"

# State: first_contact, other has talked, keep talking
@export var p1_first_contact_dialogues: Array[String] = [
	"Are you seriously dragging me into this?",
	"I already told you, I don't know who took the good Tupperware!",
    "Take your marital disputes somewhere else before I call the Homeowners Association!"
]
@export var p1_first_contact_emotion: EmotionData.Emotion = EmotionData.Emotion.ANGER
@export var p1_cold_dialogues: Array[String] = [
	"Oh, great. The other half of the disaster.",
	"Your soon-to-be-ex was just here complaining about the shared Netflix password.",
    "Please, I just want to water my petunias in peace..."
]
@export var p1_cold_emotion: EmotionData.Emotion = EmotionData.Emotion.SADNESS
@export var p1_repeat_dialogues: Array[String] = [
	"I still don't know who shrunk your favorite sweater in the wash.",
    "Leave me out of your messy asset division."
]
@export var p1_repeat_emotion: EmotionData.Emotion = EmotionData.Emotion.SADNESS
@export var p2_first_contact_dialogues: Array[String] = [
	"Oh... hello. I heard about the split. Tragic, really.",
	"It's just devastating when a couple can't agree on who gets custody of the prized lawn gnome.",
    "I'm sorry, I just can't bear to take sides right now..."
]
@export var p2_first_contact_emotion: EmotionData.Emotion = EmotionData.Emotion.SADNESS
@export var p2_cold_dialogues: Array[String] = [
	"I can't believe your partner was just here aggressively demanding the fondue set.",
	"This whole divorce is tearing our weekly book club apart.",
    "Just go. My heart can't take any more neighborhood drama."
]
@export var p2_cold_emotion: EmotionData.Emotion = EmotionData.Emotion.SADNESS
@export var p2_repeat_dialogues: Array[String] = [
	"*sigh* Are you still looking for 'evidence' of the thermostat tampering?",
    "I have no more domestic secrets to reveal. Shoo."
]
@export var p2_repeat_emotion: EmotionData.Emotion = EmotionData.Emotion.SADNESS


@export var evidence_chance: float = 1.0  # 0.0–1.0 probability of giving evidence
# ==========================================

var dialogue_index: int = 0
var current_dialogues: Array[String] = []
var pending_emotion: EmotionData.Emotion = EmotionData.Emotion.NONE
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
			EventBus.show_prompt.emit(body.player_id, ghost_text)

func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		players_in_range.erase(body)

		EventBus.hide_prompt.emit(body.player_id)
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
			dialogue_index += 1

			if dialogue_index < current_dialogues.size():
				player.show_dialogue(npc_name, current_dialogues[dialogue_index])
			else:
				end_interaction()
			return

func start_interaction(player: Player):
	is_talking = true
	active_player = player
	
	# Turn off ghost prompts for everyone in the circle
	for p in players_in_range:
		EventBus.hide_prompt.emit(p.player_id)
		
	var id = player.player_id
	var chosen_emotion: EmotionData.Emotion = EmotionData.Emotion.NONE
	
	# Determine which of the 3 dialogues to use
	if id == 1:
		if has_p1_talked:
			current_dialogues = p1_repeat_dialogues
			chosen_emotion = p1_repeat_emotion
		elif someone_talked_first:
			current_dialogues = p1_cold_dialogues
			chosen_emotion = p1_cold_emotion
			has_p1_talked = true
		else:
			current_dialogues = p1_first_contact_dialogues
			chosen_emotion = p1_first_contact_emotion
			has_p1_talked = true
			someone_talked_first = true
	elif id == 2:
		if has_p2_talked:
			current_dialogues = p2_repeat_dialogues
			chosen_emotion = p2_repeat_emotion
		elif someone_talked_first:
			current_dialogues = p2_cold_dialogues
			chosen_emotion = p2_cold_emotion
			has_p2_talked = true
		else:
			current_dialogues = p2_first_contact_dialogues
			chosen_emotion = p2_first_contact_emotion
			has_p2_talked = true
			someone_talked_first = true

	dialogue_index = 0
	pending_emotion = chosen_emotion

	if current_dialogues.is_empty():
		print("Warning: NPC has no dialogue set for this state!")
		end_interaction()
		return
		
	# Send the final data to the active player's UI
	EventBus.show_dialogue.emit(player.player_id, npc_name, current_dialogues[dialogue_index])

func end_interaction():
	# Unlock the NPC
	if not active_player:
		return

	var id: int = active_player.player_id

	if pending_emotion != EmotionData.Emotion.NONE:
		EmotionManager.set_emotion(id, pending_emotion)
		pending_emotion = EmotionData.Emotion.NONE

	# Maybe give evidence later

	is_talking = false
	EventBus.hide_dialogue.emit(active_player.player_id)
	active_player = null
	
	# If anyone is still standing there waiting, turn their ghost prompt back on!
	for p in players_in_range:
		EventBus.show_prompt.emit(p.player_id, ghost_text)
