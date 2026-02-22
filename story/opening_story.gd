extends Control

signal sequence_finished

@onready var tutorial_split_screen = $SpitScreen

func _ready() -> void:
	tutorial_split_screen.tutorial_finished.connect(_on_tutorial_finished)

func _on_tutorial_finished() -> void:
	GlobalStats.reset()
	EmotionManager.set_emotion(1, EmotionData.Emotion.NONE)
	EmotionManager.set_emotion(2, EmotionData.Emotion.NONE)
	sequence_finished.emit()
