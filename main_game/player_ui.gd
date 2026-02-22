extends CanvasLayer

var player_id: int = 1 # This will be set by the Player scene on ready

@onready var ghost_prompt = $GhostPrompt
@onready var dialogue_box = $DialogueBox
@onready var name_label = $DialogueBox/HBoxContainer/VBoxContainer/NameLabel
@onready var text_label = $DialogueBox/HBoxContainer/VBoxContainer/TextLabel
@onready var stats_label = $HUD/VBoxContainer/StatsLabel

func _ready() -> void:
	# 1. Listen to the Event Bus for dialogue/prompts
	EventBus.show_prompt.connect(_on_show_prompt)
	EventBus.hide_prompt.connect(_on_hide_prompt)
	EventBus.show_dialogue.connect(_on_show_dialogue)
	EventBus.hide_dialogue.connect(_on_hide_dialogue)
	
	# 2. Listen to GlobalStats for HUD updates
	GlobalStats.stat_changed.connect(_on_stat_changed)
	
	# Initial setup
	if player_id == 1:
		stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		stats_label.text = "First Talks: " + str(GlobalStats.p1_first_talks)
	else:
		stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		stats_label.text = "First Talks: " + str(GlobalStats.p2_first_talks)

# --- SIGNAL LISTENERS ---
func _on_stat_changed(id: int, stat_name: String, new_value: int) -> void:
	if id == player_id and stat_name == "first_talks":
		stats_label.text = "First Talks: " + str(new_value)

func _on_show_prompt(id: int, text: String) -> void:
	if id == player_id:
		ghost_prompt.text = text
		ghost_prompt.show()

func _on_hide_prompt(id: int) -> void:
	if id == player_id:
		ghost_prompt.hide()

func _on_show_dialogue(id: int, npc_name: String, dialogue: String) -> void:
	if id == player_id:
		ghost_prompt.hide()
		name_label.text = npc_name
		text_label.text = dialogue
		dialogue_box.show()

func _on_hide_dialogue(id: int) -> void:
	if id == player_id:
		dialogue_box.hide()
