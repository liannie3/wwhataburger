extends Control

@onready var ending_image = $EndingImage
@onready var punchline = $Punchline

# Load the specific victory images for each player
var p1_win_image = preload("res://assets/bad_ending_zill.png")
var p2_win_image = preload("res://assets/bad_ending_zerica.png")

func _ready() -> void:
	# 1. Hide the text instantly
	punchline.modulate.a = 0.0 
	
	# 2. Check the Autoload to see who actually triggered the ending!
	if GlobalStats.p1_evidence > GlobalStats.p2_evidence:
		ending_image.texture = p1_win_image
	else:
		ending_image.texture = p2_win_image
		
	# 3. Start the cinematic sequence
	_play_cinematic()

func _play_cinematic() -> void:
	# Wait for 5 seconds with just the tragic image on screen
	await get_tree().create_timer(5.0).timeout
	
	# Fade the text in over 3 seconds (while the image remains!)
	var tween = create_tween()
	tween.tween_property(punchline, "modulate:a", 1.0, 3.0) 
	
	# Wait for the fade animation to fully finish
	await tween.finished
	
	# Let the tragic text sit on the screen for 5 more seconds so they can read it
	await get_tree().create_timer(5.0).timeout
	
	# Optional: Reset stats before going to the menu so the next game starts fresh!
	GlobalStats.reset_stats() 
	
	# Kick them back to the Main Menu
	get_tree().change_scene_to_file("res://menu/MainMenu.tscn")
