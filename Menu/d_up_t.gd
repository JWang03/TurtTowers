extends CanvasLayer

var group = ButtonGroup.new()

# upgrade_data[path][index] = {name, icon}
var upgrade_data = {
	"left": [
		{"name": "Double Barrel", "icon": "💣"},
		{"name": "Napalm", "icon": "🔥"},
		{"name": "MIRV", "icon": "💥"},
	],
	"right": [
		{"name": "Thick Shell", "icon": "🛡️"},
		{"name": "Mortar", "icon": "🎯"},
		{"name": "Nuke", "icon": "☢️"},
	]
}

func _ready() -> void:
	_setup_path($LeftPath, upgrade_data["left"])
	_setup_path($RightPath, upgrade_data["right"])

func _setup_path(path: VBoxContainer, data: Array) -> void:
	var buttons = path.get_children()
	for i in buttons.size():
		var button: Button = buttons[i]
		button.toggle_mode = true
		button.button_group = group
		
		# Clear existing children
		for child in button.get_children():
			child.queue_free()
		
		# Add VBox inside button
		var vbox = VBoxContainer.new()
		vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
		vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		button.add_child(vbox)
		
		# Icon label
		var icon = Label.new()
		icon.text = data[i]["icon"]
		icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		icon.add_theme_font_size_override("font_size", 24)
		vbox.add_child(icon)
		
		# Name label
		var label = Label.new()
		label.text = data[i]["name"]
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 12)
		label.autowrap_mode = TextServer.AUTOWRAP_WORD
		vbox.add_child(label)
