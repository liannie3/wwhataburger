extends Node

@onready var container = $CurrentSceneContainer

# 1. Define your exact progression order here using file paths
var progression_sequence: Array[String] = [
	"res://menu/MainMenu.tscn",
	"res://story/OpeningStory.tscn",
	"res://main_game/SplitScreen.tscn",
]

var current_index: int = 0

func _ready():
	GlobalStats.game_over.connect(_on_game_over)
	load_scene(current_index)

func load_scene(index: int):
	# Clear out whatever scene is currently in the container
	for child in container.get_children():
		child.queue_free()
		
	# Load the new scene from the array
	var next_scene_resource = load(progression_sequence[index])
	var next_scene_instance = next_scene_resource.instantiate()
	
	if next_scene_instance.has_signal("sequence_finished"):
	# Connect to that universal signal we established earlier!
		next_scene_instance.sequence_finished.connect(_on_sequence_finished)
	
	# Add it to the screen
	container.add_child(next_scene_instance)

func load_scene_from_path(scene_path: String):
	for child in container.get_children():
		child.queue_free()
		
	var scene_resource = load(scene_path)
	var scene_instance = scene_resource.instantiate()
	container.add_child(scene_instance)

func _on_sequence_finished():
	current_index += 1
	if current_index < progression_sequence.size():
		load_scene(current_index)

func _on_game_over(ending_type: GlobalStats.Ending):
	print("Game Over Triggered! Ending Type: ", ending_type)
	
	if ending_type == GlobalStats.Ending.GOOD:
		load_scene_from_path("res://story/GoodEnding.tscn") # Update this path!
	elif ending_type == GlobalStats.Ending.BAD:
		load_scene_from_path("res://story/BadEnding.tscn") # Update this path!
