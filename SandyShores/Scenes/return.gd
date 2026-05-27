extends Button

const MAIN_MENU_SCENE := "res://Menu/main_menu.tscn"
const AUTOSAVE_PATH := "user://tower_scene_autosave.json"
const RESTART_ICON := preload("res://Menu/Images/Icons/restart.png")
const EXIT_ICON := preload("res://Menu/Images/Icons/exit_main_menu.png")
const PANEL_SIZE := Vector2(390, 205)
const MENU_FADE_DURATION := 0.2
const MENU_SCALE_DURATION := 0.3

var _menu_root: Control
var _menu_panel: PanelContainer
var _darkener: ColorRect
var _settings_rect: Control
var _save_loaded := false

func _ready():
	pressed.connect(_on_pressed)
	get_tree().auto_accept_quit = false
	call_deferred("_load_autosave_if_available")

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_autosave_current_run()
		get_tree().quit()

func _on_pressed():
	_show_return_menu()

func _show_return_menu() -> void:
	if _menu_root == null:
		_create_return_menu()

	get_tree().paused = true
	_menu_root.show()
	if _settings_rect:
		_settings_rect.hide()
	_darkener.modulate.a = 0.0
	_menu_panel.pivot_offset = _menu_panel.size / 2
	_menu_panel.scale = Vector2.ZERO
	_menu_panel.show()

	var tween := create_tween().set_parallel(true)
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(_darkener, "modulate:a", 1.0, MENU_FADE_DURATION)
	tween.tween_property(_menu_panel, "scale", Vector2.ONE, MENU_SCALE_DURATION)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _create_return_menu() -> void:
	_menu_root = GlobalSettings.get_node_or_null("MenuPanel") as Control
	if _menu_root:
		_darkener = _menu_root.get_node_or_null("Darkener") as ColorRect
		_settings_rect = _menu_root.get_node_or_null("SettingsMenu") as Control

	if _menu_root == null or _darkener == null:
		_create_fallback_menu_root()

	_menu_root.process_mode = Node.PROCESS_MODE_ALWAYS

	if _darkener:
		_darkener.process_mode = Node.PROCESS_MODE_ALWAYS

	var existing_return_menu := _menu_root.get_node_or_null("ReturnMenu")
	if existing_return_menu:
		existing_return_menu.free()

	_menu_panel = PanelContainer.new()
	_menu_panel.name = "ReturnMenu"
	_menu_panel.custom_minimum_size = PANEL_SIZE
	_menu_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	_menu_panel.set_anchors_preset(Control.PRESET_CENTER)
	_menu_panel.offset_left = -PANEL_SIZE.x / 2.0
	_menu_panel.offset_top = -PANEL_SIZE.y / 2.0
	_menu_panel.offset_right = PANEL_SIZE.x / 2.0
	_menu_panel.offset_bottom = PANEL_SIZE.y / 2.0
	_menu_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_menu_panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	_menu_root.add_child(_menu_panel)

	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.18, 0.52, 0.53, 0.96)
	panel_style.border_color = Color(0.99, 0.82, 0.32)
	panel_style.border_width_left = 5
	panel_style.border_width_top = 5
	panel_style.border_width_right = 5
	panel_style.border_width_bottom = 5
	panel_style.corner_radius_top_left = 8
	panel_style.corner_radius_top_right = 8
	panel_style.corner_radius_bottom_left = 8
	panel_style.corner_radius_bottom_right = 8
	panel_style.shadow_color = Color(0.02, 0.08, 0.09, 0.55)
	panel_style.shadow_size = 12
	panel_style.content_margin_left = 28
	panel_style.content_margin_top = 22
	panel_style.content_margin_right = 28
	panel_style.content_margin_bottom = 28
	_menu_panel.add_theme_stylebox_override("panel", panel_style)

	var options := VBoxContainer.new()
	options.name = "Options"
	options.alignment = BoxContainer.ALIGNMENT_CENTER
	options.add_theme_constant_override("separation", 12)
	_menu_panel.add_child(options)

	var header := HBoxContainer.new()
	header.name = "Header"
	header.add_theme_constant_override("separation", 12)
	options.add_child(header)

	var title := Label.new()
	title.text = "Leave this run?"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", Color(1.0, 0.96, 0.72))
	title.add_theme_constant_override("outline_size", 7)
	title.add_theme_color_override("font_outline_color", Color(0.04, 0.19, 0.2))
	title.add_theme_font_size_override("font_size", 26)
	header.add_child(title)

	var close_button := _create_close_button()
	close_button.pressed.connect(_on_return_to_game_pressed)
	header.add_child(close_button)

	var exit_button := _create_menu_button("Exit to Main Menu", EXIT_ICON)
	exit_button.pressed.connect(_on_exit_to_main_menu_pressed)
	options.add_child(exit_button)

	var restart_button := _create_menu_button("Restart", RESTART_ICON)
	restart_button.pressed.connect(_on_restart_pressed)
	options.add_child(restart_button)

	_menu_panel.hide()

