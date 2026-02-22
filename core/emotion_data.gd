class_name EmotionData
extends RefCounted

enum Emotion {
	NONE,
	ANGER,
	SADNESS,
	FEAR,
	CONTEMPT,
	ZOOM_IN,
	ZOOM_OUT,
	REVERSE_CONTROLS,
	DOUBLE_EVIDENCE,
	LOSE_EVIDENCE
}

const DEFAULT_ZOOM := Vector2(1.0, 1.0)

const SPEED_MULTIPLIER: Dictionary = {
	Emotion.ANGER: 1.5,
	Emotion.SADNESS: 0.5
}

const ACCELERATION: Dictionary = {
	Emotion.CONTEMPT: 8.0
}

const HAS_DASH: Dictionary = {
	Emotion.FEAR: true
}

const CAMERA_ZOOM: Dictionary = {
	Emotion.ZOOM_IN: Vector2(2.0, 2.0),
	Emotion.ZOOM_OUT: Vector2(0.5, 0.5)
}

const DURATION: Dictionary = {
	Emotion.NONE: 0.0,
	Emotion.ANGER: 10.0,
	Emotion.SADNESS: 10.0,
	Emotion.FEAR: 10.0,
	Emotion.CONTEMPT: 10.0,
	Emotion.ZOOM_IN: 10.0,
	Emotion.ZOOM_OUT: 10.0,
	Emotion.REVERSE_CONTROLS: 10.0,
	Emotion.DOUBLE_EVIDENCE: 10.0,
	Emotion.LOSE_EVIDENCE: 10.0
}

static func get_speed_multiplier(emotion: Emotion) -> float:
	return SPEED_MULTIPLIER.get(emotion, 1.0)

static func get_acceleration(emotion: Emotion) -> float:
	return ACCELERATION.get(emotion, 0.0)

static func has_dash(emotion: Emotion) -> bool:
	return HAS_DASH.get(emotion, false)

static func get_camera_zoom(emotion: Emotion) -> Vector2:
	return CAMERA_ZOOM.get(emotion, DEFAULT_ZOOM)

static func get_duration(emotion: Emotion) -> float:
	return DURATION.get(emotion, 0.0)
