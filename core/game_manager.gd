extends Node

@onready var container = $CurrentSceneContainer

# 1. Define your exact progression order here using file paths
var progression_sequence: Array[String] = [
	"res://menu/MainMenu.tscn",
	"res://story/OpeningStory.tscn",
	"res://main_game/MainGame.tscn",
	"res://story/EndingStory.tscn"
]

var current_index: int = 0

func _ready():
	load_scene(current_index)

func load_scene(index: int):
	# Clear out whatever scene is currently in the container
	for child in container.get_children():
		child.queue_free()
		
	# Load the new scene from the array
	var next_scene_resource = load(progression_sequence[index])
	var next_scene_instance = next_scene_resource.instantiate()
	
	# Connect to that universal signal we established earlier!
	next_scene_instance.sequence_finished.connect(_on_sequence_finished)
	
	# Add it to the screen
	container.add_child(next_scene_instance)

func _on_sequence_finished():
	current_index += 1
	if current_index < progression_sequence.size():
		load_scene(current_index)
	else:
		print("Game Over! You beat the progression.")
		# Optional: Reset back to menu
		current_index = 0
		load_scene(current_index)
