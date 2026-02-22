extends CanvasLayer

var player_id: int = 1 

@onready var ghost_prompt = $GhostPrompt
@onready var stats_label = $HUD/VBoxContainer/StatsLabel

# New UI References
@onready var dialogue_margin = $DialogueMargin
@onready var bubble_bg = $DialogueMargin/BubbleBG
@onready var text_padding = $DialogueMargin/BubbleBG/TextPadding
@onready var name_label = $DialogueMargin/BubbleBG/TextPadding/HBoxContainer/VBoxContainer/NameLabel
@onready var text_label = $DialogueMargin/BubbleBG/TextPadding/HBoxContainer/VBoxContainer/TextLabel

# Load your 6 frames here! Update the paths to match your folder.
var bubble_frames = [
	preload("res://assets/bubble/Text1.PNG"),
	preload("res://assets/bubble/Text2.PNG"),
	preload("res://assets/bubble/Text3.PNG"),
	preload("res://assets/bubble/Text4.PNG"),
	preload("res://assets/bubble/Text5.PNG"),
	preload("res://assets/bubble/Text6.PNG")
]

# New State tracking!
var bubble_state: String = "closed" # States: "closed", "opening", "open", "closing"

func _ready() -> void:
	dialogue_margin.hide() # Hide it by default
	
	EventBus.show_prompt.connect(_on_show_prompt)
	EventBus.hide_prompt.connect(_on_hide_prompt)
	EventBus.show_dialogue.connect(_on_show_dialogue)
	EventBus.hide_dialogue.connect(_on_hide_dialogue)
	GlobalStats.stat_changed.connect(_on_stat_changed)
	
	if player_id == 1:
		stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		stats_label.text = "First Talks: " + str(GlobalStats.p1_first_talks)
	else:
		stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		stats_label.text = "First Talks: " + str(GlobalStats.p2_first_talks)


# --- DIALOGUE ANIMATION LOGIC ---

func _on_show_dialogue(id: int, npc_name: String, dialogue: String) -> void:
	if id == player_id:
		ghost_prompt.hide()
		name_label.text = npc_name
		text_label.text = dialogue
		open_bubble()

func _on_hide_dialogue(id: int) -> void:
	if id == player_id:
		close_bubble()

func open_bubble():
	# Only open if it's currently fully closed
	if bubble_state != "closed": return
	bubble_state = "opening"
	
	text_padding.hide() 
	dialogue_margin.show()
	
	# 1. Pop Open (Animate frames 1 to 4 -> Indices 0 to 3)
	for i in range(4): 
		if bubble_state != "opening": return # Stop if interrupted!
		bubble_bg.texture = bubble_frames[i]
		await get_tree().create_timer(0.04).timeout 
		
	# 2. Text appears and we switch to Idle mode!
	text_padding.show() 
	
	if bubble_state == "opening":
		bubble_state = "open"
		_idle_bubble_loop()

func _idle_bubble_loop():
	var use_frame_six = false
	
	# Keep looping back and forth as long as the bubble remains open
	while bubble_state == "open":
		# Swap between index 4 (Text5) and index 5 (Text6)
		if use_frame_six:
			bubble_bg.texture = bubble_frames[5]
		else:
			bubble_bg.texture = bubble_frames[4]
			
		use_frame_six = not use_frame_six
		
		# Idle animation speed! (Slightly slower than pop-in so it doesn't vibrate violently)
		await get_tree().create_timer(0.15).timeout 

func close_bubble():
	# Only close if it's currently open or opening
	if bubble_state == "closed" or bubble_state == "closing": return
	bubble_state = "closing"
	
	text_padding.hide() 
	
	# 3. Pop Closed (Animate from frame 4 down to 1 -> Indices 3 down to 0)
	for i in range(3, -1, -1):
		bubble_bg.texture = bubble_frames[i]
		await get_tree().create_timer(0.04).timeout
		
	dialogue_margin.hide() 
	bubble_state = "closed"

# --- OTHER LISTENERS ---
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
