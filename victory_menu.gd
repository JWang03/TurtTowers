extends Node

const MAIN_MENU_SCENE := "res://Menu/main_menu.tscn"
const MAP_CLEAR_PATH := "user://map_clear_data.json"
const AUTOSAVE_PATH := "user://tower_scene_autosave.json"
const PANEL_SIZE := Vector2(400, 390)
const MENU_FADE_DURATION := 0.2
const MENU_SCALE_DURATION := 0.35

var _menu_layer: CanvasLayer
var _menu_root: Control
var _menu_panel: PanelContainer
var _darkener: ColorRect

func show_victory(scene_path: String, stats: Dictionary) -> void:
	_mark_map_cleared(scene_path)
	_clear_autosave()
	_create_menu_if_needed()
	_populate_report(scene_path, stats)

	get_tree().paused = true
	_menu_root.show()
	_darkener.modulate.a = 0.0
	_menu_panel.pivot_offset = _menu_panel.size / 2
	_menu_panel.scale = Vector2.ZERO
	_menu_panel.show()

	var tween := create_tween().set_parallel(true)
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(_darkener, "modulate:a", 1.0, MENU_FADE_DURATION)
	tween.tween_property(_menu_panel, "scale", Vector2.ONE, MENU_SCALE_DURATION)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _create_menu_if_needed() -> void:
	if _menu_root != null and is_instance_valid(_menu_root):
		return

	_menu_layer = CanvasLayer.new()
	_menu_layer.name = "VictoryMenuLayer"
	_menu_layer.layer = 5000
	_menu_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().current_scene.add_child(_menu_layer)

	_menu_root = Control.new()
	_menu_root.name = "VictoryMenuRoot"
	_menu_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_menu_root.process_mode = Node.PROCESS_MODE_ALWAYS
	_menu_layer.add_child(_menu_root)

	_darkener = ColorRect.new()
	_darkener.name = "Darkener"
	_darkener.color = Color(0.0, 0.0, 0.0, 0.64)
	_darkener.set_anchors_preset(Control.PRESET_FULL_RECT)
	_darkener.process_mode = Node.PROCESS_MODE_ALWAYS
	_menu_root.add_child(_darkener)

	_menu_panel = PanelContainer.new()
	_menu_panel.name = "VictoryReport"
	_menu_panel.custom_minimum_size = PANEL_SIZE
	_menu_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	_menu_panel.set_anchors_preset(Control.PRESET_CENTER)
	_menu_panel.offset_left = -PANEL_SIZE.x / 2.0
	_menu_panel.offset_top = -PANEL_SIZE.y / 2.0
	_menu_panel.offset_right = PANEL_SIZE.x / 2.0
	_menu_panel.offset_bottom = PANEL_SIZE.y / 2.0
	_menu_root.add_child(_menu_panel)

	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.16, 0.48, 0.5, 0.97)
	panel_style.border_color = Color(1.0, 0.82, 0.22)
	panel_style.border_width_left = 6
	panel_style.border_width_top = 6
	panel_style.border_width_right = 6
	panel_style.border_width_bottom = 6
	panel_style.corner_radius_top_left = 8
	panel_style.corner_radius_top_right = 8
	panel_style.corner_radius_bottom_left = 8
	panel_style.corner_radius_bottom_right = 8
	panel_style.shadow_color = Color(0.02, 0.07, 0.08, 0.62)
	panel_style.shadow_size = 16
	panel_style.content_margin_left = 24
	panel_style.content_margin_top = 18
	panel_style.content_margin_right = 24
	panel_style.content_margin_bottom = 20
	_menu_panel.add_theme_stylebox_override("panel", panel_style)

	_menu_panel.hide()
	_menu_root.hide()

func _populate_report(scene_path: String, stats: Dictionary) -> void:
	for child in _menu_panel.get_children():
		child.queue_free()

	var content := VBoxContainer.new()
	content.name = "Content"
	content.alignment = BoxContainer.ALIGNMENT_CENTER
	content.add_theme_constant_override("separation", 8)
	_menu_panel.add_child(content)

	var title := Label.new()
	title.text = "VICTORY"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", Color(1.0, 0.94, 0.28))
	title.add_theme_constant_override("outline_size", 7)
	title.add_theme_color_override("font_outline_color", Color(0.34, 0.08, 0.02))
	title.add_theme_font_size_override("font_size", 38)
	content.add_child(title)

	var subtitle := Label.new()
	subtitle.text = _get_map_name(scene_path) + " Cleared"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_color_override("font_color", Color(1.0, 0.98, 0.82))
	subtitle.add_theme_constant_override("outline_size", 4)
	subtitle.add_theme_color_override("font_outline_color", Color(0.04, 0.18, 0.19))
	subtitle.add_theme_font_size_override("font_size", 20)
	content.add_child(subtitle)

	var divider := ColorRect.new()
	divider.color = Color(1.0, 0.82, 0.22, 0.95)
	divider.custom_minimum_size = Vector2(0, 4)
	content.add_child(divider)

	var rows := VBoxContainer.new()
	rows.add_theme_constant_override("separation", 5)
	content.add_child(rows)

	_add_stat_row(rows, "Towers Placed", str(stats.get("towers_placed", 0)))
	_add_stat_row(rows, "Cash Generated", str(stats.get("cash_generated", 0)))
	_add_stat_row(rows, "Turtory Bombs Used", str(stats.get("turtory_bombs_used", 0)))
	_add_stat_row(rows, "Lives Lost", str(stats.get("lives_lost", 0)))
	_add_stat_row(rows, "Runtime", _format_runtime(int(stats.get("runtime_seconds", 0))))

	var footer := Label.new()
	footer.text = "MAP CLEARED"
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	footer.add_theme_color_override("font_color", Color(0.08, 0.31, 0.19))
	footer.add_theme_color_override("font_outline_color", Color(0.82, 1.0, 0.55))
	footer.add_theme_constant_override("outline_size", 3)
	footer.add_theme_font_size_override("font_size", 20)
	content.add_child(footer)

	var buttons := HBoxContainer.new()
	buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	buttons.add_theme_constant_override("separation", 12)
	content.add_child(buttons)

	var replay_button := _create_menu_button("Replay")
	replay_button.pressed.connect(_on_replay_pressed)
	buttons.add_child(replay_button)

	var menu_button := _create_menu_button("Return")
	menu_button.pressed.connect(_on_map_select_pressed)
	buttons.add_child(menu_button)

