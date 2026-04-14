extends Control

@export var tower_scene: PackedScene

@onready var button = $PlaceTowerButton
@onready var build_manager = get_node("/root/Game/BuildManager")

func _ready():
	button.pressed.connect(_on_place_tower_button_pressed)

func _on_place_tower_button_pressed():
	build_manager.select(tower_scene)
	button.release_focus()
