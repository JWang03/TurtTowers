extends CanvasLayer

var group = ButtonGroup.new()

var upgrade_data = {
	"left": {
		"path_name": "CLUSTER BOMBER",
		"upgrades": [
			{"name": "+1 Bomb", "icon": "💣", "desc": "Adds an extra bomb to each volley.", "price": 150},
			{"name": "+1 Bomb", "icon": "💣", "desc": "Adds yet another bomb to each volley.", "price": 200},
			{"name": "+1 Bomb", "icon": "💣", "desc": "Maximum bomb payload reached.", "price": 300},
		]
	},
	"right": {
		"path_name": "MISSILE MENACE",
		"upgrades": [
			{"name": "Faster Fire", "icon": "🔥", "desc": "Increases fire rate by 20%.", "price": 175},
			{"name": "Increased Range", "icon": "🎯", "desc": "Extends targeting range significantly.", "price": 225},
			{"name": "Homing Missiles", "icon": "🚀", "desc": "Missiles track the nearest enemy.", "price": 400},
		]
	}
}

var desc_text_label: Label
var desc_price_label: Label
var desc_tween: Tween
var hidden_y: float
var shown_y: float
var desc_box: Button

func _ready() -> void:
	$LeftPathLabel.text = upgrade_data["left"]["path_name"]
	$RightPathLabel.text = upgrade_data["right"]["path_name"]
	# ... rest of _ready

	desc_box = $DescBox
	print("DescBox: ", desc_box)
	_setup_desc_box()
	_setup_path($LeftPath, upgrade_data["left"]["upgrades"])
	_setup_path($RightPath, upgrade_data["right"]["upgrades"])
	await get_tree().process_frame
	var vbox = desc_box.get_child(0)
	vbox.position = Vector2(0, 10)
	vbox.size = desc_box.size
	vbox.custom_minimum_size = desc_box.size
	shown_y = desc_box.position.y
	hidden_y = shown_y - desc_box.size.y
	desc_box.pivot_offset = Vector2(desc_box.size.x / 2, 0)
	desc_box.position.y = hidden_y
	desc_box.modulate.a = 0.0

func _setup_desc_box() -> void:
	desc_box.clip_contents = true
	desc_box.alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_box.vertical_icon_alignment = VERTICAL_ALIGNMENT_CENTER

	var vbox = VBoxContainer.new()
	vbox.position = Vector2.ZERO
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 4)
	desc_box.add_child(vbox)

	desc_text_label = Label.new()
	desc_text_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_text_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	desc_text_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	desc_text_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	desc_text_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	desc_text_label.add_theme_font_size_override("font_size", 14)
	vbox.add_child(desc_text_label)

	desc_price_label = Label.new()
	desc_price_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_price_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	desc_price_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	desc_price_label.add_theme_font_size_override("font_size", 16)
	desc_price_label.add_theme_color_override("font_color", Color("#C8942A"))
	vbox.add_child(desc_price_label)

func _setup_path(path: VBoxContainer, data: Array) -> void:
	var buttons = path.get_children()
	for i in buttons.size():
		var button: Button = buttons[i]
		button.toggle_mode = true
		button.button_group = group

		for child in button.get_children():
			child.queue_free()

		var vbox = VBoxContainer.new()
		vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
		vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		button.add_child(vbox)

		var icon = Label.new()
		icon.text = data[i]["icon"]
		icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		icon.add_theme_font_size_override("font_size", 50)
		vbox.add_child(icon)

		var label = Label.new()
		label.text = data[i]["name"]
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 24)
		label.autowrap_mode = TextServer.AUTOWRAP_WORD
		vbox.add_child(label)

		var captured_data = data[i]
		button.mouse_entered.connect(_show_desc.bind(captured_data))
		button.mouse_exited.connect(_on_mouse_exited.bind(button))
		button.toggled.connect(_on_button_toggled.bind(captured_data))

func _show_desc(data: Dictionary) -> void:
	desc_text_label.text = data["desc"]
	desc_price_label.text = str(data["price"])
	_animate_desc(true)

func _hide_desc() -> void:
	_animate_desc(false)

func _on_mouse_exited(button: Button) -> void:
	if not button.button_pressed:
		_hide_desc()

func _on_button_toggled(pressed: bool, data: Dictionary) -> void:
	if pressed:
		_show_desc(data)
	else:
		_hide_desc()

func _animate_desc(show: bool) -> void:
	if desc_tween:
		desc_tween.kill()
	desc_tween = create_tween().set_parallel(true)
	if show:
		desc_tween.tween_property(desc_box, "position:y", shown_y, 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		desc_tween.tween_property(desc_box, "modulate:a", 1.0, 0.15)
	else:
		desc_tween.tween_property(desc_box, "position:y", hidden_y, 0.15).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUART)
		desc_tween.tween_property(desc_box, "modulate:a", 0.0, 0.12)
