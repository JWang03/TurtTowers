extends Node
class_name BuildManager

@export var is_placed: bool = false

signal selection_changed(selected_scene)

var selected_scene: PackedScene = null

func select(scene: PackedScene) -> void:
	selected_scene = scene
	emit_signal("selection_changed", selected_scene)

func clear() -> void:
	selected_scene = null
	emit_signal("selection_changed", selected_scene)

func has_selection() -> bool:
	return selected_scene != null
