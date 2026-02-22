extends Node

signal emotion_changed(player_id: int, emotion: EmotionData.Emotion)

var _emotions: Dictionary = {} # player_id (int) -> EmotionData.Emotion
var _timers: Dictionary = {}   # player_id (int) -> Timer node

func get_emotion(player_id: int) -> EmotionData.Emotion:
	return _emotions.get(player_id, EmotionData.Emotion.NONE)

func set_emotion(player_id: int, emotion: EmotionData.Emotion) -> void:
	_emotions[player_id] = emotion
	
	var timer: Timer = _get_or_create_timer(player_id)
	timer.stop() # Cancel existing timer if it's running
	
	var duration: float = EmotionData.get_duration(emotion)
	if duration > 0.0:
		timer.start(duration)
		
	emotion_changed.emit(player_id, emotion)

func _get_or_create_timer(player_id: int) -> Timer:
	if _timers.has(player_id):
		return _timers[player_id]
		
	var timer := Timer.new()
	timer.one_shot = true
	
	timer.timeout.connect(_on_emotion_expired.bind(player_id))
	
	add_child(timer)
	_timers[player_id] = timer
	return timer

func _on_emotion_expired(player_id: int) -> void:
	set_emotion(player_id, EmotionData.Emotion.NONE)

func get_emotion_time_left(player_id: int) -> float:
	if _timers.has(player_id) and not _timers[player_id].is_stopped():
		return _timers[player_id].time_left
	return 0.0
