class_name BaseHUD
extends CanvasLayer

@export var player_id: int = 1

@onready var main_ui_container: VBoxContainer = $Control/VBoxContainer
@onready var main_control: Control = $Control
@onready var evidence_label: Label = $Control/VBoxContainer/EvidenceLabel
@onready var emotion_icon: TextureRect = $Control/VBoxContainer/EmotionRow/EmotionIcon
@onready var emotion_label: Label = $Control/VBoxContainer/EmotionRow/EmotionLabel
@onready var emotion_row: HBoxContainer = $Control/VBoxContainer/EmotionRow
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

const EMOTION_EFFECTS := {
	EmotionData.Emotion.ANGER:      "Anger\nMove faster",
	EmotionData.Emotion.SADNESS:    "Sadness\nMove slower",
	EmotionData.Emotion.FEAR:       "Fear\nControls are reversed",
	EmotionData.Emotion.LONELINESS: "Loneliness\nCamera zooms in",
	EmotionData.Emotion.JOY:        "Joy\nDouble tap a direction to dash",
	EmotionData.Emotion.NERVOUS:    "Nervous\nMovement is slippery",
	EmotionData.Emotion.GRATEFUL:   "Grateful\nCamera zooms out",
}

const EMOTION_ICONS := {
	EmotionData.Emotion.ANGER:      ["AlienAngry",    "BlooberMad"],
	EmotionData.Emotion.SADNESS:    ["AlienSad",      "BlooberSad"],
	EmotionData.Emotion.FEAR:       ["AlienFear",     "BlooberFear"],
	EmotionData.Emotion.LONELINESS: ["AlienLonely",   "BlooberLonely"],
	EmotionData.Emotion.JOY:        ["AlienJoy",      "BlooberJoy"],
	EmotionData.Emotion.NERVOUS:    ["AlienNervous",  "BlooberNervous"],
	EmotionData.Emotion.GRATEFUL:   ["AlienGrateful", "BlooberGrateful"],
}

func _update_emotion_display(emotion: EmotionData.Emotion) -> void:
	if emotion == EmotionData.Emotion.NONE:
		duration_bar.visible = false
		emotion_row.visible = false
	else:
		duration_bar.visible = true
		emotion_row.visible = true
		var duration: float = EmotionData.get_duration(emotion)
		duration_bar.max_value = max(duration, 0.01)
		var names: Array = EMOTION_ICONS.get(emotion, [])
		if names.size() > 0:
			var idx := 0 if player_id == 1 else 1
			var path := "res://assets/emotions/%s.png" % names[idx]
			emotion_icon.texture = load(path)
		emotion_label.text = EMOTION_EFFECTS.get(emotion, "")

func _update_evidence_display(amount: int) -> void:
	evidence_label.text = "Evidence: " + str(amount)