func _add_stat_row(parent: VBoxContainer, label_text: String, value_text: String) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	parent.add_child(row)

	var label := Label.new()
	label.text = label_text
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.add_theme_color_override("font_color", Color(1.0, 0.96, 0.77))
	label.add_theme_font_size_override("font_size", 20)
	row.add_child(label)

	var value := Label.new()
	value.text = value_text
	value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	value.custom_minimum_size = Vector2(120, 0)
	value.add_theme_color_override("font_color", Color(0.8, 1.0, 0.42))
	value.add_theme_constant_override("outline_size", 4)
	value.add_theme_color_override("font_outline_color", Color(0.03, 0.15, 0.13))
	value.add_theme_font_size_override("font_size", 20)
	row.add_child(value)

func _create_menu_button(label_text: String) -> Button:
	var button := Button.new()
	button.text = label_text
	button.custom_minimum_size = Vector2(130, 40)
	button.process_mode = Node.PROCESS_MODE_ALWAYS
	button.add_theme_font_size_override("font_size", 18)
	button.add_theme_color_override("font_color", Color(0.04, 0.19, 0.2))
	button.add_theme_stylebox_override("normal", _make_button_style(Color(0.99, 0.82, 0.32)))
	button.add_theme_stylebox_override("hover", _make_button_style(Color(1.0, 0.91, 0.47)))
	button.add_theme_stylebox_override("pressed", _make_button_style(Color(0.84, 0.6, 0.18)))
	return button

func _make_button_style(bg_color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = Color(0.06, 0.24, 0.26)
	style.border_width_left = 3
	style.border_width_top = 3
	style.border_width_right = 3
	style.border_width_bottom = 3
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.content_margin_left = 12
	style.content_margin_top = 8
	style.content_margin_right = 12
	style.content_margin_bottom = 8
	return style

func _on_replay_pressed() -> void:
	get_tree().paused = false
	_clear_upgrades()
	get_tree().reload_current_scene()

func _on_map_select_pressed() -> void:
	get_tree().paused = false
	_clear_upgrades()
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)

func _clear_upgrades() -> void:
	var upgrade_manager := get_node_or_null("/root/UpgradeManager")
	if upgrade_manager and upgrade_manager.has_method("clear_all"):
		upgrade_manager.clear_all()

func _mark_map_cleared(scene_path: String) -> void:
	var data := _load_clear_data()
	var cleared_maps := {}
	if data.get("cleared_maps", {}) is Dictionary:
		cleared_maps = data.get("cleared_maps", {})
	cleared_maps[scene_path] = true
	data["cleared_maps"] = cleared_maps

	var save_file := FileAccess.open(MAP_CLEAR_PATH, FileAccess.WRITE)
	if save_file == null:
		push_warning("Could not write map clear data to %s." % MAP_CLEAR_PATH)
		return
	save_file.store_string(JSON.stringify(data, "\t"))

func _load_clear_data() -> Dictionary:
	if not FileAccess.file_exists(MAP_CLEAR_PATH):
		return {"cleared_maps": {}}

	var save_file := FileAccess.open(MAP_CLEAR_PATH, FileAccess.READ)
	if save_file == null:
		return {"cleared_maps": {}}

	var parsed = JSON.parse_string(save_file.get_as_text())
	if parsed is Dictionary:
		return parsed
	return {"cleared_maps": {}}

func _clear_autosave() -> void:
	if FileAccess.file_exists(AUTOSAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(AUTOSAVE_PATH))

func _format_runtime(seconds: int) -> String:
	var minutes := seconds / 60
	var remaining_seconds := seconds % 60
	return "%02d:%02d" % [minutes, remaining_seconds]

func _get_map_name(scene_path: String) -> String:
	match scene_path:
		"res://SandyShores/Scenes/Sandy_Beach.tscn":
			return "Sandy Shores"
		"res://SandyShores/Scenes/Abstract.tscn":
			return "Abstract"
		"res://SandyShores/Scenes/Checkers.tscn":
			return "Checkers"
		"res://SandyShores/Scenes/Turtle_Temple.tscn":
			return "Temple"
		_:
			return "Map"
