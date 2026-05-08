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
@onready var map_return_button = $MapSelectionLayer/Return

# Towers Menu Nodes
@onready var tower_overlay = $TowersLayer
@onready var tower_darkener = $TowersLayer/CanvasLayer/Darkener
@onready var tower_return_button = $TowersLayer/ReturnTowers
@onready var tower_left_arrow = $TowersLayer/LeftArrow
@onready var tower_right_arrow = $TowersLayer/RightArrow
@onready var tower_cards = [
	$TowersLayer/CanvasLayer/"1", $TowersLayer/CanvasLayer/"2", $TowersLayer/CanvasLayer/"3",
	$TowersLayer/CanvasLayer/"4", $TowersLayer/CanvasLayer/"5", $TowersLayer/CanvasLayer/"6"
]
@onready var tower_cards_page2 = [
	$TowersLayer/CanvasLayer/"7", $TowersLayer/CanvasLayer/"8", $TowersLayer/CanvasLayer/"9",
	$TowersLayer/CanvasLayer/"10", $TowersLayer/CanvasLayer/"11", $TowersLayer/CanvasLayer/"12"
]
@onready var turts_upgrades = $TowersLayer/TurtsUpgrades

var current_tower_page: int = 0
var total_tower_pages: int = 2
const DEFAULT_OFFENSIVE_PATH_COLOR := Color("e07b39")
const DEFAULT_UTILITY_PATH_COLOR := Color("3a8fd4")
const TOWER_METADATA := {
	"1": {"name": "Demolition Turt", "icon": preload("res://Textures/bomb_tower.png")},
	"2": {"name": "Mad Scienturt", "icon": preload("res://Textures/electric_tower.png")},
	"3": {"name": "Blackhole Turt", "icon": preload("res://Textures/blackhole_tower.png")},
	"4": {"name": "Lazer Turt", "icon": preload("res://Textures/godzilla_tower.png")},
	"5": {"name": "Soldier Turt", "icon": preload("res://Textures/bullet_tower.png")},
	"6": {"name": "Fighturt Jet", "icon": preload("res://Textures/paper_airplane.png")},
	"7": {"name": "Holy Crusaturt", "icon": preload("res://Textures/holy_crusader.png")},
	"8": {"name": "Turt Sahur", "icon": preload("res://Textures/Turt^3 Sahur.png")},
	"9": {"name": "Turt Town", "icon": preload("res://Textures/TurtTown.png")},
	"10": {"name": "Placeholder", "icon": null},
	"11": {"name": "Placeholder", "icon": null},
	"12": {"name": "Placeholder", "icon": null}
}

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

# Button origins
var map_return_origin: Vector2
var tower_return_origin: Vector2

# Initialization
func _ready():
	# Hide all UI overlays at start
	settings_overlay.hide()
	map_overlay.hide()
	tower_overlay.hide()

	# Ensure tower cards and arrows are prepped for animation
	for card in tower_cards:
		card.scale = Vector2.ZERO
		card.mouse_filter = Control.MOUSE_FILTER_STOP
		if not card.gui_input.is_connected(_on_tower_card_gui_input):
			card.gui_input.connect(_on_tower_card_gui_input.bind(card))
	for card in tower_cards_page2:
		card.scale = Vector2.ZERO
		card.mouse_filter = Control.MOUSE_FILTER_STOP
		if not card.gui_input.is_connected(_on_tower_card_gui_input):
			card.gui_input.connect(_on_tower_card_gui_input.bind(card))
	tower_left_arrow.scale = Vector2.ZERO
	tower_right_arrow.scale = Vector2.ZERO

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

	# Store button origins
	map_return_origin = map_return_button.position
	tower_return_origin = tower_return_button.position

	if turts_upgrades:
		turts_upgrades.visible = false

func _on_tower_card_gui_input(event: InputEvent, card: Control) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_open_turt_upgrades(card)

func _open_turt_upgrades(card: Control) -> void:
	if turts_upgrades == null:
		return
	var turt_data := _build_turt_data(card)
	turts_upgrades.show_for_turt(turt_data)
	turts_upgrades.visible = true

func _build_turt_data(card: Control) -> Dictionary:
	var metadata: Dictionary = TOWER_METADATA.get(card.name, {})
	var turt_name: String = metadata.get("name", "Unknown Turt")
	var turt_icon: Texture2D = metadata.get("icon", null)
	var path_1 := _build_default_path_1(turt_name)
	var path_2 := _build_default_path_2(turt_name)

	return {
		"name": turt_name,
		"icon": turt_icon,
		"path_1_title": "Path 1",
		"path_2_title": "Path 2",
		"path_1_color": DEFAULT_OFFENSIVE_PATH_COLOR,
		"path_2_color": DEFAULT_UTILITY_PATH_COLOR,
		"path_1": path_1,
		"path_2": path_2
	}

func _build_default_path_1(turt_name: String) -> Array:
	return [
		{
			"upgrade_name": "Sharpened Shell",
			"tier": 1,
			"description": "%s gains improved precision and consistency." % turt_name,
			"cost": 100,
			"is_purchased": false,
			"is_locked": false
		},
		{
			"upgrade_name": "Power Burst",
			"tier": 2,
			"description": "Boosts %s base damage for stronger hits." % turt_name,
			"cost": 220,
			"is_purchased": false,
			"is_locked": true
		},
		{
			"upgrade_name": "Master Path",
			"tier": 3,
			"description": "Unlocks %s's top-end offensive branch." % turt_name,
			"cost": 450,
			"is_purchased": false,
			"is_locked": true
		}
	]

