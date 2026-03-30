extends Control

# Settings Menu Nodes
@onready var overlay = $CanvasLayer
@onready var menu_panel = $CanvasLayer/SettingsMenu
@onready var darkener = $CanvasLayer/Darkener

# Colorblindness Nodes
@onready var colorblind_dropdown = $CanvasLayer/SettingsMenu/CBButton
@onready var fullscreen_dropdown = $CanvasLayer/SettingsMenu/FullscreenButton
@onready var volume_slider = $CanvasLayer/SettingsMenu/VolumeSlider

# Map Selection Nodes
@onready var map_overlay = $MapSelectionLayer
@onready var map_panel = $MapSelectionLayer/MapPanel
@onready var map_selector = $MapSelectionLayer/MapPanel/MapSelector
@onready var map_name_label = $MapSelectionLayer/MapPanel/MapNameLabel
@onready var map_darkener = $MapSelectionLayer/Darkener

# Map data
var map_textures: Array = []
var map_names: Array = ["Sandy Shores", "Checkers", "Abstract"]
var map_scenes: Array = [
	"res://SandyShores/Scenes/Sandy_Beach.tscn",
	null,
	null
]
var current_map_index: int = 0


# Initialization
func _ready():
	# Hide all UI overlays at start
	overlay.hide()
	map_overlay.hide()

	# Load map textures
	map_textures = [
		preload("res://Menu/Images/SandyShores.png"),
		preload("res://Menu/Images/Checkers.png"),
		preload("res://Menu/Images/Abstract.png")
	]
	assert(map_textures.size() == map_names.size() and map_names.size() == map_scenes.size(), \
		"Map data arrays must have the same length")

	# Sync UI controls to GlobalSettings state so changes persist across scenes
	if colorblind_dropdown:
		colorblind_dropdown.selected = GlobalSettings.colorblind_mode
	if fullscreen_dropdown:
		fullscreen_dropdown.selected = GlobalSettings.fullscreen_mode
	if volume_slider:
		volume_slider.value = GlobalSettings.volume_value


func _update_map_display():
	map_selector.texture_normal = map_textures[current_map_index]
	map_name_label.text = map_names[current_map_index]


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
	GlobalSettings.set_volume(value)


func _on_option_button_item_selected(index: int) -> void:
	GlobalSettings.set_colorblind(index)


func _on_fullscreen_item_selected(index: int) -> void:
	GlobalSettings.set_fullscreen(index)


# Map Selection Functions
func _on_start_game_pressed() -> void:
	current_map_index = 0
	_update_map_display()
	map_overlay.show()
	
	# Center pivot for the popup bounce animation
	map_panel.pivot_offset = map_panel.size / 2
	map_panel.scale = Vector2.ZERO 
	map_darkener.modulate.a = 0         
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(map_darkener, "modulate:a", 1.0, 0.2)
	tween.tween_property(map_panel, "scale", Vector2.ONE, 0.3)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)


func _on_close_map_selection_pressed() -> void:
	var tween = create_tween().set_parallel(true)
	tween.tween_property(map_darkener, "modulate:a", 0.0, 0.2)
	tween.tween_property(map_panel, "scale", Vector2.ZERO, 0.2)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_IN)
		
	tween.chain().tween_callback(map_overlay.hide)


func _on_left_arrow_pressed() -> void:
	current_map_index = (current_map_index - 1 + map_names.size()) % map_names.size()
	_update_map_display()


func _on_right_arrow_pressed() -> void:
	current_map_index = (current_map_index + 1) % map_names.size()
	_update_map_display()


func _on_map_selector_pressed() -> void:
	var scene_path = map_scenes[current_map_index]
	if scene_path != null:
		get_tree().change_scene_to_file(scene_path)


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
