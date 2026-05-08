extends CanvasLayer

const UPGRADE_CARD_SCENE := preload("res://Menu/UpgradeCard.tscn")

@onready var close_button: Button = $CloseButton
@onready var panel: PanelContainer = $Panel
@onready var turt_icon: TextureRect = $Panel/MainHBox/Center/TurtIcon
@onready var turt_name: Label = $Panel/MainHBox/Center/TurtName
@onready var path_1_header: Label = $Panel/MainHBox/Left/Header
@onready var path_2_header: Label = $Panel/MainHBox/Right/Header
@onready var path_1_column: VBoxContainer = $Panel/MainHBox/Left/Cards
@onready var path_2_column: VBoxContainer = $Panel/MainHBox/Right/Cards

func _ready() -> void:
	visible = false
	if close_button and not close_button.pressed.is_connected(_on_close_pressed):
		close_button.pressed.connect(_on_close_pressed)
	if panel:
		var panel_style := StyleBoxFlat.new()
		panel_style.bg_color = Color("121212")
		panel_style.corner_radius_top_left = 10
		panel_style.corner_radius_top_right = 10
		panel_style.corner_radius_bottom_left = 10
		panel_style.corner_radius_bottom_right = 10
		panel.add_theme_stylebox_override("panel", panel_style)

func show_for_turt(turt_data: Dictionary) -> void:
	clear_columns()

	turt_name.text = turt_data.get("name", "Unknown Turt")
	turt_icon.texture = turt_data.get("icon", null)

	var path_1_color: Color = turt_data.get("path_1_color", Color("e07b39"))
	var path_2_color: Color = turt_data.get("path_2_color", Color("3a8fd4"))
	path_1_header.text = turt_data.get("path_1_title", "Path 1")
	path_2_header.text = turt_data.get("path_2_title", "Path 2")
	path_1_header.modulate = path_1_color
	path_2_header.modulate = path_2_color

	_populate_column(path_1_column, turt_data.get("path_1", []), path_1_color)
	_populate_column(path_2_column, turt_data.get("path_2", []), path_2_color)
	show()

func clear_columns() -> void:
	for child in path_1_column.get_children():
		child.queue_free()
	for child in path_2_column.get_children():
		child.queue_free()

func _populate_column(column: VBoxContainer, upgrades: Array, path_color: Color) -> void:
	for upgrade_data in upgrades:
		if typeof(upgrade_data) != TYPE_DICTIONARY:
			continue
		var card: UpgradeCard = UPGRADE_CARD_SCENE.instantiate() as UpgradeCard
		if card == null:
			continue
		card.path_accent = path_color
		card.upgrade_name = upgrade_data.get("upgrade_name", "Upgrade")
		card.tier = int(upgrade_data.get("tier", 1))
		card.description = upgrade_data.get("description", "")
		card.cost = int(upgrade_data.get("cost", 0))
		card.icon = upgrade_data.get("icon", turt_icon.texture)
		card.is_purchased = bool(upgrade_data.get("is_purchased", false))
		card.is_locked = bool(upgrade_data.get("is_locked", false))
		column.add_child(card)

func _on_close_pressed() -> void:
	hide()
