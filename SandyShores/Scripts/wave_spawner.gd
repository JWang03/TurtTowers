extends Node

@onready var play_button = get_tree().current_scene.find_child("PlayButton", true, false)

@export var enemy_path: Path2D
@export var wave_label: Label

var enemy_bottle = preload("res://enemies/zombie.tscn")
var enemy_algae = preload("res://enemies/algae_bloom.tscn")
var enemy_ring = preload("res://enemies/plastic_ring.tscn")
var enemy_net = preload("res://enemies/fishing_net.tscn")
var enemy_spill = preload("res://enemies/oil_spill.tscn")
var enemy_shield = preload("res://enemies/shield_enemy.tscn")
var cortex = preload("res://enemies/cortex.tscn")

@export var time_between_waves: float = 3.0
@export var max_waves: int = 51

var current_wave: int = 0
var enemies_alive: int = 0
var game_started: bool = false
var wave_running: bool = false
var game_finished: bool = false
var spawning: bool = false

func _process(_delta: float) -> void:
	if enemy_path:
		enemies_alive = enemy_path.get_child_count()
	if game_started or game_finished:
		return
	if play_button and play_button.playing:
		start_game()

func start_game() -> void:
	if game_started:
		return
	game_started = true
	await start_next_wave()

func resume_restored_wave() -> void:
	if game_finished:
		return
	game_started = true
	wave_running = true
	while enemies_alive > 0:
		await get_tree().create_timer(0.5).timeout
	var currency_manager = get_node_or_null("/root/Game/UI/HUD/CurrencyManager")
	if currency_manager:
		currency_manager.add_shellings(get_wave_bonus(current_wave))
	wave_running = false
	await wait_while_unpaused(time_between_waves)
	await start_next_wave()

func get_wave_bonus(wave: int) -> int:
	return 15 + (wave * 7)

func wait_while_unpaused(seconds: float) -> void:
	var elapsed = 0.0
	while elapsed < seconds:
		if play_button and play_button.playing:
			elapsed += 0.1
		await get_tree().create_timer(0.1).timeout

func start_next_wave() -> void:
	if current_wave >= max_waves:
		game_finished = true
		wave_running = false
		if wave_label != null:
			wave_label.text = "All Waves Cleared!"
		return

	current_wave += 1
	wave_running = true

	if wave_label != null:
		wave_label.text = "Wave " + str(current_wave) + " / " + str(max_waves)

	var wave_data = get_wave_data(current_wave)
	spawning = true
	await spawn_wave(wave_data)
	spawning = false

	# wait for all enemies to be cleared
	while enemies_alive > 0:
		await get_tree().create_timer(0.5).timeout

	var currency_manager = get_node_or_null("/root/Game/UI/HUD/CurrencyManager")
	if currency_manager:
		currency_manager.add_shellings(get_wave_bonus(current_wave))

	wave_running = false
	await wait_while_unpaused(time_between_waves)
	await start_next_wave()

func spawn_wave(wave_data: Array) -> void:
	for group in wave_data:
		var scene: PackedScene = group["scene"]
		var count: int = group["count"]
		var delay: float = group["delay"]
		var speed_mult: float = group.get("speed_mult", 1.0)
		var health_mult: float = group.get("health_mult", 1.0)
		var pause_after: float = group.get("pause_after", 0.0)

		for i in range(count):
			spawn_enemy(scene, speed_mult, health_mult)
			await wait_while_unpaused(delay)

		if pause_after > 0.0:
			await wait_while_unpaused(pause_after)

func spawn_enemy(scene: PackedScene, speed_mult: float = 1.0, health_mult: float = 1.0) -> void:
	if scene == null or enemy_path == null:
		return

	var follow := PathFollow2D.new()
	follow.rotates = false
	follow.loop = false
	enemy_path.add_child(follow)

	var enemy = scene.instantiate()
	follow.add_child(enemy)

	follow.progress = 0.0

	enemy.set("wave_manager", self)

	if enemy.get("speed") != null:
		enemy.set("speed", enemy.get("speed") * speed_mult)
	if enemy.get("max_health") != null:
		var base_health = enemy.get("max_health") * health_mult
		enemy.set("max_health", base_health)
		enemy.set("health", base_health)

func enemy_removed() -> void:
	pass # kept for compatibility since enemy scripts still call it