func _create_fallback_menu_root() -> void:
	var menu_layer := CanvasLayer.new()
	menu_layer.name = "ReturnMenuLayer"
	menu_layer.layer = 4096
	menu_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().current_scene.add_child(menu_layer)

	_menu_root = Control.new()
	_menu_root.name = "MenuPanel"
	_menu_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_menu_root.process_mode = Node.PROCESS_MODE_ALWAYS
	menu_layer.add_child(_menu_root)

	_darkener = ColorRect.new()
	_darkener.name = "Darkener"
	_darkener.color = Color(0, 0, 0, 0.588)
	_darkener.set_anchors_preset(Control.PRESET_FULL_RECT)
	_menu_root.add_child(_darkener)

func _create_close_button() -> Button:
	var button := Button.new()
	button.text = "X"
	button.tooltip_text = "Return to game"
	button.custom_minimum_size = Vector2(48, 42)
	button.process_mode = Node.PROCESS_MODE_ALWAYS
	button.add_theme_font_size_override("font_size", 24)
	button.add_theme_color_override("font_color", Color(0.04, 0.19, 0.2))
	button.add_theme_stylebox_override("normal", _make_button_style(Color(0.99, 0.82, 0.32)))
	button.add_theme_stylebox_override("hover", _make_button_style(Color(1.0, 0.91, 0.47)))
	button.add_theme_stylebox_override("pressed", _make_button_style(Color(0.84, 0.6, 0.18)))
	return button

func _create_menu_button(label: String, icon_texture: Texture2D = null) -> Button:
	var button := Button.new()
	button.text = label
	button.custom_minimum_size = Vector2(300, 44)
	button.process_mode = Node.PROCESS_MODE_ALWAYS
	if icon_texture:
		button.icon = icon_texture
		button.expand_icon = true
		button.icon_alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.add_theme_constant_override("icon_max_width", 30)
	button.add_theme_font_size_override("font_size", 20)
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

func _on_return_to_game_pressed() -> void:
	_hide_return_menu()

func _on_exit_to_main_menu_pressed() -> void:
	_autosave_current_run()
	_prepare_for_scene_change()
	get_tree().paused = false
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)

func _on_restart_pressed() -> void:
	if FileAccess.file_exists(AUTOSAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(AUTOSAVE_PATH))
	_prepare_for_scene_change()
	get_tree().paused = false
	get_tree().reload_current_scene()
	UpgradeManager.clear_all()

func _prepare_for_scene_change() -> void:
	if _menu_panel:
		_menu_panel.queue_free()
	if _settings_rect:
		_settings_rect.show()
	if _darkener:
		_darkener.modulate.a = 0.0
	if _menu_root:
		_menu_root.hide()

func _hide_return_menu() -> void:
	if _menu_root == null:
		get_tree().paused = false
		return

	var tween := create_tween().set_parallel(true)
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(_darkener, "modulate:a", 0.0, MENU_FADE_DURATION)
	tween.tween_property(_menu_panel, "scale", Vector2.ZERO, MENU_FADE_DURATION)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.chain().tween_callback(_finish_hiding_return_menu)

func _finish_hiding_return_menu() -> void:
	_menu_panel.hide()
	if _settings_rect:
		_settings_rect.show()
	_menu_root.hide()
	get_tree().paused = false

func _autosave_current_run() -> void:
	var current_scene := get_tree().current_scene
	if current_scene == null:
		return

	var save_data := {
		"scene": current_scene.scene_file_path,
		"saved_at_unix": Time.get_unix_time_from_system()
	}

	var wave_spawner := current_scene.find_child("WaveSpawner", true, false)
	if wave_spawner:
		save_data["current_wave"] = wave_spawner.get("current_wave")
		save_data["game_started"] = wave_spawner.get("game_started")
		save_data["wave_running"] = wave_spawner.get("wave_running")
		save_data["game_finished"] = wave_spawner.get("game_finished")
		save_data["enemies_alive"] = wave_spawner.get("enemies_alive")

	var currency_manager := current_scene.find_child("CurrencyManager", true, false)
	if currency_manager:
		save_data["shellings"] = currency_manager.get("shellings")

	var loss_conditions := current_scene.find_child("LossConditions", true, false)
	if loss_conditions:
		save_data["lives"] = loss_conditions.get("lives")

	var play_button := current_scene.find_child("PlayButton", true, false)
	if play_button:
		save_data["play_button_playing"] = play_button.get("playing")

	save_data["towers"] = _get_tower_save_data(current_scene)
	save_data["active_enemies"] = _get_active_enemy_save_data()

	var autosave_file := FileAccess.open(AUTOSAVE_PATH, FileAccess.WRITE)
	if autosave_file == null:
		push_warning("Could not write autosave to %s." % AUTOSAVE_PATH)
		return

	autosave_file.store_string(JSON.stringify(save_data, "\t"))

