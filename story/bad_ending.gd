extends Control

@onready var ending_image = $EndingImage
@onready var punchline = $Punchline
@onready var replay_button = $ReplayButton

# Load the specific victory images for each player
var p1_win_image = preload("res://assets/bad_ending_zerica.png")
var p2_win_image = preload("res://assets/bad_ending_zill.png")

func _ready() -> void:
	# 1. Hide the text and button instantly
	punchline.modulate.a = 0.0
	replay_button.modulate.a = 0.0
	replay_button.pressed.connect(_on_replay_pressed)
	
	# 2. Check the Autoload to see who actually triggered the ending!
	if GlobalStats.p1_evidence > GlobalStats.p2_evidence:
		ending_image.texture = p1_win_image
	else:
		ending_image.texture = p2_win_image
		
	# 3. Start the cinematic sequence
	_play_cinematic()

func _play_cinematic() -> void:
	# Wait for 5 seconds with just the tragic image on screen
	await get_tree().create_timer(2).timeout
	
	# Fade the text in over 3 seconds (while the image remains!)
	var tween = create_tween()
	tween.tween_property(punchline, "modulate:a", 1.0, 1) 
	
	# Wait for the fade animation to fully finish
	await tween.finished
	
	# Fade in the replay button
	await get_tree().create_timer(2.0).timeout
	var button_tween = create_tween()
	button_tween.tween_property(replay_button, "modulate:a", 1.0, 1)

func _on_replay_pressed() -> void:
	GlobalStats.reset()
	var game_manager = get_tree().root.get_child(get_tree().root.get_child_count() - 1)
	if game_manager.has_method("load_scene_from_path"):
		game_manager.load_scene_from_path("res://main_game/SpitScreen.tscn")
	else:
		get_tree().change_scene_to_file("res://main_game/SpitScreen.tscn")
