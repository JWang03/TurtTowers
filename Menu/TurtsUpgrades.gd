extends CanvasLayer
class_name TurtsUpgrades

const TIERS_PER_PATH := 3
const TIER_BUTTON_HEIGHT := 48.0

@onready var darkener: ColorRect = $Darkener
@onready var close_button: Button = $CloseButton
@onready var panel: PanelContainer = $Panel
@onready var turt_icon: TextureRect = $Panel/MainHBox/Center/TurtIcon
@onready var turt_name: Label = $Panel/MainHBox/Center/TurtName
@onready var path_one_cards: VBoxContainer = $Panel/MainHBox/Left/Cards
@onready var path_two_cards: VBoxContainer = $Panel/MainHBox/Right/Cards

func _ready() -> void:
	close_button.pressed.connect(_on_close_pressed)
	_ensure_tier_buttons(path_one_cards)
	_ensure_tier_buttons(path_two_cards)
	hide()

func open_for_tower(tower_name: String, tower_texture: Texture2D) -> void:
	turt_name.text = tower_name
	turt_icon.texture = tower_texture
	turt_icon.visible = tower_texture != null
	_open()

func close() -> void:
	if not visible:
		return
	_animate_close()

func _open() -> void:
	show()
	panel.pivot_offset = panel.size / 2
	panel.scale = Vector2.ZERO
	darkener.modulate.a = 0.0
	var tween = create_tween().set_parallel(true)
	tween.tween_property(darkener, "modulate:a", 0.6, 0.2)
	tween.tween_property(panel, "scale", Vector2.ONE, 0.25)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _animate_close() -> void:
	var tween = create_tween().set_parallel(true)
	tween.tween_property(darkener, "modulate:a", 0.0, 0.2)
	tween.tween_property(panel, "scale", Vector2.ZERO, 0.2)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.chain().tween_callback(hide)

func _on_close_pressed() -> void:
	close()

func _ensure_tier_buttons(container: VBoxContainer) -> void:
	if container.get_child_count() > 0:
		return
	for tier in range(1, TIERS_PER_PATH + 1):
		var button := Button.new()
		button.text = "Tier %d" % tier
		button.custom_minimum_size = Vector2(0, TIER_BUTTON_HEIGHT)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		container.add_child(button)
