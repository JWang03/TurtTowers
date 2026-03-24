extends CanvasLayer

var colorblind_mode: int = 0
signal settings_updated

@onready var menu_panel = $MenuPanel
@onready var colorblind_filter = $ColorblindFilter

func _ready():
	menu_panel.hide()
	# Initialize the filter state on startup
	update_filter_shader()

func toggle_menu():
	menu_panel.visible = !menu_panel.visible
	get_tree().paused = menu_panel.visible

func _on_colorblind_dropdown_item_selected(index: int):
	colorblind_mode = index
	update_filter_shader()
	settings_updated.emit()

func update_filter_shader():
	# Example: Let's assume 0 is "Off"
	if colorblind_mode == 0:
		colorblind_filter.hide()
	else:
		colorblind_filter.show()
		# Pass the specific mode to your shader so it knows which filter to apply
		# (e.g., 1 = Protanopia, 2 = Deuteranopia, 3 = Tritanopia)
		colorblind_filter.material.set_shader_parameter("mode", colorblind_mode)
