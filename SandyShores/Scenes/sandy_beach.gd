extends Node2D

func _ready():
	# small delay so autosave can restore first
	await get_tree().process_frame
	await get_tree().process_frame
	_check_intro()

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
