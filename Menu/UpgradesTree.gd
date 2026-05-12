extends CanvasLayer

signal upgrade_selected(path: int, tier: int)
signal tower_sold()

@export var tower_name: String = "Tower Name"
@export var sell_value: int = 0
@export var path1_upgrades: Array[Dictionary] = []
@export var path2_upgrades: Array[Dictionary] = []

var selected_upgrade: Dictionary = {}

const DEFAULT_UPGRADE_NAME := "Upgrade Name"
const DEFAULT_UPGRADE_DESCRIPTION := "Placeholder description.\nInsert your own text here."

@onready var tower_name_label: Label = $Background/MainLayout/TowerCard/Content/TowerName
@onready var selected_upgrade_name_label: Label = $Background/MainLayout/TowerCard/Content/SelectedUpgradeName
@onready var selected_upgrade_price_label: Label = $Background/MainLayout/TowerCard/Content/SelectedUpgradePrice
@onready var sell_value_label: Label = $Background/MainLayout/TowerCard/Content/SellValue
@onready var sell_button: Button = $Background/MainLayout/TowerCard/Content/SellButton
@onready var tooltip_box: PanelContainer = $Background/TooltipBox
@onready var tooltip_title: Label = $Background/TooltipBox/Content/TooltipTitle
@onready var tooltip_description: Label = $Background/TooltipBox/Content/TooltipDescription

@onready var path1_boxes: Array[UpgradeBox] = [
	$Background/MainLayout/Path1/P1_Upgrade1,
	$Background/MainLayout/Path1/P1_Upgrade2,
	$Background/MainLayout/Path1/P1_Upgrade3
]
@onready var path2_boxes: Array[UpgradeBox] = [
	$Background/MainLayout/Path2/P2_Upgrade1,
	$Background/MainLayout/Path2/P2_Upgrade2,
	$Background/MainLayout/Path2/P2_Upgrade3
]

var _all_boxes: Array[UpgradeBox] = []

func _ready() -> void:
	sell_button.pressed.connect(_on_sell_button_pressed)
	_all_boxes = path1_boxes + path2_boxes
	for box in _all_boxes:
		box.upgrade_clicked.connect(_on_upgrade_clicked)
		box.upgrade_hovered.connect(_on_upgrade_hovered)
	refresh_ui()

func refresh_ui() -> void:
	tower_name_label.text = tower_name
	sell_value_label.text = "Sell: $%s" % _format_price(sell_value)
	_update_upgrade_boxes(1, path1_upgrades, path1_boxes)
	_update_upgrade_boxes(2, path2_upgrades, path2_boxes)

func _update_upgrade_boxes(path: int, upgrades: Array[Dictionary], boxes: Array[UpgradeBox]) -> void:
	for index in range(boxes.size()):
		var upgrade_data := _build_upgrade_data(upgrades[index]) if index < upgrades.size() else _build_upgrade_data({})
		var box := boxes[index]
		box.path = path
		box.tier = index + 1
		box.set_upgrade_data(
			upgrade_data["name"],
			upgrade_data["price"],
			upgrade_data["description"]
		)
		box.set_highlighted(false)

func _build_upgrade_data(raw_data: Dictionary) -> Dictionary:
	return {
		"name": str(raw_data.get("name", DEFAULT_UPGRADE_NAME)),
		"price": int(raw_data.get("price", 0)),
		"description": str(raw_data.get("description", DEFAULT_UPGRADE_DESCRIPTION))
	}

func _get_upgrade_data(path: int, tier: int) -> Dictionary:
	var upgrades := path1_upgrades if path == 1 else path2_upgrades
	if tier - 1 >= 0 and tier - 1 < upgrades.size():
		return _build_upgrade_data(upgrades[tier - 1])
	return _build_upgrade_data({})

func _on_upgrade_clicked(path: int, tier: int) -> void:
	var upgrade_data := _get_upgrade_data(path, tier)
	selected_upgrade = upgrade_data
	selected_upgrade_name_label.text = upgrade_data["name"]
	selected_upgrade_price_label.text = "$%s" % _format_price(upgrade_data["price"])
	_update_highlights(path, tier)
	upgrade_selected.emit(path, tier)

func _on_upgrade_hovered(path: int, tier: int, show: bool) -> void:
	if not show:
		tooltip_box.visible = false
		return
	var upgrade_data := _get_upgrade_data(path, tier)
	tooltip_title.text = upgrade_data["name"]
	tooltip_description.text = upgrade_data["description"]
	tooltip_box.visible = true
	tooltip_box.global_position = tooltip_box.get_global_mouse_position() + Vector2(16, 16)

func _update_highlights(selected_path: int, selected_tier: int) -> void:
	for box in _all_boxes:
		box.set_highlighted(box.path == selected_path and box.tier == selected_tier)

func _on_sell_button_pressed() -> void:
	tower_sold.emit()

func _format_price(value: int) -> String:
	return "%03d" % value
