extends TextureButton

@export var tower_scene: PackedScene
@onready var build_manager = get_node("/root/Game/BuildManager")

func _ready() -> void:
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	build_manager.select(tower_scene)
	release_focus()
	print("tower selected: ", name)
