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
# (Make sure $MapSelectionLayer/MapSelector is now your TextureButton!)
@onready var map_overlay = $MapSelectionLayer
@onready var map_selector = $MapSelectionLayer/MapSelector
@onready var map_darkener = $MapSelectionLayer/Darkener


# Initialization
func _ready():
	# Hide all UI overlays at start
	overlay.hide()
	map_overlay.hide()
		
	# Sets colorblindness to none at start
	if colorblind_dropdown:
		colorblind_dropdown.selected = 0
	
	# Sets screen to window at start
	if fullscreen_dropdown:
		fullscreen_dropdown.selected = 0
		
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


# Settings Menu Function
func _on_settings_pressed():
	overlay.show()
	
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
	var tween = create_tween().set_parallel(true)
	tween.tween_property(darkener, "modulate:a", 0.0, 0.2)
	tween.tween_property(menu_panel, "scale", Vector2.ZERO, 0.2)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_IN)
		
	# Wait for animation to finish before hiding the layer
	tween.chain().tween_callback(overlay.hide)


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
	map_overlay.show()
	
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
	var tween = create_tween().set_parallel(true)
	tween.tween_property(map_darkener, "modulate:a", 0.0, 0.2)
	tween.tween_property(map_selector, "scale", Vector2.ZERO, 0.2)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_IN)
		
	tween.chain().tween_callback(map_overlay.hide)


func _on_map_selector_pressed() -> void:
	get_tree().change_scene_to_file("res://SandyShores/Scenes/Sandy_Beach.tscn")


# temp for closing
func _input(event):
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			if event.alt_pressed:
				# Alt + Escape: Quit the game entirely
				get_tree().quit()
			else:
				# Escape ONLY: Close the Start/Map Menu if it's open
				if map_overlay.visible:
					_on_close_map_selection_pressed()
					
				# Bonus: You can also let Escape close the Settings menu!
				elif overlay.visible:
					_on_button_pressed()
