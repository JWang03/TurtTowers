extends Node

var lives = 1
@onready var label = $"../Lives/LivesLabel"

func update_label():
	label.text = str(lives)

func _ready():
	update_label()

func add_lives(amount: int):
	lives += amount
	update_label()

func spend_lives(amount: int):
	lives -= amount
	var run_stats := get_node_or_null("/root/RunStats")
	if run_stats:
		run_stats.record_lives_lost(amount)
	update_label()
	if lives <= 0:
		lives = 0
		update_label()
		_trigger_defeat()

func _trigger_defeat():
	var defeat_screen := get_node_or_null("/root/DefeatScreen")
	if not defeat_screen or not defeat_screen.has_method("show_defeat"):
		return
	var scene_path = get_tree().current_scene.scene_file_path
	var stats = {}
	var run_stats := get_node_or_null("/root/RunStats")
	if run_stats:
		stats = run_stats.get_report()
	# add wave reached from wave spawner
	var wave_spawner = get_tree().current_scene.find_child("WaveSpawner", true, false)
	if wave_spawner:
		stats["wave_reached"] = wave_spawner.get("current_wave")
	defeat_screen.show_defeat(scene_path, stats)

func is_alive(lives):
	if lives <= 0:
		return false
	else:
		return true
