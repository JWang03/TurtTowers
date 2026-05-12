extends PanelContainer
class_name UpgradeBox

signal upgrade_clicked(path: int, tier: int)
signal upgrade_hovered(path: int, tier: int, show: bool)

@export var upgrade_name: String = "Upgrade Name"
@export var upgrade_price: int = 0
@export var upgrade_description: String = "Placeholder description.\nInsert your own text here."
@export var path: int = 1
@export var tier: int = 1

const BASE_BG_COLOR := Color(0.15, 0.15, 0.2)
const DEFAULT_BORDER_COLOR := Color(0.4, 0.4, 0.5)
const HIGHLIGHT_BORDER_COLOR := Color(1.0, 0.85, 0.0)
const BORDER_WIDTH := 2
const CORNER_RADIUS := 8

var _style: StyleBoxFlat
func _ready() -> void:
	_ensure_style()
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	gui_input.connect(_on_gui_input)

func set_highlighted(is_highlighted: bool) -> void:
	_ensure_style()
	_style.border_color = HIGHLIGHT_BORDER_COLOR if is_highlighted else DEFAULT_BORDER_COLOR
	queue_redraw()

func set_upgrade_data(name: String, price: int, description: String) -> void:
	upgrade_name = name
	upgrade_price = price
	upgrade_description = description
	var name_label := get_node_or_null("VBoxContainer/UpgradeName") as Label
	if name_label:
		name_label.text = name

func _on_mouse_entered() -> void:
	upgrade_hovered.emit(path, tier, true)

func _on_mouse_exited() -> void:
	upgrade_hovered.emit(path, tier, false)

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		upgrade_clicked.emit(path, tier)

func _ensure_style() -> void:
	if _style != null:
		return
	_style = StyleBoxFlat.new()
	_style.bg_color = BASE_BG_COLOR
	_style.border_color = DEFAULT_BORDER_COLOR
	_style.set_border_width_all(BORDER_WIDTH)
	_style.set_corner_radius_all(CORNER_RADIUS)
	add_theme_stylebox_override("panel", _style)
