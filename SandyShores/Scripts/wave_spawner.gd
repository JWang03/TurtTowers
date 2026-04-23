extends Node

@onready var play_button = get_node("/root/Game/UI/Start_Pause/PlayButton")

@export var enemy_path: Path2D
@export var wave_label: Label

@export var enemy1: PackedScene
@export var enemy2: PackedScene
@export var enemy3: PackedScene

@export var time_between_waves: float = 2.0
@export var max_waves: int = 10

var current_wave: int = 0
var enemies_alive: int = 0
var game_started: bool = false
var wave_running: bool = false
var game_finished: bool = false


func _process(delta: float) -> void:
	if play_button.playing and not game_started and not game_finished:
		start_game()


func start_game() -> void:
	if game_started:
		return
	
	game_started = true
	await start_next_wave()


func start_next_wave() -> void:
	if current_wave >= max_waves:
		game_finished = true
		wave_running = false
		print("All waves cleared!")
		if wave_label != null:
			wave_label.text = "All Waves Cleared!"
		return
	
	current_wave += 1
	wave_running = true
	
	if wave_label != null:
		wave_label.text = "Wave " + str(current_wave) + " / " + str(max_waves)
	
	print("Starting wave ", current_wave)
	
	var wave_data = get_wave_data(current_wave)
	await spawn_wave(wave_data)
	
	# Wait until every enemy from this wave is dead/despawned
	while enemies_alive > 0:
		await get_tree().process_frame
	
	print("Wave ", current_wave, " cleared")
	wave_running = false
	
	await get_tree().create_timer(time_between_waves).timeout
	await start_next_wave()


func spawn_wave(wave_data: Array) -> void:
	for enemy_info in wave_data:
		var scene: PackedScene = enemy_info["scene"]
		var count: int = enemy_info["count"]
		var delay: float = enemy_info["delay"]
		var speed_mult: float = enemy_info["speed_mult"]
		
		for i in range(count):
			spawn_enemy(scene, speed_mult)
			await get_tree().create_timer(delay).timeout


func spawn_enemy(scene: PackedScene, speed_mult: float = 1.0) -> void:
	if scene == null or enemy_path == null:
		return
	
	var follow := PathFollow2D.new()
	follow.rotates = false
	follow.loop = false
	enemy_path.add_child(follow)
	
	var enemy = scene.instantiate()
	follow.add_child(enemy)
	
	follow.progress = 0.0
	enemies_alive += 1
	
	# Give the enemy a reference back to this manager
	# In your enemy script, make a variable called:
	# var wave_manager = null
	enemy.set("wave_manager", self)
	
	# Multiply enemy speed if that variable exists in the enemy scene
	# In your enemy script, make sure there is a speed variable
	if enemy.get("speed") != null:
		enemy.set("speed", enemy.get("speed") * speed_mult)


func enemy_removed() -> void:
	enemies_alive -= 1
	
	if enemies_alive < 0:
		enemies_alive = 0
	
	print("Enemies alive: ", enemies_alive)


func get_wave_data(wave_num: int) -> Array:
	match wave_num:
		1:
			return [
				{"scene": enemy1, "count": 5, "delay": 1.0, "speed_mult": 1.0}
			]
		2:
			return [
				{"scene": enemy1, "count": 7, "delay": 0.8, "speed_mult": 1.1}
			]
		3:
			return [
				{"scene": enemy1, "count": 20, "delay": 0.4, "speed_mult": 1.2}
			]
		4:
			return [
				{"scene": enemy1, "count": 8, "delay": 0.75, "speed_mult": 1.2},
				{"scene": enemy2, "count": 2, "delay": 1.0, "speed_mult": 1.0}
			]
		5:
			return [
				{"scene": enemy1, "count": 10, "delay": 0.7, "speed_mult": 1.2},
				{"scene": enemy2, "count": 4, "delay": 0.9, "speed_mult": 1.05}
			]
		6:
			return [
				{"scene": enemy1, "count": 12, "delay": 0.65, "speed_mult": 1.25},
				{"scene": enemy2, "count": 5, "delay": 0.85, "speed_mult": 1.1}
			]
		7:
			return [
				{"scene": enemy1, "count": 10, "delay": 0.6, "speed_mult": 1.3},
				{"scene": enemy2, "count": 8, "delay": 0.75, "speed_mult": 1.15}
			]
		8:
			return [
				{"scene": enemy1, "count": 12, "delay": 0.55, "speed_mult": 1.35},
				{"scene": enemy2, "count": 10, "delay": 0.7, "speed_mult": 1.2}
			]
		9:
			return [
				{"scene": enemy1, "count": 15, "delay": 0.5, "speed_mult": 1.4},
				{"scene": enemy2, "count": 10, "delay": 0.65, "speed_mult": 1.25},
				{"scene": enemy3, "count": 2, "delay": 1.2, "speed_mult": 1.0}
			]
		10:
			return [
				{"scene": enemy1, "count": 20, "delay": 0.45, "speed_mult": 1.5},
				{"scene": enemy2, "count": 12, "delay": 0.6, "speed_mult": 1.3},
				{"scene": enemy3, "count": 4, "delay": 1.0, "speed_mult": 1.1}
			]
		_:
			return []
