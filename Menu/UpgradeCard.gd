extends PanelContainer
class_name UpgradeCard

signal upgrade_selected(card)

@export var upgrade_name: String = "Upgrade"
@export var tier: int = 1
@export_multiline var description: String = ""
@export var cost: int = 0
@export var icon: Texture2D
@export var is_purchased: bool = false
@export var is_locked: bool = false
@export var path_accent: Color = Color("e07b39")

@onready var icon_rect: TextureRect = $Padding/Content/Header/Icon
@onready var name_label: Label = $Padding/Content/Header/TitleGroup/Name
@onready var tier_label: Label = $Padding/Content/Header/TitleGroup/Tier
@onready var description_label: RichTextLabel = $Padding/Content/Description
@onready var cost_label: Label = $Padding/Content/Footer/Cost
@onready var cost_icon: TextureRect = $Padding/Content/Footer/CoinIcon
@onready var locked_overlay: ColorRect = $LockedOverlay

const DEFAULT_COST_ICON := preload("res://textures/mothershell.png")

func _ready() -> void:
	_populate()
	_apply_state()

func _populate() -> void:
	if icon_rect:
		icon_rect.texture = icon
	if name_label:
		name_label.text = upgrade_name
	if tier_label:
		tier_label.text = "Tier %d" % tier
	if description_label:
		description_label.text = description
	if cost_label:
		cost_label.text = str(cost)
	if cost_icon and cost_icon.texture == null:
		cost_icon.texture = DEFAULT_COST_ICON

func _apply_state() -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("1a1a2e")
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	style.border_width_left = 4
	style.border_color = path_accent

	if is_purchased:
		style.bg_color = Color("2a3a5a")
		style.border_color = path_accent.lightened(0.2)

	add_theme_stylebox_override("panel", style)
	if locked_overlay:
		locked_overlay.visible = is_locked

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		upgrade_selected.emit(self)
