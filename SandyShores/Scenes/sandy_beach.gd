extends Node2D

const DEBUG_SKIP_CASH := 100000
const DEBUG_TARGET_WAVE := 51

func _ready():
	_add_debug_skip_button()

	var run_stats := get_node_or_null("/root/RunStats")
	if run_stats:
		run_stats.reset_for_scene(scene_file_path)
		
	await get_tree().process_frame
	await get_tree().process_frame
	_check_intro()

func _add_debug_skip_button() -> void:
	var debug_layer := CanvasLayer.new()
	debug_layer.name = "SandyShoresDebugLayer"
	debug_layer.layer = 100
	add_child(debug_layer)

	var button := Button.new()
	button.name = "SkipToWave51Button"
	button.text = "Debug W51 +100K"
	button.custom_minimum_size = Vector2(160, 40)
	button.anchor_left = 1.0
	button.anchor_right = 1.0
	button.offset_left = -172.0
	button.offset_top = 12.0
	button.offset_right = -12.0
	button.offset_bottom = 52.0
	button.pressed.connect(_on_debug_skip_pressed)
	debug_layer.add_child(button)

func _on_debug_skip_pressed() -> void:
	var currency_manager = get_node_or_null("/root/Game/UI/HUD/CurrencyManager")
	if currency_manager:
		currency_manager.add_shellings(DEBUG_SKIP_CASH, false)

	var wave_spawner = get_node_or_null("/root/Game/WaveSpawner")
	if wave_spawner and wave_spawner.has_method("debug_skip_to_wave"):
		wave_spawner.debug_skip_to_wave(DEBUG_TARGET_WAVE)

func _check_intro():
	var wave_spawner = get_node("/root/Game/WaveSpawner")
	var is_fresh_start = true
	
	if wave_spawner:
		var current_wave = wave_spawner.get("current_wave")
		var game_started = wave_spawner.get("game_started")
		if current_wave > 0 or game_started:
			is_fresh_start = false
	
	if is_fresh_start:
		IntroScreen.show_intro()
	else:
		# game was restored from save, just spawn the ? button
		IntroScreen.spawn_info_button_only()
