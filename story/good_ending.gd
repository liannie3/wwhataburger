extends Control

# Grab your UI labels
@onready var bubble_bg = $DialogueMargin/BubbleBG
@onready var name_label = $DialogueMargin/BubbleBG/TextPadding/VBoxContainer/NameLabel
@onready var text_label = $DialogueMargin/BubbleBG/TextPadding/VBoxContainer/TextLabel

var bubble_frames = [
	preload("res://assets/bubble_1.png"),
	preload("res://assets/bubble_2.png")
]

# Your custom script! Add as many lines as you want here.
var conversation: Array[Dictionary] = [
	{"name": "Zill", "text": "You know, we used to love each other."},
	{"name": "Zerica", "text": "I know. But I think we loved the version of us that only lived in your head."},
	{"name": "Zill", "text": "That was so long ago. I never saw it... the way we just drifted."},
	{"name": "Zerica", "text": "We didn't drift, Zill. I just finally started walking in a different direction."},
	{"name": "Zill", "text": "In another world, we could still be together."},
	{"name": "Zerica", "text": "Maybe. But in that world, I don't think I’d know who I am."},
	{"name": "Zill", "text": "I’m sorry I made you feel small."},
	{"name": "Zerica", "text": "I’m sorry I let myself stay that way for so long. I’m glad I knew you."},
	{"name": "Zill", "text": "Yeah. I’m glad I knew you, too."},
]

var current_line: int = 0
var bubble_state: String = "open" # Track the state so we can stop it safely

func _ready() -> void:
	# Load the very first line the moment the scene opens
	_show_line(current_line)
	_idle_bubble_loop()

func _input(event: InputEvent) -> void:
	# Listen for a Left Mouse Click or the "ui_accept" action (Spacebar/Enter)
	if event.is_action_pressed("ui_accept") or (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		_advance_dialogue()

func _show_line(index: int) -> void:
	# Update the labels with the current dictionary entry
	name_label.text = conversation[index]["name"]
	text_label.text = conversation[index]["text"]

func _advance_dialogue() -> void:
	current_line += 1
	
	if current_line < conversation.size():
		# Show the next line
		_show_line(current_line)
	else:
		# The conversation is over! Kick them back to the Main Menu.
		print("Cutscene finished!")
		# Make sure this path exactly matches your Main Menu file!
		get_tree().change_scene_to_file("res://menu/MainMenu.tscn")
		
func _idle_bubble_loop():
	var use_frame_six = false
	
	# Keep looping back and forth as long as the scene is active
	while bubble_state == "open":
		if use_frame_six:
			bubble_bg.texture = bubble_frames[0] # Text6.PNG
		else:
			bubble_bg.texture = bubble_frames[1] # Text5.PNG
			
		use_frame_six = not use_frame_six
		
		# The breathing speed (0.15 seconds)
		await get_tree().create_timer(0.45).timeout
