extends CharacterBody2D
class_name Player

@export var player_id: int = 1 
@export var base_speed: float = 400.0
@export var dash_speed: float = 900.0

@onready var minimap_dot = $MinimapDot
@onready var anim = $AnimatedSprite2D
@onready var player_ui = $PlayerUI
@onready var camera = $Camera2D

# Variable to hold the player's current emotion
var current_emotion: EmotionData.Emotion = EmotionData.Emotion.NONE

# Camera zoom tween tracker
var _zoom_tween: Tween

# Dash state (JOY double-tap)
var _last_tap_direction: Vector2 = Vector2.ZERO
var _last_tap_time: float = 0.0
var _is_dashing: bool = false
var _dash_timer: float = 0.0
var _dash_direction: Vector2 = Vector2.ZERO
const DASH_DURATION: float = 0.2
const DOUBLE_TAP_WINDOW: float = 0.3

func _ready() -> void:
	# Paint the dot based on the player ID!
	if player_ui:
		player_ui.player_id = player_id
	if player_id == 1:
		minimap_dot.modulate = Color.DARK_GREEN  
	else:
		minimap_dot.modulate = Color.REBECCA_PURPLE
		
	# Connect to the EmotionManager to listen for changes, and grab the starting state
	EmotionManager.emotion_changed.connect(_on_emotion_changed)
	current_emotion = EmotionManager.get_emotion(player_id)
	_apply_camera_zoom(current_emotion)

func _physics_process(delta: float) -> void:
	var prefix = "p" + str(player_id) + "_"
	var up = prefix + "up"
	var down = prefix + "down"
	var left = prefix + "left"
	var right = prefix + "right"

	# 2. Get the raw movement direction
	var direction = Input.get_vector(left, right, up, down)
	
	# EMOTION MODIFIER: Reverse Controls
	if EmotionData.has_reverse_controls(current_emotion):
		direction *= -1

	# EMOTION MODIFIER: Speed
	var speed_mult = EmotionData.get_speed_multiplier(current_emotion)
	var target_velocity = direction * (base_speed * speed_mult)

	# EMOTION MODIFIER: Acceleration (Instant vs Contempt's sliding)
	var accel = EmotionData.get_acceleration(current_emotion)
	if accel > 0.0:
		velocity = velocity.lerp(target_velocity, accel * delta)
	else:
		velocity = target_velocity

	# EMOTION MODIFIER: Dash (JOY double-tap)
	if EmotionData.has_dash(current_emotion):
		_process_dash(delta, up, down, left, right)
	elif _is_dashing:
		_is_dashing = false

	if _is_dashing:
		velocity = _dash_direction * dash_speed

	move_and_slide()
	
	if velocity.length() > 10.0:
		anim.play(prefix + "move")
		if velocity.x != 0:
			anim.flip_h = velocity.x > 0
	else:
		anim.play(prefix + "idle")

func _on_emotion_changed(id: int, emotion: EmotionData.Emotion) -> void:
	if id == player_id:
		current_emotion = emotion
		_apply_camera_zoom(emotion)

func _get_facing_direction() -> Vector2:
	return Vector2.LEFT if anim.flip_h else Vector2.RIGHT

func _apply_camera_zoom(emotion: EmotionData.Emotion) -> void:
	if not camera:
		return
	var target_zoom = EmotionData.get_camera_zoom(emotion)
	if _zoom_tween:
		_zoom_tween.kill()
	_zoom_tween = create_tween()
	_zoom_tween.tween_property(camera, "zoom", target_zoom, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _get_tap_direction(up: String, down: String, left: String, right: String) -> Vector2:
	var tap := Vector2.ZERO
	if Input.is_action_just_pressed(left):
		tap.x -= 1
	if Input.is_action_just_pressed(right):
		tap.x += 1
	if Input.is_action_just_pressed(up):
		tap.y -= 1
	if Input.is_action_just_pressed(down):
		tap.y += 1
	return tap

func _process_dash(delta: float, up: String, down: String, left: String, right: String) -> void:
	if _is_dashing:
		_dash_timer -= delta
		if _dash_timer <= 0.0:
			_is_dashing = false
		return

	var tap = _get_tap_direction(up, down, left, right)
	if tap == Vector2.ZERO:
		return

	var now = Time.get_ticks_msec() / 1000.0
	if tap == _last_tap_direction and (now - _last_tap_time) < DOUBLE_TAP_WINDOW:
		_is_dashing = true
		_dash_timer = DASH_DURATION
		_dash_direction = tap.normalized()
		_last_tap_direction = Vector2.ZERO
		_last_tap_time = 0.0
	else:
		_last_tap_direction = tap
		_last_tap_time = now
