extends CanvasLayer

const UPGRADE_SCENE_PATH_TEMPLATE := "res://Menu/Upgrades/tower_%s_upgrades.tscn"
const CARD_BUTTON_NAME := "CardButton"
const BACK_BUTTON_NAME := "BackButton"
const BACK_BUTTON_ICON_PATH := "res://Menu/Images/Gemini_Generated_Image_k2lpzqk2lpzqk2lp-removebg-preview.png"
const BACK_BUTTON_STYLE_PATH := "res://exit_button.tres"

@onready var upgrades_tree: CanvasLayer = get_parent().get_node_or_null("UpgradesTree")

var current_upgrade_instance: Node
var back_button: Button

func _ready() -> void:
	_setup_upgrades_tree()
	_setup_card_buttons()
	_ensure_back_button()
	show_tower_cards()

func _setup_upgrades_tree() -> void:
	if not upgrades_tree:
		push_error("UpgradesTree not found under TowersLayer.")
		return
	upgrades_tree.hide()

func _setup_card_buttons() -> void:
	for child in get_children():
		if child is Control and child.name.is_valid_int():
			_setup_card_button(child)

func _setup_card_button(card: Control) -> void:
	var button := card.get_node_or_null(CARD_BUTTON_NAME) as TextureButton
	if button == null:
		var existing_children := card.get_children()
		button = TextureButton.new()
		button.name = CARD_BUTTON_NAME
		button.focus_mode = Control.FOCUS_NONE
		button.mouse_filter = Control.MOUSE_FILTER_STOP
		button.set_anchors_preset(Control.PRESET_FULL_RECT)
		button.offset_left = 0.0
		button.offset_top = 0.0
		button.offset_right = 0.0
		button.offset_bottom = 0.0
		button.texture_normal = null
		button.texture_hover = null
		button.texture_pressed = null
		button.texture_disabled = null
		card.add_child(button)
		for node in existing_children:
			node.reparent(button, true)
	var pressed_callable := _on_card_pressed.bind(card)
	if not button.pressed.is_connected(pressed_callable):
		button.pressed.connect(pressed_callable)

func _on_card_pressed(card: Control) -> void:
	_open_tower_upgrades(card)

func _open_tower_upgrades(card: Control) -> void:
	if not upgrades_tree:
		return
	var tower_id := card.name
	var scene_path := UPGRADE_SCENE_PATH_TEMPLATE % tower_id
	var packed_scene := load(scene_path)
	if packed_scene is PackedScene:
		_clear_current_upgrade()
		current_upgrade_instance = packed_scene.instantiate()
		upgrades_tree.add_child(current_upgrade_instance)
	else:
		push_warning("Upgrade scene not found: %s" % scene_path)
	hide()
	upgrades_tree.show()

func _clear_current_upgrade() -> void:
	if current_upgrade_instance and current_upgrade_instance.is_inside_tree():
		current_upgrade_instance.queue_free()
	current_upgrade_instance = null

func _ensure_back_button() -> void:
	if not upgrades_tree:
		return
	back_button = upgrades_tree.get_node_or_null(BACK_BUTTON_NAME) as Button
	if back_button == null:
		back_button = Button.new()
		back_button.name = BACK_BUTTON_NAME
		back_button.text = "Back"
		back_button.focus_mode = Control.FOCUS_NONE
		back_button.anchor_left = 0.0
		back_button.anchor_top = 0.0
		back_button.anchor_right = 0.0
		back_button.anchor_bottom = 0.0
		back_button.offset_left = 12.0
		back_button.offset_top = 12.0
		back_button.offset_right = 112.0
		back_button.offset_bottom = 52.0
		_style_back_button(back_button)
		upgrades_tree.add_child(back_button)
	if not back_button.pressed.is_connected(_on_back_pressed):
		back_button.pressed.connect(_on_back_pressed)

func _style_back_button(button: Button) -> void:
	var style_box := load(BACK_BUTTON_STYLE_PATH)
	if style_box is StyleBox:
		button.add_theme_stylebox_override("normal", style_box)
	var icon_texture := load(BACK_BUTTON_ICON_PATH)
	if icon_texture is Texture2D:
		button.icon = icon_texture
		button.expand_icon = true
		button.text = ""

func _on_back_pressed() -> void:
	show_tower_cards()

func show_tower_cards() -> void:
	if upgrades_tree:
		upgrades_tree.hide()
	show()
	_clear_current_upgrade()

func close_upgrades_if_open() -> bool:
	if upgrades_tree and upgrades_tree.visible:
		show_tower_cards()
		return true
	return false
