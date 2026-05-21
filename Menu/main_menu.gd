extends Control

const DEFAULT_TOWER_NAME := "Turt"
const TOWER_SCENE_AUTOSAVE_PATH := "user://tower_scene_autosave.json"
# Settings Menu Nodes
@onready var settings_overlay = $SettingsLayer
@onready var menu_panel = $SettingsLayer/SettingsMenu
@onready var darkener = $SettingsLayer/Darkener

# Colorblindness Nodes
@onready var colorblind_dropdown = $SettingsLayer/SettingsMenu.find_child("CBButton", true, false)
@onready var fullscreen_dropdown = $SettingsLayer/SettingsMenu.find_child("FullscreenButton", true, false)
@onready var volume_slider = $SettingsLayer/SettingsMenu.find_child("VolumeSlider", true, false)

# Map Selection Nodes
@onready var map_overlay = $MapSelectionLayer
@onready var map_panel = $MapSelectionLayer/MapPanel
@onready var map_selector = $MapSelectionLayer/MapPanel/MapSelector
@onready var map_name_label = $MapSelectionLayer/MapPanel/MapNameLabel
@onready var map_darkener = $MapSelectionLayer/Darkener
@onready var map_return_button = $MapSelectionLayer/Return

# Towers Menu Nodes
@onready var tower_overlay = $TowersLayer
@onready var tower_layer = $TowersLayer/Turts
@onready var tower_darkener = $TowersLayer/Turts/Darkener
@onready var tower_return_button = $TowersLayer/ReturnTowers
@onready var tower_left_arrow = $TowersLayer/Turts/LeftArrow
@onready var tower_right_arrow = $TowersLayer/Turts/RightArrow
@onready var tower_cards = [
	$TowersLayer/Turts/"1", $TowersLayer/Turts/"2", $TowersLayer/Turts/"3",
	$TowersLayer/Turts/"4", $TowersLayer/Turts/"5", $TowersLayer/Turts/"6"
]
@onready var tower_cards_page2 = [
	$TowersLayer/Turts/"7", $TowersLayer/Turts/"8", $TowersLayer/Turts/"9",
	$TowersLayer/Turts/"10", $TowersLayer/Turts/"11", $TowersLayer/Turts/"12"
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

# Button origins
var map_return_origin: Vector2
var tower_return_origin: Vector2

func _ready():
	tower_darkener.hide()
	settings_overlay.hide()
	map_overlay.hide()
	tower_overlay.hide()
	tower_layer.hide()
	$TowersLayer/UpgradeTrees.hide()

	for card in tower_cards + tower_cards_page2:
		if card:
			card.scale = Vector2.ZERO
	if tower_left_arrow:
		tower_left_arrow.scale = Vector2.ZERO
	if tower_right_arrow:
		tower_right_arrow.scale = Vector2.ZERO

	map_textures = [
		preload("res://Menu/Images/Maps/SandyShores.png"),
		preload("res://Menu/Images/Maps/Abstract.png"),
		preload("res://Menu/Images/Maps/Checkers.png"),
		preload("res://Menu/Images/Maps/Temple.jpg")
	]
	assert(map_textures.size() == map_names.size() and map_names.size() == map_scenes.size(), \
		"Map data arrays must have the same length")

	if colorblind_dropdown:
		colorblind_dropdown.selected = GlobalSettings.colorblind_mode
	if fullscreen_dropdown:
		fullscreen_dropdown.selected = GlobalSettings.fullscreen_mode
	if volume_slider:
		volume_slider.value = GlobalSettings.volume_value

	map_return_origin = map_return_button.position
	tower_return_origin = tower_return_button.position

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
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _on_button_pressed() -> void:
	var tween = create_tween().set_parallel(true)
	tween.tween_property(darkener, "modulate:a", 0.0, 0.2)
	tween.tween_property(menu_panel, "scale", Vector2.ZERO, 0.2)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
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
	map_return_button.position.x = map_return_origin.x - 200
	map_panel.pivot_offset = map_panel.size / 2
	map_panel.scale = Vector2.ZERO
	map_darkener.modulate.a = 0

	var tween = create_tween().set_parallel(true)
	tween.tween_property(map_darkener, "modulate:a", 1.0, 0.2)
	tween.tween_property(map_panel, "scale", Vector2.ONE, 0.3)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(map_return_button, "position:x", map_return_origin.x, 0.35)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func _on_left_arrow_pressed() -> void:
	current_map_index = (current_map_index - 1 + map_names.size()) % map_names.size()
	_update_map_display()

func _on_right_arrow_pressed() -> void:
	current_map_index = (current_map_index + 1) % map_names.size()
	_update_map_display()

func _on_map_selector_pressed() -> void:
	var scene_path = map_scenes[current_map_index]
	scene_path = _get_resume_scene(scene_path)

	if scene_path != null:
		get_tree().change_scene_to_file(scene_path)
	else:
		push_warning("%s is not playable yet." % map_names[current_map_index])

func _get_resume_scene(default_scene_path: String) -> String:
	if not FileAccess.file_exists(TOWER_SCENE_AUTOSAVE_PATH):
		return default_scene_path

	var autosave_file := FileAccess.open(TOWER_SCENE_AUTOSAVE_PATH, FileAccess.READ)
	if autosave_file == null:
		return default_scene_path

	var parsed = JSON.parse_string(autosave_file.get_as_text())
	if not (parsed is Dictionary):
		return default_scene_path

	var saved_scene_path: String = str(parsed.get("scene", default_scene_path))
	if saved_scene_path != default_scene_path:
		return default_scene_path
	if not ResourceLoader.exists(saved_scene_path):
		return default_scene_path

	return saved_scene_path

func _on_return_pressed() -> void:
	var tween = create_tween().set_parallel(true)
	tween.tween_property(map_darkener, "modulate:a", 0.0, 0.2)
	tween.tween_property(map_panel, "scale", Vector2.ZERO, 0.2)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.tween_property(map_return_button, "position:x", map_return_origin.x - 200, 0.2)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.chain().tween_callback(map_overlay.hide)

# Towers Menu Functions
func _on_towers_pressed() -> void:
	if tower_layer and tower_layer.has_method("show_tower_cards"):
		tower_layer.show_tower_cards()
	tower_darkener.show()
	tower_overlay.show()
	tower_layer.show()
	tower_darkener.modulate.a = 0
	current_tower_page = 0
	tower_return_button.position.x = tower_return_origin.x - 200

	tower_left_arrow.pivot_offset = tower_left_arrow.size / 2
	tower_left_arrow.scale = Vector2.ZERO
	tower_right_arrow.pivot_offset = tower_right_arrow.size / 2
	tower_right_arrow.scale = Vector2.ZERO

	var tween = create_tween().set_parallel(true)
	tween.tween_property(tower_darkener, "modulate:a", 1.0, 0.2)
	tween.tween_property(tower_return_button, "position:x", tower_return_origin.x, 0.35)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	var left_tween = create_tween()
	left_tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	left_tween.tween_interval(0.1)
	left_tween.tween_property(tower_left_arrow, "scale", Vector2.ONE, 0.3)

	var right_tween = create_tween()
	right_tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	right_tween.tween_interval(0.15)
	right_tween.tween_property(tower_right_arrow, "scale", Vector2.ONE, 0.3)

	for card in tower_cards_page2:
		card.pivot_offset = card.size / 2
		card.scale = Vector2.ZERO

	for i in range(tower_cards.size()):
		var card = tower_cards[i]
		card.pivot_offset = card.size / 2
		card.scale = Vector2.ZERO
		var card_tween = create_tween()
		card_tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		card_tween.tween_interval(i * 0.05)
		card_tween.tween_property(card, "scale", Vector2.ONE, 0.3)

func _on_close_towers_pressed() -> void:
	if tower_layer and tower_layer.has_method("show_tower_cards"):
		tower_layer.show_tower_cards()
	var tween = create_tween().set_parallel(true)
	tween.tween_property(tower_darkener, "modulate:a", 0.0, 0.2)
	tween.tween_property(tower_return_button, "position:x", tower_return_origin.x - 200, 0.2)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_property(tower_left_arrow, "scale", Vector2.ZERO, 0.2)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.tween_property(tower_right_arrow, "scale", Vector2.ZERO, 0.2)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	for card in tower_cards + tower_cards_page2:
		tween.tween_property(card, "scale", Vector2.ZERO, 0.2)\
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.chain().tween_callback(tower_layer.hide)
	tween.chain().tween_callback(tower_overlay.hide)

func _on_return_towers_pressed() -> void:
	if tower_layer and tower_layer.has_method("close_upgrades_if_open"):
		if tower_layer.close_upgrades_if_open():
			return
	var tween = create_tween().set_parallel(true)
	tween.tween_property(tower_darkener, "modulate:a", 0.0, 0.2)
	tween.tween_property(tower_return_button, "position:x", tower_return_origin.x - 200, 0.2)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_property(tower_left_arrow, "scale", Vector2.ZERO, 0.2)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.tween_property(tower_right_arrow, "scale", Vector2.ZERO, 0.2)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	for card in tower_cards + tower_cards_page2:
		tween.tween_property(card, "scale", Vector2.ZERO, 0.2)\
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.chain().tween_callback(tower_layer.hide)
	tween.chain().tween_callback(tower_overlay.hide)

func _input(event):
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			if event.alt_pressed:
				get_tree().quit()
			else:
				if tower_layer and tower_layer.has_method("close_upgrades_if_open"):
					if tower_layer.close_upgrades_if_open():
						return
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
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)

	current_tower_page = new_page

	for i in range(new_cards.size()):
		var card = new_cards[i]
		card.pivot_offset = card.size / 2
		card.scale = Vector2.ZERO
		var card_tween = create_tween()
		card_tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		card_tween.tween_interval(0.2 + i * 0.05)
		card_tween.tween_property(card, "scale", Vector2.ONE, 0.3)
