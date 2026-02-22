extends Control

signal tutorial_finished

@onready var viewport1 = $HBoxContainer/SubViewportContainer/SubViewport
@onready var viewport2 = $HBoxContainer/SubViewportContainer2/SubViewport2

func _ready():
	viewport2.world_2d = viewport1.world_2d

	var p2_cam = viewport1.get_node("TutorialWorld/Player2/Camera2D")
	p2_cam.custom_viewport = viewport2
	p2_cam.make_current()

	var p2_canvas = viewport1.get_node("TutorialWorld/Player2/PlayerUI")
	p2_canvas.custom_viewport = viewport2

	var tutorial_world = viewport1.get_node("TutorialWorld")
	tutorial_world.tutorial_complete.connect(_on_tutorial_complete)

func _on_tutorial_complete():
	tutorial_finished.emit()