func get_wave_data(wave_num: int) -> Array:
	match wave_num:
		1:
			return [
				{"scene": enemy_bottle, "count": 5, "delay": 0.8, "speed_mult": 1.0, "health_mult": 1.0}
			]
		2:
			return [
				{"scene": enemy_bottle, "count": 10, "delay": 0.75, "speed_mult": 1.05, "health_mult": 1.1}
			]
		3:
			return [
				{"scene": enemy_bottle, "count": 12, "delay": 0.7, "speed_mult": 1.1, "health_mult": 1.2}
			]
		4:
			return [
				{"scene": enemy_bottle, "count": 14, "delay": 0.65, "speed_mult": 1.15, "health_mult": 1.3}
			]
		5:
			return [
				{"scene": enemy_bottle, "count": 16, "delay": 0.6, "speed_mult": 1.2, "health_mult": 1.4}
			]
		6:
			return [
				{"scene": enemy_bottle, "count": 18, "delay": 0.55, "speed_mult": 1.25, "health_mult": 1.5}
			]
		7:
			return [
				{"scene": enemy_bottle, "count": 20, "delay": 0.5, "speed_mult": 1.3, "health_mult": 1.65}
			]
		8:
			return [
				{"scene": enemy_bottle, "count": 22, "delay": 0.5, "speed_mult": 1.35, "health_mult": 1.8}
			]
		9:
			return [
				{"scene": enemy_bottle, "count": 25, "delay": 0.45, "speed_mult": 1.4, "health_mult": 1.95}
			]
		10:
			return [
				{"scene": enemy_bottle, "count": 30, "delay": 0.4, "speed_mult": 1.45, "health_mult": 2.1}
			]
		11:
			return [
				{"scene": enemy_algae, "count": 3, "delay": 1.5, "speed_mult": 1.0, "health_mult": 1.0, "pause_after": 2.0},
				{"scene": enemy_bottle, "count": 15, "delay": 0.5, "speed_mult": 1.45, "health_mult": 2.1}
			]
		12:
			return [
				{"scene": enemy_algae, "count": 2, "delay": 1.2, "speed_mult": 1.05, "health_mult": 1.1, "pause_after": 1.0},
				{"scene": enemy_bottle, "count": 18, "delay": 0.5, "speed_mult": 1.5, "health_mult": 2.2}
			]
		13:
			return [
				{"scene": enemy_algae, "count": 3, "delay": 1.2, "speed_mult": 1.1, "health_mult": 1.2, "pause_after": 0.5},
				{"scene": enemy_bottle, "count": 20, "delay": 0.45, "speed_mult": 1.55, "health_mult": 2.3}
			]
		14:
			return [
				{"scene": enemy_algae, "count": 2, "delay": 1.0, "speed_mult": 1.1, "health_mult": 1.25},
				{"scene": enemy_bottle, "count": 10, "delay": 0.45, "speed_mult": 1.55, "health_mult": 2.3, "pause_after": 0.5},
				{"scene": enemy_algae, "count": 2, "delay": 1.0, "speed_mult": 1.1, "health_mult": 1.25},
				{"scene": enemy_bottle, "count": 10, "delay": 0.45, "speed_mult": 1.55, "health_mult": 2.3}
			]
		15:
			return [
				{"scene": enemy_algae, "count": 4, "delay": 1.0, "speed_mult": 1.15, "health_mult": 1.3, "pause_after": 0.5},
				{"scene": enemy_bottle, "count": 22, "delay": 0.45, "speed_mult": 1.6, "health_mult": 2.4}
			]
		16:
			return [
				{"scene": enemy_algae, "count": 3, "delay": 0.9, "speed_mult": 1.2, "health_mult": 1.4},
				{"scene": enemy_bottle, "count": 12, "delay": 0.4, "speed_mult": 1.65, "health_mult": 2.5, "pause_after": 0.5},
				{"scene": enemy_algae, "count": 3, "delay": 0.9, "speed_mult": 1.2, "health_mult": 1.4},
				{"scene": enemy_bottle, "count": 12, "delay": 0.4, "speed_mult": 1.65, "health_mult": 2.5}
			]
		17:
			return [
				{"scene": enemy_algae, "count": 5, "delay": 0.9, "speed_mult": 1.25, "health_mult": 1.5, "pause_after": 0.5},
				{"scene": enemy_bottle, "count": 25, "delay": 0.4, "speed_mult": 1.7, "health_mult": 2.6}
			]
		18:
			return [
				{"scene": enemy_algae, "count": 6, "delay": 0.85, "speed_mult": 1.3, "health_mult": 1.6, "pause_after": 0.3},
				{"scene": enemy_bottle, "count": 28, "delay": 0.38, "speed_mult": 1.75, "health_mult": 2.7}
			]
		19:
			return [
				{"scene": enemy_algae, "count": 3, "delay": 1.0, "speed_mult": 1.3, "health_mult": 1.6, "pause_after": 1.0},
				{"scene": enemy_ring, "count": 3, "delay": 1.2, "speed_mult": 1.1, "health_mult": 1.3, "pause_after": 0.5},
				{"scene": enemy_bottle, "count": 20, "delay": 0.4, "speed_mult": 1.75, "health_mult": 2.7}
			]
		20:
			return [
				{"scene": enemy_algae, "count": 3, "delay": 1.0, "speed_mult": 1.35, "health_mult": 1.7, "pause_after": 0.5},
				{"scene": enemy_bottle, "count": 15, "delay": 0.4, "speed_mult": 1.8, "health_mult": 2.8},
				{"scene": enemy_ring, "count": 4, "delay": 1.1, "speed_mult": 1.15, "health_mult": 1.4, "pause_after": 0.5},
				{"scene": enemy_bottle, "count": 10, "delay": 0.4, "speed_mult": 1.8, "health_mult": 2.8}
			]
		21:
			return [
				{"scene": enemy_algae, "count": 4, "delay": 0.9, "speed_mult": 1.4, "health_mult": 1.8, "pause_after": 0.5},
				{"scene": enemy_ring, "count": 4, "delay": 1.0, "speed_mult": 1.2, "health_mult": 1.5},
				{"scene": enemy_bottle, "count": 20, "delay": 0.38, "speed_mult": 1.85, "health_mult": 2.9}
			]
		22:
			return [
				{"scene": enemy_ring, "count": 3, "delay": 1.0, "speed_mult": 1.25, "health_mult": 1.6, "pause_after": 0.5},
				{"scene": enemy_algae, "count": 4, "delay": 0.9, "speed_mult": 1.45, "health_mult": 1.9},
				{"scene": enemy_bottle, "count": 22, "delay": 0.38, "speed_mult": 1.9, "health_mult": 3.0}
			]
		23:
			return [
				{"scene": enemy_algae, "count": 5, "delay": 0.9, "speed_mult": 1.5, "health_mult": 2.0, "pause_after": 0.3},
				{"scene": enemy_ring, "count": 5, "delay": 1.0, "speed_mult": 1.3, "health_mult": 1.7},
				{"scene": enemy_bottle, "count": 25, "delay": 0.36, "speed_mult": 1.95, "health_mult": 3.1}
			]
		24:
			return [
				{"scene": enemy_algae, "count": 3, "delay": 0.85, "speed_mult": 1.55, "health_mult": 2.1},
				{"scene": enemy_bottle, "count": 10, "delay": 0.38, "speed_mult": 2.0, "health_mult": 3.2, "pause_after": 0.5},
				{"scene": enemy_ring, "count": 5, "delay": 0.95, "speed_mult": 1.35, "health_mult": 1.8},
				{"scene": enemy_algae, "count": 3, "delay": 0.85, "speed_mult": 1.55, "health_mult": 2.1},
				{"scene": enemy_bottle, "count": 15, "delay": 0.36, "speed_mult": 2.0, "health_mult": 3.2}
			]
		25:
			return [
				{"scene": enemy_algae, "count": 6, "delay": 0.85, "speed_mult": 1.6, "health_mult": 2.2, "pause_after": 0.3},
				{"scene": enemy_ring, "count": 6, "delay": 0.95, "speed_mult": 1.4, "health_mult": 1.9},
				{"scene": enemy_bottle, "count": 28, "delay": 0.35, "speed_mult": 2.05, "health_mult": 3.3}
			]
		26:
			return [
				{"scene": enemy_ring, "count": 5, "delay": 0.9, "speed_mult": 1.45, "health_mult": 2.0, "pause_after": 0.5},
				{"scene": enemy_algae, "count": 6, "delay": 0.8, "speed_mult": 1.65, "health_mult": 2.3, "pause_after": 0.3},
				{"scene": enemy_bottle, "count": 30, "delay": 0.34, "speed_mult": 2.1, "health_mult": 3.4}
			]
		27:
			return [
				{"scene": enemy_net, "count": 2, "delay": 2.0, "speed_mult": 1.0, "health_mult": 1.0, "pause_after": 1.0},
				{"scene": enemy_ring, "count": 5, "delay": 0.9, "speed_mult": 1.5, "health_mult": 2.1, "pause_after": 0.5},
				{"scene": enemy_bottle, "count": 20, "delay": 0.38, "speed_mult": 2.15, "health_mult": 3.5}
			]
		28:
			return [
				{"scene": enemy_net, "count": 2, "delay": 1.8, "speed_mult": 1.05, "health_mult": 1.2, "pause_after": 0.5},
				{"scene": enemy_algae, "count": 4, "delay": 0.85, "speed_mult": 1.65, "health_mult": 2.3},
				{"scene": enemy_ring, "count": 4, "delay": 0.9, "speed_mult": 1.5, "health_mult": 2.1},
				{"scene": enemy_bottle, "count": 22, "delay": 0.36, "speed_mult": 2.2, "health_mult": 3.6}
			]
		29:
			return [
				{"scene": enemy_algae, "count": 4, "delay": 0.85, "speed_mult": 1.7, "health_mult": 2.4, "pause_after": 0.3},
				{"scene": enemy_net, "count": 3, "delay": 1.8, "speed_mult": 1.1, "health_mult": 1.4},
				{"scene": enemy_ring, "count": 5, "delay": 0.9, "speed_mult": 1.55, "health_mult": 2.2},
				{"scene": enemy_bottle, "count": 22, "delay": 0.35, "speed_mult": 2.25, "health_mult": 3.7}
			]
		30:
			return [
				{"scene": enemy_net, "count": 3, "delay": 1.6, "speed_mult": 1.15, "health_mult": 1.6, "pause_after": 0.5},
				{"scene": enemy_algae, "count": 5, "delay": 0.8, "speed_mult": 1.75, "health_mult": 2.5},
				{"scene": enemy_ring, "count": 5, "delay": 0.85, "speed_mult": 1.6, "health_mult": 2.3},
				{"scene": enemy_bottle, "count": 25, "delay": 0.34, "speed_mult": 2.3, "health_mult": 3.8}
			]
		31:
			return [
				{"scene": enemy_algae, "count": 5, "delay": 0.8, "speed_mult": 1.8, "health_mult": 2.6, "pause_after": 0.3},
				{"scene": enemy_net, "count": 3, "delay": 1.6, "speed_mult": 1.2, "health_mult": 1.8},
				{"scene": enemy_bottle, "count": 15, "delay": 0.35, "speed_mult": 2.35, "health_mult": 3.9},
				{"scene": enemy_ring, "count": 6, "delay": 0.85, "speed_mult": 1.65, "health_mult": 2.4},
				{"scene": enemy_bottle, "count": 15, "delay": 0.34, "speed_mult": 2.35, "health_mult": 3.9}
			]
		32:
			return [
				{"scene": enemy_net, "count": 4, "delay": 1.5, "speed_mult": 1.25, "health_mult": 2.0, "pause_after": 0.5},
				{"scene": enemy_algae, "count": 6, "delay": 0.78, "speed_mult": 1.85, "health_mult": 2.7},
				{"scene": enemy_ring, "count": 6, "delay": 0.82, "speed_mult": 1.7, "health_mult": 2.5},
				{"scene": enemy_bottle, "count": 28, "delay": 0.33, "speed_mult": 2.4, "health_mult": 4.0}
			]
		33:
			return [
				{"scene": enemy_algae, "count": 5, "delay": 0.78, "speed_mult": 1.9, "health_mult": 2.8},
				{"scene": enemy_net, "count": 4, "delay": 1.5, "speed_mult": 1.3, "health_mult": 2.2, "pause_after": 0.3},
				{"scene": enemy_ring, "count": 7, "delay": 0.82, "speed_mult": 1.75, "health_mult": 2.6},
				{"scene": enemy_algae, "count": 4, "delay": 0.78, "speed_mult": 1.9, "health_mult": 2.8},
				{"scene": enemy_bottle, "count": 28, "delay": 0.32, "speed_mult": 2.45, "health_mult": 4.1}
			]
		34:
			return [
				{"scene": enemy_net, "count": 5, "delay": 1.4, "speed_mult": 1.35, "health_mult": 2.4, "pause_after": 0.5},
				{"scene": enemy_algae, "count": 7, "delay": 0.75, "speed_mult": 1.95, "health_mult": 2.9},
				{"scene": enemy_ring, "count": 8, "delay": 0.8, "speed_mult": 1.8, "health_mult": 2.7},
				{"scene": enemy_bottle, "count": 30, "delay": 0.32, "speed_mult": 2.5, "health_mult": 4.2}
			]
		35:
			return [
				{"scene": enemy_spill, "count": 3, "delay": 3.0, "speed_mult": 1.0, "health_mult": 1.0, "pause_after": 2.0},
				{"scene": enemy_bottle, "count": 15, "delay": 0.4, "speed_mult": 2.5, "health_mult": 4.3}
			]
		36:
			return [
				{"scene": enemy_spill, "count": 2, "delay": 2.5, "speed_mult": 1.05, "health_mult": 1.2, "pause_after": 0.5},
				{"scene": enemy_algae, "count": 5, "delay": 0.75, "speed_mult": 2.0, "health_mult": 3.0},
				{"scene": enemy_ring, "count": 6, "delay": 0.8, "speed_mult": 1.85, "health_mult": 2.8},
				{"scene": enemy_bottle, "count": 25, "delay": 0.33, "speed_mult": 2.55, "health_mult": 4.4}
			]
		37:
			return [
				{"scene": enemy_algae, "count": 5, "delay": 0.75, "speed_mult": 2.05, "health_mult": 3.1, "pause_after": 0.3},
				{"scene": enemy_spill, "count": 3, "delay": 2.5, "speed_mult": 1.1, "health_mult": 1.4},
				{"scene": enemy_net, "count": 4, "delay": 1.4, "speed_mult": 1.5, "health_mult": 2.5},
				{"scene": enemy_ring, "count": 6, "delay": 0.78, "speed_mult": 1.9, "health_mult": 2.9},
				{"scene": enemy_bottle, "count": 25, "delay": 0.32, "speed_mult": 2.6, "health_mult": 4.5}
			]
		38:
			return [
				{"scene": enemy_spill, "count": 3, "delay": 2.4, "speed_mult": 1.15, "health_mult": 1.6, "pause_after": 0.5},
				{"scene": enemy_algae, "count": 6, "delay": 0.73, "speed_mult": 2.1, "health_mult": 3.2},
				{"scene": enemy_net, "count": 4, "delay": 1.3, "speed_mult": 1.55, "health_mult": 2.6},
				{"scene": enemy_ring, "count": 7, "delay": 0.78, "speed_mult": 1.95, "health_mult": 3.0},
				{"scene": enemy_bottle, "count": 28, "delay": 0.31, "speed_mult": 2.65, "health_mult": 4.6}
			]
		39:
			return [
				{"scene": enemy_algae, "count": 6, "delay": 0.72, "speed_mult": 2.15, "health_mult": 3.3, "pause_after": 0.3},
				{"scene": enemy_spill, "count": 4, "delay": 2.3, "speed_mult": 1.2, "health_mult": 1.8},
				{"scene": enemy_net, "count": 5, "delay": 1.3, "speed_mult": 1.6, "health_mult": 2.7},
				{"scene": enemy_ring, "count": 7, "delay": 0.76, "speed_mult": 2.0, "health_mult": 3.1},
				{"scene": enemy_bottle, "count": 28, "delay": 0.3, "speed_mult": 2.7, "health_mult": 4.8}
			]
		40:
			return [
				{"scene": enemy_spill, "count": 4, "delay": 2.2, "speed_mult": 1.25, "health_mult": 2.0, "pause_after": 0.5},
				{"scene": enemy_algae, "count": 7, "delay": 0.7, "speed_mult": 2.2, "health_mult": 3.5},
				{"scene": enemy_net, "count": 5, "delay": 1.2, "speed_mult": 1.65, "health_mult": 2.8},
				{"scene": enemy_ring, "count": 8, "delay": 0.75, "speed_mult": 2.05, "health_mult": 3.2},
				{"scene": enemy_bottle, "count": 30, "delay": 0.3, "speed_mult": 2.75, "health_mult": 5.0}
			]
		41:
			return [
				{"scene": enemy_algae, "count": 7, "delay": 0.7, "speed_mult": 2.25, "health_mult": 3.7, "pause_after": 0.3},
				{"scene": enemy_spill, "count": 4, "delay": 2.1, "speed_mult": 1.3, "health_mult": 2.2},
				{"scene": enemy_net, "count": 6, "delay": 1.2, "speed_mult": 1.7, "health_mult": 2.9},
				{"scene": enemy_ring, "count": 8, "delay": 0.73, "speed_mult": 2.1, "health_mult": 3.4},
				{"scene": enemy_bottle, "count": 30, "delay": 0.29, "speed_mult": 2.8, "health_mult": 5.2}
			]
		42:
			return [
				{"scene": enemy_spill, "count": 5, "delay": 2.0, "speed_mult": 1.35, "health_mult": 2.4, "pause_after": 0.5},
				{"scene": enemy_algae, "count": 8, "delay": 0.68, "speed_mult": 2.3, "health_mult": 3.9},
				{"scene": enemy_net, "count": 6, "delay": 1.1, "speed_mult": 1.75, "health_mult": 3.0},
				{"scene": enemy_ring, "count": 9, "delay": 0.72, "speed_mult": 2.15, "health_mult": 3.6},
				{"scene": enemy_bottle, "count": 32, "delay": 0.28, "speed_mult": 2.85, "health_mult": 5.4}
			]
		43:
			return [
				{"scene": enemy_algae, "count": 8, "delay": 0.68, "speed_mult": 2.35, "health_mult": 4.1, "pause_after": 0.3},
				{"scene": enemy_spill, "count": 5, "delay": 2.0, "speed_mult": 1.4, "health_mult": 2.6},
				{"scene": enemy_net, "count": 7, "delay": 1.1, "speed_mult": 1.8, "health_mult": 3.1},
				{"scene": enemy_ring, "count": 9, "delay": 0.7, "speed_mult": 2.2, "health_mult": 3.8},
				{"scene": enemy_bottle, "count": 32, "delay": 0.27, "speed_mult": 2.9, "health_mult": 5.6}
			]
		44:
			return [
				{"scene": enemy_spill, "count": 6, "delay": 1.9, "speed_mult": 1.45, "health_mult": 2.8, "pause_after": 0.5},
				{"scene": enemy_algae, "count": 9, "delay": 0.65, "speed_mult": 2.4, "health_mult": 4.3},
				{"scene": enemy_net, "count": 7, "delay": 1.0, "speed_mult": 1.85, "health_mult": 3.2},
				{"scene": enemy_ring, "count": 10, "delay": 0.7, "speed_mult": 2.25, "health_mult": 4.0},
				{"scene": enemy_bottle, "count": 35, "delay": 0.26, "speed_mult": 2.95, "health_mult": 5.8}
			]
		45:
			return [
				{"scene": enemy_algae, "count": 10, "delay": 0.65, "speed_mult": 2.45, "health_mult": 4.5, "pause_after": 0.3},
				{"scene": enemy_spill, "count": 6, "delay": 1.8, "speed_mult": 1.5, "health_mult": 3.0},
				{"scene": enemy_net, "count": 8, "delay": 1.0, "speed_mult": 1.9, "health_mult": 3.4},
				{"scene": enemy_ring, "count": 10, "delay": 0.68, "speed_mult": 2.3, "health_mult": 4.2},
				{"scene": enemy_bottle, "count": 35, "delay": 0.25, "speed_mult": 3.0, "health_mult": 6.0}
			]
		46:
			return [
				{"scene": enemy_shield, "count": 2, "delay": 2.0, "speed_mult": 1.0, "health_mult": 1.2, "pause_after": 0.5},
				{"scene": enemy_spill, "count": 5, "delay": 1.8, "speed_mult": 1.55, "health_mult": 3.2},
				{"scene": enemy_algae, "count": 8, "delay": 0.65, "speed_mult": 2.5, "health_mult": 4.7},
				{"scene": enemy_net, "count": 6, "delay": 1.0, "speed_mult": 1.95, "health_mult": 3.6},
				{"scene": enemy_ring, "count": 8, "delay": 0.68, "speed_mult": 2.35, "health_mult": 4.4},
				{"scene": enemy_bottle, "count": 30, "delay": 0.26, "speed_mult": 3.05, "health_mult": 6.2}
			]
		47:
			return [
				{"scene": enemy_shield, "count": 3, "delay": 1.8, "speed_mult": 1.05, "health_mult": 1.4, "pause_after": 0.3},
				{"scene": enemy_algae, "count": 8, "delay": 0.63, "speed_mult": 2.55, "health_mult": 4.9},
				{"scene": enemy_shield, "count": 2, "delay": 1.8, "speed_mult": 1.05, "health_mult": 1.4},
				{"scene": enemy_spill, "count": 6, "delay": 1.8, "speed_mult": 1.6, "health_mult": 3.4},
				{"scene": enemy_net, "count": 7, "delay": 1.0, "speed_mult": 2.0, "health_mult": 3.8},
				{"scene": enemy_ring, "count": 9, "delay": 0.66, "speed_mult": 2.4, "health_mult": 4.6},
				{"scene": enemy_bottle, "count": 32, "delay": 0.25, "speed_mult": 3.1, "health_mult": 6.5}
			]
		48:
			return [
				{"scene": enemy_shield, "count": 3, "delay": 1.7, "speed_mult": 1.1, "health_mult": 1.6, "pause_after": 0.3},
				{"scene": enemy_spill, "count": 6, "delay": 1.7, "speed_mult": 1.65, "health_mult": 3.6},
				{"scene": enemy_shield, "count": 2, "delay": 1.7, "speed_mult": 1.1, "health_mult": 1.6},
				{"scene": enemy_algae, "count": 9, "delay": 0.62, "speed_mult": 2.6, "health_mult": 5.1},
				{"scene": enemy_net, "count": 7, "delay": 0.95, "speed_mult": 2.05, "health_mult": 4.0},
				{"scene": enemy_ring, "count": 10, "delay": 0.65, "speed_mult": 2.45, "health_mult": 4.8},
				{"scene": enemy_bottle, "count": 34, "delay": 0.24, "speed_mult": 3.15, "health_mult": 6.8}
			]
		49:
			return [
				{"scene": enemy_shield, "count": 4, "delay": 1.6, "speed_mult": 1.15, "health_mult": 1.8, "pause_after": 0.3},
				{"scene": enemy_algae, "count": 10, "delay": 0.6, "speed_mult": 2.65, "health_mult": 5.3},
				{"scene": enemy_shield, "count": 3, "delay": 1.6, "speed_mult": 1.15, "health_mult": 1.8},
				{"scene": enemy_spill, "count": 7, "delay": 1.6, "speed_mult": 1.7, "health_mult": 3.8},
				{"scene": enemy_net, "count": 8, "delay": 0.95, "speed_mult": 2.1, "health_mult": 4.2},
				{"scene": enemy_ring, "count": 10, "delay": 0.63, "speed_mult": 2.5, "health_mult": 5.0},
				{"scene": enemy_bottle, "count": 35, "delay": 0.23, "speed_mult": 3.2, "health_mult": 7.0}
			]
		50:
			return [
				{"scene": enemy_shield, "count": 5, "delay": 1.5, "speed_mult": 1.2, "health_mult": 2.0, "pause_after": 0.5},
				{"scene": enemy_spill, "count": 8, "delay": 1.5, "speed_mult": 1.75, "health_mult": 4.0, "pause_after": 0.3},
				{"scene": enemy_shield, "count": 4, "delay": 1.5, "speed_mult": 1.2, "health_mult": 2.0},
				{"scene": enemy_algae, "count": 12, "delay": 0.55, "speed_mult": 2.7, "health_mult": 5.5, "pause_after": 0.3},
				{"scene": enemy_net, "count": 10, "delay": 0.9, "speed_mult": 2.15, "health_mult": 4.5},
				{"scene": enemy_shield, "count": 4, "delay": 1.5, "speed_mult": 1.2, "health_mult": 2.0},
				{"scene": enemy_ring, "count": 12, "delay": 0.6, "speed_mult": 2.55, "health_mult": 5.2},
				{"scene": enemy_shield, "count": 3, "delay": 1.5, "speed_mult": 1.2, "health_mult": 2.0},
				{"scene": enemy_bottle, "count": 40, "delay": 0.2, "speed_mult": 3.3, "health_mult": 8.0}
			]
		51:
			return [
				{"scene": cortex, "count": 1, "delay": 1.5, "speed_mult": 1, "health_mult": 1},
				{"scene": enemy_net, "count": 10, "delay": 1.5, "speed_mult": 3, "health_mult": 12},
				{"scene": enemy_shield, "count": 5, "delay": 0.2, "speed_mult": 3, "health_mult": 5},
				{"scene": enemy_spill, "count": 20, "delay": 0.5, "speed_mult": 3, "health_mult": 4}
			]
		_:
			return []
