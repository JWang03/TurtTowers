extends CanvasLayer

const DEFAULT_VOLUME: float = 0.5
const MENU_FADE_DURATION: float = 0.2
const MENU_SCALE_DURATION: float = 0.3

var colorblind_mode: int = 0
var volume_value: float = DEFAULT_VOLUME
var fullscreen_mode: int = 0
var _is_animating: bool = false

signal settings_updated

@onready var menu_panel = $MenuPanel
@onready var colorblind_filter = $ColorblindFilter
@onready var music_player = $MusicPlayer
@onready var darkener = $MenuPanel/Darkener
@onready var settings_rect = $MenuPanel/SettingsMenu
@onready var cb_dropdown = $MenuPanel/SettingsMenu/CBButton
@onready var fs_dropdown = $MenuPanel/SettingsMenu/FullscreenButton
@onready var vol_slider = $MenuPanel/SettingsMenu/VolumeSlider

var master_bus = AudioServer.get_bus_index("Master")

func _ready():
	menu_panel.hide()
	update_filter_shader()
	# Start background music if not already playing
	if music_player and not music_player.playing:
		music_player.play()

func toggle_menu():
	if _is_animating:
		return
	if menu_panel.visible:
		_close_menu()
	else:
		_open_menu()

func _open_menu():
	_is_animating = true
	menu_panel.show()
	get_tree().paused = true
	# Sync UI controls to current state
	cb_dropdown.selected = colorblind_mode
	fs_dropdown.selected = fullscreen_mode
	vol_slider.value = volume_value
	# Pop-in animation
	settings_rect.pivot_offset = settings_rect.size / 2
	settings_rect.scale = Vector2.ZERO
	darkener.modulate.a = 0
	var tween = create_tween().set_parallel(true)
	tween.tween_property(darkener, "modulate:a", 1.0, MENU_FADE_DURATION)
	tween.tween_property(settings_rect, "scale", Vector2.ONE, MENU_SCALE_DURATION) \
		.set_trans(Tween.TRANS_BACK) \
		.set_ease(Tween.EASE_OUT)
	tween.chain().tween_callback(func(): _is_animating = false)

func _close_menu():
	_is_animating = true
	var tween = create_tween().set_parallel(true)
	tween.tween_property(darkener, "modulate:a", 0.0, MENU_FADE_DURATION)
	tween.tween_property(settings_rect, "scale", Vector2.ZERO, MENU_FADE_DURATION) \
		.set_trans(Tween.TRANS_BACK) \
		.set_ease(Tween.EASE_IN)
	tween.chain().tween_callback(func():
		menu_panel.hide()
		get_tree().paused = false
		_is_animating = false
	)

func set_colorblind(index: int):
	colorblind_mode = index
	update_filter_shader()
	settings_updated.emit()

func set_volume(value: float):
	volume_value = value
	AudioServer.set_bus_volume_db(master_bus, linear_to_db(value))
	AudioServer.set_bus_mute(master_bus, value < 0.05)

func set_fullscreen(index: int):
	fullscreen_mode = index
	match index:
		0: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		1: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		2: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)

func _on_colorblind_dropdown_item_selected(index: int):
	set_colorblind(index)

func _on_volume_slider_value_changed(value: float):
	set_volume(value)

func _on_fullscreen_item_selected(index: int):
	set_fullscreen(index)

func _on_close_button_pressed():
	_close_menu()

func update_filter_shader():
	if colorblind_mode == 0:
		colorblind_filter.hide()
	else:
		colorblind_filter.show()
		colorblind_filter.material.set_shader_parameter("mode", colorblind_mode)
