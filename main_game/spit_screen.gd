extends Control

@onready var viewport1 = $HBoxContainer/SubViewportContainer/SubViewport
@onready var viewport2 = $HBoxContainer/SubViewportContainer2/SubViewport2
@onready var minimap_viewport = $CanvasLayer/CenterContainer/SubViewportContainer/SubViewport

func _ready():
	# 1. Force the right screen to exist in the exact same physical world as the left screen
	viewport2.world_2d = viewport1.world_2d
	minimap_viewport.world_2d = viewport1.world_2d
	
	# 2. Grab Player 2's camera from the left screen's game instance
	var p2_cam = viewport1.get_node("MainGame/Player2/Camera2D")
	
	# 3. Tell Player 2's camera to project onto the right screen!
	p2_cam.custom_viewport = viewport2
	
	# 4. THE FIX: Force the right screen to actively look through this camera!
	p2_cam.make_current()
