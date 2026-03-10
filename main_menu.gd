extends Control

# --- VARIABLES ---
var master_bus = AudioServer.get_bus_index("Master")

# Grabs references to your UI nodes (UPDATED PATHS)
@onready var overlay = $SettingsOverlay
@onready var menu_panel = $SettingsOverlay/SettingsMenu
@onready var darkener = $SettingsOverlay/Darkener

# Reference to the colorblind filter ColorRect
@onready var colorblind_filter = $ColorblindLayer/ColorRect

# References to the dropdown menus (UPDATED PATHS)
@onready var colorblind_dropdown = $SettingsOverlay/SettingsMenu/ColorblindDropdown
@onready var screen_mode_dropdown = $SettingsOverlay/SettingsMenu/ScreenModeDropdown


# --- BUILT-IN FUNCTIONS ---
func _ready():
	# Keep the settings menu hidden on start
	overlay.hide()
	
	# Force the colorblind dropdown to visually select the first option ("Default")
	if colorblind_dropdown:
		colorblind_dropdown.selected = 0
		colorblind_dropdown.fit_to_longest_item = false
		
	# Manually tell the shader to use mode 0 (Normal Colors) on startup
	if colorblind_filter:
		colorblind_filter.material.set_shader_parameter("mode", 0)
		
	# Force the screen options dropdown to "Windowed" (Index 0) on startup
	if screen_mode_dropdown:
		screen_mode_dropdown.selected = 0
		screen_mode_dropdown.fit_to_longest_item = false 
		
	# Force the actual game window into Windowed mode just to be safe
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


# --- SIGNAL FUNCTIONS ---

# Connect your main "Settings" button to this
func _on_settings_pressed():
	print("The settings button was clicked!") 
	overlay.show()
	
	menu_panel.pivot_offset = menu_panel.size / 2
	menu_panel.scale = Vector2.ZERO 
	darkener.modulate.a = 0         
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(darkener, "modulate:a", 1.0, 0.2)
	tween.tween_property(menu_panel, "scale", Vector2.ONE, 0.3)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)

# Connect your new "CloseMenuButton" to this
func _on_close_menu_button_pressed() -> void:
	var tween = create_tween().set_parallel(true)
	tween.tween_property(darkener, "modulate:a", 0.0, 0.2)
	tween.tween_property(menu_panel, "scale", Vector2.ZERO, 0.2)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_IN)
	tween.chain().tween_callback(overlay.hide)

# Connect your new "VolumeSlider" to this
func _on_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(master_bus, linear_to_db(value))
	AudioServer.set_bus_mute(master_bus, value < 0.05)

# Connect your new "ColorblindDropdown" to this
func _on_colorblind_dropdown_item_selected(index: int) -> void:
	if colorblind_filter:
		colorblind_filter.material.set_shader_parameter("mode", index)

# Connect your new "ScreenModeDropdown" to this
func _on_screen_mode_dropdown_item_selected(index: int) -> void:
	match index:
		0:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		1:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		2:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
