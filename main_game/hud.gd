class_name BaseHUD
extends CanvasLayer

@export var player_id: int = 1

@onready var main_ui_container: VBoxContainer = $Control/VBoxContainer
@onready var main_control: Control = $Control
@onready var evidence_label: Label = $Control/VBoxContainer/EvidenceLabel
@onready var emotion_label: Label = $Control/VBoxContainer/EmotionLabel
@onready var duration_bar: ProgressBar = $Control/VBoxContainer/DurationBar

func _ready() -> void:
	EmotionManager.emotion_changed.connect(_on_emotion_changed)
	GlobalStats.evidence_changed.connect(_on_evidence_changed)
	
	var current_emotion = EmotionManager.get_emotion(player_id)
	_update_emotion_display(current_emotion)
	
	var initial_evidence = GlobalStats.p1_evidence if player_id == 1 else GlobalStats.p2_evidence
	_update_evidence_display(initial_evidence)

func _process(_delta: float) -> void:
	if not duration_bar.visible:
		return
	var time_left = EmotionManager.get_emotion_time_left(player_id)
	duration_bar.value = time_left

func _on_emotion_changed(changed_player_id: int, emotion: EmotionData.Emotion) -> void:
	# Ignore signals meant for the other player
	if changed_player_id != player_id:
		return
		
	_update_emotion_display(emotion)

func _on_evidence_changed(changed_player_id: int, new_amount: int) -> void:
	if changed_player_id != player_id:
		return
		
	_update_evidence_display(new_amount)

# --- UI Updaters ---

func _update_emotion_display(emotion: EmotionData.Emotion) -> void:
	if emotion == EmotionData.Emotion.NONE:
		# Hide the bar completely when there is no emotion
		duration_bar.visible = false
	else:
		# Show the bar and safely set the max_value
		duration_bar.visible = true
		var duration: float = EmotionData.get_duration(emotion)
		# Use max() to guarantee max_value is never 0, preventing UI glitches
		duration_bar.max_value = max(duration, 0.01)
	emotion_label.text = "Emotion: " + str(emotion) 

func _update_evidence_display(amount: int) -> void:
	evidence_label.text = "Evidence: " + str(amount)
