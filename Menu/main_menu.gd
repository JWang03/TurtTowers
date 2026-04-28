extends Control

# Settings Menu Nodes
@onready var settings_overlay = $SettingsLayer
@onready var menu_panel = $SettingsLayer/SettingsMenu
@onready var darkener = $SettingsLayer/Darkener

# Colorblindness Nodes
@onready var colorblind_dropdown = $SettingsLayer/SettingsMenu/CBButton
@onready var fullscreen_dropdown = $SettingsLayer/SettingsMenu/FullscreenButton
@onready var volume_slider = $SettingsLayer/SettingsMenu/VolumeSlider

# Map Selection Nodes
@onready var map_overlay = $MapSelectionLayer
@onready var map_panel = $MapSelectionLayer/MapPanel
@onready var map_selector = $MapSelectionLayer/MapPanel/MapSelector
@onready var map_name_label = $MapSelectionLayer/MapPanel/MapNameLabel
@onready var map_darkener = $MapSelectionLayer/Darkener

# Towers Menu Nodes
@onready var tower_overlay = $TowersLayer
@onready var tower_darkener = $TowersLayer/Darkener
@onready var tower_cards = [
	$TowersLayer/"1", $TowersLayer/"2", $TowersLayer/"3", 
	$TowersLayer/"4", $TowersLayer/"5", $TowersLayer/"6"
]
@onready var tower_cards_page2 = [
	$TowersLayer/"7", $TowersLayer/"8", $TowersLayer/"9",
	$TowersLayer/"10", $TowersLayer/"11", $TowersLayer/"12"
]

var current_tower_page: int = 0
var total_tower_pages: int = 2

# Map data
var map_textures: Array = []
var map_names: Array = ["Sandy Shores", "Abstract", "Checkers", "Temple"]
var map_scenes: Array = [
	"res://SandyShores/Scenes/Sandy_Beach.tscn",
	"res://SandyShores/Scenes/Abstract.tscn",
	"res://SandyShores/Scenes/Checkers.tscn",
    "res://SandyShores/Scenes/Turtle_Temple.tscn"
]
var current_map_index: int = 0

# Initialization
func _ready():
	# Hide all UI overlays at start
	settings_overlay.hide()
	map_overlay.hide()
	tower_overlay.hide()
	
	# Ensure tower cards are prepped for animation
	for card in tower_cards:
		card.scale = Vector2.ZERO
	for card in tower_cards_page2:
		card.scale = Vector2.ZERO

	# Load map textures
	map_textures = [
		preload("res://Menu/Images/Maps/SandyShores.png"),
		preload("res://Menu/Images/Maps/Abstract.png"),
		preload("res://Menu/Images/Maps/Checkers.png"),
		preload("res://Menu/Images/Maps/Temple.jpg")
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
	if map_selector:
		map_selector.texture_normal = map_textures[current_map_index]
	if map_name_label:
		map_name_label.text = map_names[current_map_index]

# Settings Menu Function
func _on_settings_pressed():
	settings_overlay.show()
	
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
	tween.chain().tween_callback(settings_overlay.hide)

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
	else:
		push_warning("%s is not playable yet." % map_names[current_map_index])

func _on_return_pressed() -> void:
	var tween = create_tween().set_parallel(true)
	tween.tween_property(map_darkener, "modulate:a", 0.0, 0.2)
	tween.tween_property(map_panel, "scale", Vector2.ZERO, 0.2)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_IN)
		
	# Wait for animation to finish before hiding the map layer
	tween.chain().tween_callback(map_overlay.hide)

# Towers Menu Functions
func _on_towers_pressed() -> void:
	tower_overlay.show()
	tower_darkener.modulate.a = 0
	current_tower_page = 0

	var tween = create_tween().set_parallel(true)

	# Fade in the darkener
	tween.tween_property(tower_darkener, "modulate:a", 1.0, 0.2)

	# Reset page 2 cards so they are hidden
	for card in tower_cards_page2:
		card.pivot_offset = card.size / 2
		card.scale = Vector2.ZERO

	# Animate page 1 cards with a slight stagger/delay for each
	for i in range(tower_cards.size()):
		var card = tower_cards[i]
		card.pivot_offset = card.size / 2
		card.scale = Vector2.ZERO

		# Create a secondary tween for the individual card bounce
		var card_tween = create_tween()
		card_tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

		# Delay each card by 0.05 seconds multiplied by its index
		card_tween.tween_interval(i * 0.05)
		card_tween.tween_property(card, "scale", Vector2.ONE, 0.3)

func _on_close_towers_pressed() -> void:
	var tween = create_tween().set_parallel(true)

	# Fade out darkener
	tween.tween_property(tower_darkener, "modulate:a", 0.0, 0.2)

	# Shrink all cards (both pages) simultaneously
	for card in tower_cards + tower_cards_page2:
		tween.tween_property(card, "scale", Vector2.ZERO, 0.2)\
			.set_trans(Tween.TRANS_BACK)\
			.set_ease(Tween.EASE_IN)

	tween.chain().tween_callback(tower_overlay.hide)

# Input handling for closing menus
func _input(event):
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			if event.alt_pressed:
				get_tree().quit()
			else:
				if tower_overlay.visible:
					_on_close_towers_pressed()
				elif settings_overlay.visible:
					_on_button_pressed()
				elif map_overlay.visible:
					_on_return_pressed()


func _on_left_tower_pressed() -> void:
	var new_page = (current_tower_page - 1 + total_tower_pages) % total_tower_pages
	_switch_tower_page(new_page)


func _on_right_tower_pressed() -> void:
	var new_page = (current_tower_page + 1) % total_tower_pages
	_switch_tower_page(new_page)


func _switch_tower_page(new_page: int) -> void:
	if new_page == current_tower_page:
		return

	var current_cards = tower_cards if current_tower_page == 0 else tower_cards_page2
	var new_cards = tower_cards if new_page == 0 else tower_cards_page2

	# Shrink the current page's cards out
	var out_tween = create_tween().set_parallel(true)
	for card in current_cards:
		out_tween.tween_property(card, "scale", Vector2.ZERO, 0.2)\
			.set_trans(Tween.TRANS_BACK)\
			.set_ease(Tween.EASE_IN)

	current_tower_page = new_page

	# Animate the new page's cards in with stagger (after the out animation)
	for i in range(new_cards.size()):
		var card = new_cards[i]
		card.pivot_offset = card.size / 2
		card.scale = Vector2.ZERO
		var card_tween = create_tween()
		card_tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		card_tween.tween_interval(0.2 + i * 0.05)
		card_tween.tween_property(card, "scale", Vector2.ONE, 0.3)
