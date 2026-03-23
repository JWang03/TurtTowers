extends CanvasLayer

# Store your persistent settings here
var colorblind_mode: int = 0
var master_volume: float = 1.0

# Signal to let other scenes know a setting changed
signal settings_updated

@onready var menu_panel = $MenuPanel

func _ready():
	# Ensure it's hidden when the game starts
	menu_panel.hide()

func toggle_menu():
	menu_panel.visible = !menu_panel.visible
	
	# Optional: Pause the game when the menu is open
	get_tree().paused = menu_panel.visible

# Example function hooked up to your UI (e.g., an OptionButton)
func _on_colorblind_dropdown_item_selected(index: int):
	colorblind_mode = index
	settings_updated.emit()
	apply_colorblind_filter() # A custom function you'd write to apply the shader
