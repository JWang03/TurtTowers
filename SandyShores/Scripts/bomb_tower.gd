extends TextureButton

@export var cost: int = 5
@export var is_placed: bool = false


@export var tower_scene: PackedScene
@onready var build_manager = get_node("/root/Game/BuildManager")

func _ready() -> void:
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	build_manager.select(tower_scene)
	release_focus()
