extends CharacterBody2D
class_name Player

@export var player_id: int = 1 
@export var base_speed: float = 300.0
@export var dash_speed: float = 800.0

@onready var minimap_dot = $MinimapDot
@onready var anim = $AnimatedSprite2D
@onready var player_ui = $PlayerUI

# Variable to hold the player's current emotion
var current_emotion: EmotionData.Emotion = EmotionData.Emotion.NONE

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

func _physics_process(delta: float) -> void:
	var prefix = "p" + str(player_id) + "_"
	var up = prefix + "up"
	var down = prefix + "down"
	var left = prefix + "left"
	var right = prefix + "right"
	var dash = prefix + "dash" # Will need keys

	# 2. Get the raw movement direction
	var direction = Input.get_vector(left, right, up, down)
	
	# EMOTION MODIFIER: Reverse Controls
	if current_emotion == EmotionData.Emotion.REVERSE_CONTROLS:
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
		
	# EMOTION MODIFIER: Dash (Fear)
	#if Input.is_action_just_pressed(dash) and EmotionData.has_dash(current_emotion):
	#	var dash_dir = direction if direction != Vector2.ZERO else _get_facing_direction()
	#	velocity = dash_dir * dash_speed

	move_and_slide()
	
	if velocity.length() > 10.0:
		anim.play(prefix + "move")
		if velocity.x != 0:
			anim.flip_h = velocity.x < 0
	else:
		anim.play(prefix + "idle")

func _on_emotion_changed(id: int, emotion: EmotionData.Emotion) -> void:
	if id == player_id:
		current_emotion = emotion
		print(current_emotion)
		# this is where you would apply the ZOOM_IN / ZOOM_OUT logic.

func _get_facing_direction() -> Vector2:
	return Vector2.LEFT if anim.flip_h else Vector2.RIGHT
		
