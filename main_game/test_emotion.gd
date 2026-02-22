extends Area2D

@export var emotion_to_apply: EmotionData.Emotion = EmotionData.Emotion.ANGER

@export var consume_on_touch: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		EmotionManager.set_emotion(body.player_id, emotion_to_apply)
		
		print("Player %d just picked up emotion: %s" % [body.player_id, EmotionData.Emotion.keys()[emotion_to_apply]])
		
		if consume_on_touch:
			queue_free()