func _get_tower_save_data(current_scene: Node) -> Array:
	var tower_data := []
	var tower_container := current_scene.find_child("TowerContainer", true, false)
	if tower_container == null:
		return tower_data

	for tower in tower_container.get_children():
		if not tower.get("is_placed"):
			continue

		var scene_path := tower.scene_file_path
		if scene_path == "":
			continue

		var occupied_cell: Vector2i = tower.get("occupied_cell")
		tower_data.append({
			"scene": scene_path,
			"position": {"x": tower.position.x, "y": tower.position.y},
			"occupied_cell": {"x": occupied_cell.x, "y": occupied_cell.y},
			"target_priority": tower.get("target_priority"),
			"left_level": tower.get("left_level") if "left_level" in tower else 0,
			"right_level": tower.get("right_level") if "right_level" in tower else 0,
			"chosen_branch": tower.get("chosen_branch") if "chosen_branch" in tower else ""
		})

	return tower_data

func _get_active_enemy_save_data() -> Array:
	var enemy_data := []
	for enemy in get_tree().get_nodes_in_group("zombies"):
		if not is_instance_valid(enemy):
			continue

		var follow := enemy.get_parent()
		if not (follow is PathFollow2D):
			continue

		var scene_path := enemy.scene_file_path
		if scene_path == "":
			continue

		enemy_data.append({
			"scene": scene_path,
			"progress": follow.progress,
			"health": enemy.get("health"),
			"max_health": enemy.get("max_health"),
			"speed": enemy.get("speed"),
			"speed_modifier": enemy.get("speed_modifier"),
			"scale": {"x": enemy.scale.x, "y": enemy.scale.y}
		})

	return enemy_data

func _load_autosave_if_available() -> void:
	if _save_loaded or not FileAccess.file_exists(AUTOSAVE_PATH):
		return

	var autosave_file := FileAccess.open(AUTOSAVE_PATH, FileAccess.READ)
	if autosave_file == null:
		return

	var parsed = JSON.parse_string(autosave_file.get_as_text())
	if not (parsed is Dictionary):
		return

	var current_scene := get_tree().current_scene
	if current_scene == null or parsed.get("scene", "") != current_scene.scene_file_path:
		return

	_save_loaded = true
	await get_tree().process_frame
	_restore_autosave(parsed)

func _restore_autosave(save_data: Dictionary) -> void:
	var current_scene := get_tree().current_scene
	if current_scene == null:
		return

	var currency_manager := current_scene.find_child("CurrencyManager", true, false)
	if currency_manager and save_data.has("shellings"):
		currency_manager.set("shellings", int(save_data["shellings"]))
		if currency_manager.has_method("update_label"):
			currency_manager.update_label()

	var loss_conditions := current_scene.find_child("LossConditions", true, false)
	if loss_conditions and save_data.has("lives"):
		loss_conditions.set("lives", int(save_data["lives"]))
		if loss_conditions.has_method("update_label"):
			loss_conditions.update_label()

	_restore_towers(current_scene, save_data.get("towers", []))

	var wave_spawner := current_scene.find_child("WaveSpawner", true, false)
	if wave_spawner:
		var saved_wave: int = max(0, int(save_data.get("current_wave", 0)))
		if not save_data.has("wave_running"):
			saved_wave = max(0, saved_wave - 1)
		var wave_was_running := bool(save_data.get("wave_running", false))
		wave_spawner.set("current_wave", saved_wave)
		wave_spawner.set("game_started", wave_was_running)
		wave_spawner.set("wave_running", wave_was_running)
		wave_spawner.set("game_finished", bool(save_data.get("game_finished", false)))
		var wave_label = wave_spawner.get("wave_label")
		if wave_label:
			var display_wave := saved_wave if wave_was_running else saved_wave + 1
			wave_label.text = "Wave " + str(max(1, display_wave)) + " / " + str(wave_spawner.get("max_waves"))
		_restore_active_enemies(current_scene, wave_spawner, save_data.get("active_enemies", []))
		if wave_was_running and wave_spawner.has_method("resume_restored_wave"):
			wave_spawner.call_deferred("resume_restored_wave")

	var play_button := current_scene.find_child("PlayButton", true, false)
	if play_button:
		play_button.set("playing", bool(save_data.get("play_button_playing", save_data.get("wave_running", false))))
		if play_button.has_method("_update_icons"):
			play_button._update_icons()

