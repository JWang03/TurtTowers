extends Control

# Audio
var master_bus = AudioServer.get_bus_index("Master")

# Settings Menu Nodes
@onready var overlay = $CanvasLayer
@onready var menu_panel = $CanvasLayer/SettingsMenu
@onready var darkener = $CanvasLayer/Darkener

# Colorblindness Nodes
@onready var colorblind_dropdown = $CanvasLayer/SettingsMenu/CBButton
@onready var fullscreen_dropdown = $CanvasLayer/SettingsMenu/FullscreenButton
@onready var colorblind_filter = $ColorblindLayer/ColorRect

# Map Selection Nodes 
@onready var map_overlay = $MapSelectionLayer
@onready var map_selector = $MapSelectionLayer/MapSelector
@onready var map_darkener = $MapSelectionLayer/Darkener

# Towers Menu Nodes
@onready var towers_overlay = $TowersLayer
@onready var towers_panel = $TowersLayer/TowersPanel
@onready var towers_darkener = $TowersLayer/Darkener


# Initialization
func _ready():
	# Hide all UI overlays at start
	overlay.hide()
	map_overlay.hide()
	towers_overlay.hide()
		
	# Sets colorblindness to none at start
	if colorblind_dropdown:
		colorblind_dropdown.selected = 0
	
	# Sets screen to window at start
	if fullscreen_dropdown:
		fullscreen_dropdown.selected = 2
		
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


# Settings Menu Function
func _on_settings_pressed():
	# Reset mouse filters so the menu can block clicks again
	darkener.mouse_filter = Control.MOUSE_FILTER_STOP
	menu_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	
	overlay.show()
	menu_panel.show()
	darkener.show()
	
	# Center pivot for the popup bounce animation
	menu_panel.pivot_offset = menu_panel.size / 2
	menu_panel.scale = Vector2.ZERO 
	darkener.modulate.a = 0         
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(darkener, "modulate:a", 1.0, 0.2)
	tween.tween_property(menu_panel, "scale", Vector2.ONE, 0.3)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)


func _on_button_pressed() -> void:
	# Immediately turn off the invisible shield
	darkener.mouse_filter = Control.MOUSE_FILTER_IGNORE
	menu_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(darkener, "modulate:a", 0.0, 0.2)
	tween.tween_property(menu_panel, "scale", Vector2.ZERO, 0.2)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_IN)
		
	# Wait for animation to finish before explicitly hiding everything
	tween.chain().tween_callback(overlay.hide)
	tween.tween_callback(menu_panel.hide)
	tween.tween_callback(darkener.hide)


func _on_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(master_bus, linear_to_db(value))
	# Hard mute if the slider is basically at zero
	AudioServer.set_bus_mute(master_bus, value < 0.05)


func _on_option_button_item_selected(index: int) -> void:
	# Passes the 0-3 index straight to the shader uniform
	if colorblind_filter:
		colorblind_filter.material.set_shader_parameter("mode", index)


func _on_fullscreen_item_selected(index: int) -> void:
	match index:
		0: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		1: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		2: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)


# Map Selection Function
func _on_start_game_pressed() -> void:
	# Reset mouse filters for the map selection
	map_darkener.mouse_filter = Control.MOUSE_FILTER_STOP
	map_selector.mouse_filter = Control.MOUSE_FILTER_STOP
	
	map_overlay.show()
	map_selector.show()
	map_darkener.show()
	
	# Center pivot for the popup bounce animation
	map_selector.pivot_offset = map_selector.size / 2
	map_selector.scale = Vector2.ZERO 
	map_darkener.modulate.a = 0         
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(map_darkener, "modulate:a", 1.0, 0.2)
	tween.tween_property(map_selector, "scale", Vector2.ONE, 0.3)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)


func _on_close_map_selection_pressed() -> void:
	# Immediately turn off the invisible shield
	map_darkener.mouse_filter = Control.MOUSE_FILTER_IGNORE
	map_selector.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(map_darkener, "modulate:a", 0.0, 0.2)
	tween.tween_property(map_selector, "scale", Vector2.ZERO, 0.2)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_IN)
		
	# Wait for animation to finish before explicitly hiding everything
	tween.chain().tween_callback(map_overlay.hide)
	tween.tween_callback(map_selector.hide)
	tween.tween_callback(map_darkener.hide)


# Towers Menu Functions
func _on_towers_pressed() -> void:
	towers_darkener.mouse_filter = Control.MOUSE_FILTER_STOP
	towers_panel.mouse_filter = Control.MOUSE_FILTER_STOP

	towers_overlay.show()
	towers_panel.show()
	towers_darkener.show()

	towers_panel.pivot_offset = towers_panel.size / 2
	towers_panel.scale = Vector2.ZERO
	towers_darkener.modulate.a = 0

	var tween = create_tween().set_parallel(true)
	tween.tween_property(towers_darkener, "modulate:a", 1.0, 0.2)
	tween.tween_property(towers_panel, "scale", Vector2.ONE, 0.3)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)


func _on_close_towers_pressed() -> void:
	towers_darkener.mouse_filter = Control.MOUSE_FILTER_IGNORE
	towers_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var tween = create_tween().set_parallel(true)
	tween.tween_property(towers_darkener, "modulate:a", 0.0, 0.2)
	tween.tween_property(towers_panel, "scale", Vector2.ZERO, 0.2)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_IN)

	tween.chain().tween_callback(towers_overlay.hide)
	tween.tween_callback(towers_panel.hide)
	tween.tween_callback(towers_darkener.hide)
