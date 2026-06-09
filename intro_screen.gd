extends Node

const PANEL_SIZE := Vector2(480, 320)
const MENU_FADE_DURATION := 0.2
const MENU_SCALE_DURATION := 0.35

var _menu_layer: CanvasLayer
var _menu_root: Control
var _menu_panel: PanelContainer
var _darkener: ColorRect
var _starter = null
var _info_button_spawned: bool = false

func show_intro() -> void:
	_starter = get_node_or_null("/root/Game/UI/Buttons/PlayButton")
	# CHANGED: Use a safe method call if it exists instead of forcing the property directly
	if _starter and _starter.has_method("set_playing"):
		_starter.set_playing(false)
		
	_build_everything()
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

func spawn_info_button_only() -> void:
	_starter = get_node_or_null("/root/Game/UI/Buttons/PlayButton")
	_build_everything()
	_menu_root.hide()
	_darkener.modulate.a = 0.0
	_menu_panel.hide()
	_spawn_info_button()

func _build_everything() -> void:
	if _menu_layer:
		return

	_menu_layer = CanvasLayer.new()
	_menu_layer.name = "IntroMenuLayer"
	_menu_layer.layer = 5000
	_menu_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().current_scene.add_child(_menu_layer)

	_menu_root = Control.new()
	_menu_root.name = "IntroMenuRoot"
	_menu_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_menu_root.process_mode = Node.PROCESS_MODE_ALWAYS
	_menu_layer.add_child(_menu_root)

	_darkener = ColorRect.new()
	_darkener.name = "Darkener"
	_darkener.color = Color(0.0, 0.0, 0.0, 0.64)
	_darkener.set_anchors_preset(Control.PRESET_FULL_RECT)
	_darkener.process_mode = Node.PROCESS_MODE_ALWAYS
	_darkener.modulate.a = 0.0
	_menu_root.add_child(_darkener)

	_menu_panel = PanelContainer.new()
	_menu_panel.name = "IntroPanel"
	_menu_panel.custom_minimum_size = Vector2(480, 0)
	_menu_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	_menu_panel.set_anchors_preset(Control.PRESET_CENTER)
	_menu_panel.offset_left = -240.0
	_menu_panel.offset_top = -200.0
	_menu_panel.offset_right = 240.0
	_menu_panel.offset_bottom = 200.0
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
	panel_style.content_margin_left = 30
	panel_style.content_margin_top = 24
	panel_style.content_margin_right = 30
	panel_style.content_margin_bottom = 24
	_menu_panel.add_theme_stylebox_override("panel", panel_style)

	var content := VBoxContainer.new()
	content.name = "Content"
	content.alignment = BoxContainer.ALIGNMENT_CENTER
	content.add_theme_constant_override("separation", 14)
	_menu_panel.add_child(content)

	var title := Label.new()
	title.text = "THE MOTHERSHELL CALLS"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", Color(1.0, 0.94, 0.28))
	title.add_theme_constant_override("outline_size", 7)
	title.add_theme_color_override("font_outline_color", Color(0.04, 0.18, 0.19))
	title.add_theme_font_size_override("font_size", 28)
	content.add_child(title)

	var divider := ColorRect.new()
	divider.color = Color(1.0, 0.82, 0.22, 0.95)
	divider.custom_minimum_size = Vector2(0, 3)
	content.add_child(divider)

	var lore := Label.new()
	lore.text = "The Mothershell has cracked.\n\nCenturies of pollution have finally taken their toll — plastic, oil, and toxic waste now surge from the depths, marching toward the sacred shores where the Mothershell rests.\n\nThe Turts have answered the call. Summoned from their home within the Mothershell itself, they stand as the last line of defense between the pollutants and total destruction.\n\nDeploy your Turts wisely. Hold the beach. Protect the Mothershell."
	lore.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lore.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lore.add_theme_color_override("font_color", Color(1.0, 0.97, 0.82))
	lore.add_theme_font_size_override("font_size", 15)
	lore.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_child(lore)

	var divider2 := ColorRect.new()
	divider2.color = Color(1.0, 0.82, 0.22, 0.95)
	divider2.custom_minimum_size = Vector2(0, 3)
	content.add_child(divider2)

	var understood_button := _create_button("Understood.")
	understood_button.pressed.connect(_on_understood_pressed)
	content.add_child(understood_button)

	_menu_panel.hide()
	_menu_root.hide()

func _create_button(label_text: String) -> Button:
	var button := Button.new()
	button.text = label_text
	button.custom_minimum_size = Vector2(160, 44)
	button.process_mode = Node.PROCESS_MODE_ALWAYS
	button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
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

func _on_understood_pressed() -> void:
	var tween := create_tween().set_parallel(true)
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(_darkener, "modulate:a", 0.0, MENU_FADE_DURATION)
	tween.tween_property(_menu_panel, "scale", Vector2.ZERO, MENU_FADE_DURATION)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.chain().tween_callback(_finish_close)

func _finish_close() -> void:
	_menu_root.hide()
	_darkener.modulate.a = 0.0
	
	if _starter and _starter.has_method("set_playing"):
		_starter.set_playing(true)
		
	_spawn_info_button()

func _spawn_info_button() -> void:
	if _info_button_spawned:
		return
	_info_button_spawned = true

	var button := Button.new()
	button.text = "?"
	button.custom_minimum_size = Vector2(36, 36)
	button.process_mode = Node.PROCESS_MODE_ALWAYS
	button.add_theme_font_size_override("font_size", 20)
	button.add_theme_color_override("font_color", Color(0.04, 0.19, 0.2))
	button.add_theme_stylebox_override("normal", _make_button_style(Color(0.99, 0.82, 0.32)))
	button.add_theme_stylebox_override("hover", _make_button_style(Color(1.0, 0.91, 0.47)))
	button.add_theme_stylebox_override("pressed", _make_button_style(Color(0.84, 0.6, 0.18)))
	button.pressed.connect(_on_info_pressed)
	button.set_anchors_preset(Control.PRESET_TOP_LEFT)
	button.offset_left = 1114.0
	button.offset_top = 610.0
	button.offset_right = 1150.0
	button.offset_bottom = 646.0
	_menu_layer.add_child(button)

func _on_info_pressed() -> void:
	# CHANGED: Use a safe method call if it exists instead of forcing the property directly
	if _starter and _starter.has_method("set_playing"):
		_starter.set_playing(false)
		
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