func _restore_towers(current_scene: Node, tower_data: Array) -> void:
	var tower_container := current_scene.find_child("TowerContainer", true, false)
	var grid := current_scene.find_child("Grid", true, false)
	if tower_container == null:
		return

	for child in tower_container.get_children():
		if child.get("is_placed"):
			child.queue_free()

	if grid:
		grid.set("occupied_cells", {})

	for data in tower_data:
		if not (data is Dictionary) or not data.has("scene"):
			continue

		var tower_scene := load(str(data["scene"])) as PackedScene
		if tower_scene == null:
			continue

		var tower := tower_scene.instantiate()
		tower_container.add_child(tower)

		var pos: Variant = data.get("position", {})
		if pos is Dictionary:
			tower.position = Vector2(float(pos.get("x", 0.0)), float(pos.get("y", 0.0)))

		var cell_data: Variant = data.get("occupied_cell", {})
		var occupied_cell := Vector2i.ZERO
		if cell_data is Dictionary:
			occupied_cell = Vector2i(int(cell_data.get("x", 0)), int(cell_data.get("y", 0)))

		tower.set("occupied_cell", occupied_cell)
		tower.set("tilemap", grid)
		tower.set("is_placed", true)

		if data.has("target_priority"):
			tower.set("target_priority", int(data["target_priority"]))

		_restore_tower_upgrades(tower, data)

		if grid:
			var occupied_cells: Dictionary = grid.get("occupied_cells")
			occupied_cells[occupied_cell] = true
			grid.set("occupied_cells", occupied_cells)

		if tower.has_method("_on_placed"):
			tower.call_deferred("_on_placed")
		if tower.has_method("on_placed"):
			tower.on_placed()

func _restore_tower_upgrades(tower: Node, data: Dictionary) -> void:
	var left_level: int = int(data.get("left_level", 0))
	var right_level: int = int(data.get("right_level", 0))

	if tower.has_method("apply_left_upgrade"):
		for i in range(left_level):
			tower.set("left_level", i)
			tower.apply_left_upgrade()
	if tower.has_method("apply_right_upgrade"):
		for i in range(right_level):
			tower.set("right_level", i)
			tower.apply_right_upgrade()

	if "left_level" in tower:
		tower.set("left_level", left_level)
	if "right_level" in tower:
		tower.set("right_level", right_level)
	if "chosen_branch" in tower:
		tower.set("chosen_branch", str(data.get("chosen_branch", "")))

func _restore_active_enemies(current_scene: Node, wave_spawner: Node, enemy_data: Array) -> void:
	var enemy_path := current_scene.find_child("EnemyPath", true, false) as Path2D
	if enemy_path == null:
		return

	var restored_count := 0
	for data in enemy_data:
		if not (data is Dictionary) or not data.has("scene"):
			continue

		var enemy_scene := load(str(data["scene"])) as PackedScene
		if enemy_scene == null:
			continue

		var follow := PathFollow2D.new()
		follow.rotates = false
		follow.loop = false
		follow.progress = float(data.get("progress", 0.0))
		enemy_path.add_child(follow)

		var enemy := enemy_scene.instantiate()
		follow.add_child(enemy)
		enemy.set("wave_manager", wave_spawner)

		if data.has("max_health") and enemy.get("max_health") != null:
			enemy.set("max_health", float(data["max_health"]))
		if data.has("health") and enemy.get("health") != null:
			enemy.set("health", float(data["health"]))
			var health_bar = enemy.get("health_bar")
			if health_bar and health_bar.has_method("update"):
				health_bar.update(enemy.get("health"), enemy.get("max_health"))
		if data.has("speed") and enemy.get("speed") != null:
			enemy.set("speed", float(data["speed"]))
		if data.has("speed_modifier") and enemy.get("speed_modifier") != null:
			enemy.set("speed_modifier", float(data["speed_modifier"]))
		var scale_data: Variant = data.get("scale", {})
		if scale_data is Dictionary:
			enemy.scale = Vector2(float(scale_data.get("x", 1.0)), float(scale_data.get("y", 1.0)))

		restored_count += 1

	wave_spawner.set("enemies_alive", restored_count)
