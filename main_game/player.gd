extends CharacterBody2D

@export var player_id: int = 1 
@export var speed: float = 300.0

@onready var anim = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	# 1. Build the action strings dynamically based on the player_id
	# If player_id is 1, this becomes "p1_up". If it's 2, it becomes "p2_up".
	var prefix = "p" + str(player_id) + "_"
	var up = prefix + "up"
	var down = prefix + "down"
	var left = prefix + "left"
	var right = prefix + "right"

	# 2. Get the movement direction using our dynamically created strings
	var direction = Input.get_vector(left, right, up, down)
	
	# 3. Apply the movement
	velocity = direction * speed
	move_and_slide()
	
	if direction.length() > 0:
		# If moving, play the move animation
		anim.play(prefix + "move")
		if direction.x != 0:
			anim.flip_h = direction.x > 0
	else:
		# If standing still, play idle
		anim.play(prefix + "idle")