func _build_default_path_2(turt_name: String) -> Array:
	return [
		{
			"upgrade_name": "Quick Paddle",
			"tier": 1,
			"description": "Increases %s attack cadence and responsiveness." % turt_name,
			"cost": 90,
			"is_purchased": false,
			"is_locked": false
		},
		{
			"upgrade_name": "Adaptive Shell",
			"tier": 2,
			"description": "Adds utility to help %s handle crowded waves." % turt_name,
			"cost": 210,
			"is_purchased": false,
			"is_locked": true
		},
		{
			"upgrade_name": "Elite Utility",
			"tier": 3,
			"description": "Unlocks %s's late-wave support effect." % turt_name,
			"cost": 430,
			"is_purchased": false,
			"is_locked": true
		}
	]

func _update_map_display():
	if map_selector:
		map_selector.texture_normal = map_textures[current_map_index]
	if map_name_label:
		map_name_label.text = map_names[current_map_index]

# Settings Menu Functions
func _on_settings_pressed():
	settings_overlay.show()

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

	# Slide return button in from left
	map_return_button.position.x = map_return_origin.x - 200

	map_panel.pivot_offset = map_panel.size / 2
	map_panel.scale = Vector2.ZERO
	map_darkener.modulate.a = 0

	var tween = create_tween().set_parallel(true)
	tween.tween_property(map_darkener, "modulate:a", 1.0, 0.2)
	tween.tween_property(map_panel, "scale", Vector2.ONE, 0.3)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)
	tween.tween_property(map_return_button, "position:x", map_return_origin.x, 0.35)\
		.set_trans(Tween.TRANS_CUBIC)\
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
	tween.tween_property(map_return_button, "position:x", map_return_origin.x - 200, 0.2)\
		.set_trans(Tween.TRANS_CUBIC)\
		.set_ease(Tween.EASE_IN)

	tween.chain().tween_callback(map_overlay.hide)

# Towers Menu Functions
func _on_towers_pressed() -> void:
	tower_overlay.show()
	tower_darkener.modulate.a = 0
	current_tower_page = 0

	# Slide return button in from left
	tower_return_button.position.x = tower_return_origin.x - 200

	# Reset arrows for bounce animation
	tower_left_arrow.pivot_offset = tower_left_arrow.size / 2
	tower_left_arrow.scale = Vector2.ZERO
	tower_right_arrow.pivot_offset = tower_right_arrow.size / 2
	tower_right_arrow.scale = Vector2.ZERO

	var tween = create_tween().set_parallel(true)
	tween.tween_property(tower_darkener, "modulate:a", 1.0, 0.2)
	tween.tween_property(tower_return_button, "position:x", tower_return_origin.x, 0.35)\
		.set_trans(Tween.TRANS_CUBIC)\
		.set_ease(Tween.EASE_OUT)

	# Bounce arrows in like cards
	var left_tween = create_tween()
	left_tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	left_tween.tween_interval(0.1)
	left_tween.tween_property(tower_left_arrow, "scale", Vector2.ONE, 0.3)

	var right_tween = create_tween()
	right_tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	right_tween.tween_interval(0.15)
	right_tween.tween_property(tower_right_arrow, "scale", Vector2.ONE, 0.3)

	# Reset page 2 cards
	for card in tower_cards_page2:
		card.pivot_offset = card.size / 2
		card.scale = Vector2.ZERO

	# Animate page 1 cards with stagger
	for i in range(tower_cards.size()):
		var card = tower_cards[i]
		card.pivot_offset = card.size / 2
		card.scale = Vector2.ZERO

		var card_tween = create_tween()
		card_tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		card_tween.tween_interval(i * 0.05)
		card_tween.tween_property(card, "scale", Vector2.ONE, 0.3)

func _on_close_towers_pressed() -> void:
	var tween = create_tween().set_parallel(true)

	tween.tween_property(tower_darkener, "modulate:a", 0.0, 0.2)
	tween.tween_property(tower_return_button, "position:x", tower_return_origin.x - 200, 0.2)\
		.set_trans(Tween.TRANS_CUBIC)\
		.set_ease(Tween.EASE_IN)
	tween.tween_property(tower_left_arrow, "scale", Vector2.ZERO, 0.2)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_IN)
	tween.tween_property(tower_right_arrow, "scale", Vector2.ZERO, 0.2)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_IN)

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

	var out_tween = create_tween().set_parallel(true)
	for card in current_cards:
		out_tween.tween_property(card, "scale", Vector2.ZERO, 0.2)\
			.set_trans(Tween.TRANS_BACK)\
			.set_ease(Tween.EASE_IN)

	current_tower_page = new_page

	for i in range(new_cards.size()):
		var card = new_cards[i]
		card.pivot_offset = card.size / 2
		card.scale = Vector2.ZERO
		var card_tween = create_tween()
		card_tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		card_tween.tween_interval(0.2 + i * 0.05)
		card_tween.tween_property(card, "scale", Vector2.ONE, 0.3)

func _on_return_towers_pressed() -> void:
	var tween = create_tween().set_parallel(true)
	tween.tween_property(tower_darkener, "modulate:a", 0.0, 0.2)
	tween.tween_property(tower_return_button, "position:x", tower_return_origin.x - 200, 0.2)\
		.set_trans(Tween.TRANS_CUBIC)\
		.set_ease(Tween.EASE_IN)
	tween.tween_property(tower_left_arrow, "scale", Vector2.ZERO, 0.2)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_IN)
	tween.tween_property(tower_right_arrow, "scale", Vector2.ZERO, 0.2)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_IN)
	for card in tower_cards + tower_cards_page2:
		tween.tween_property(card, "scale", Vector2.ZERO, 0.2)\
			.set_trans(Tween.TRANS_BACK)\
			.set_ease(Tween.EASE_IN)

	tween.chain().tween_callback(tower_overlay.hide)
