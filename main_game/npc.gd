extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# A simple function to apply state changes
func apply_effect(effect_type: String):
	if effect_type == "test":
		print("testing 1")
	elif effect_type == "test2":
		print("testing 2")

var players_in_range: Array[Player] = []

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		if not players_in_range.has(body):
			players_in_range.append(body)


func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		players_in_range.erase(body)

func _input(event: InputEvent) -> void:
	for player in players_in_range:
		var interact_action = "p" + str(player.player_id) + "_interact"
		if event.is_action_pressed(interact_action):
			print(player.player_id, "interacting right now")
