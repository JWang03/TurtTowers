extends TextureButton

@export var tower_scene: PackedScene
@onready var cost_label: Label = $Label
@onready var build_manager = get_node("/root/Game/BuildManager")

func _ready() -> void:
	pressed.connect(_on_pressed)
	var temp = tower_scene.instantiate()
	cost_label.text = str(int(temp.cost)) + " 🦐"
	temp.free()

func _on_pressed() -> void:
	build_manager.select(tower_scene)
	release_focus()
