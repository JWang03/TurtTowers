extends Node

const NUKE_SCENE_PATH := "res://Towers/nuke.tscn"

var scene_path := ""
var towers_placed := 0
var cash_generated := 0
var turtory_bombs_used := 0
var lives_lost := 0
var _start_ticks_msec := 0
var _saved_runtime_msec := 0

func reset_for_scene(new_scene_path: String = "") -> void:
	scene_path = new_scene_path
	towers_placed = 0
	cash_generated = 0
	turtory_bombs_used = 0
	lives_lost = 0
	_saved_runtime_msec = 0
	_start_ticks_msec = Time.get_ticks_msec()

func record_tower_placed(tower_scene_path: String) -> void:
	if tower_scene_path == NUKE_SCENE_PATH:
		turtory_bombs_used += 1
		return
	towers_placed += 1

func record_cash_generated(amount: int) -> void:
	if amount > 0:
		cash_generated += amount

func record_lives_lost(amount: int) -> void:
	if amount > 0:
		lives_lost += amount

func get_runtime_seconds() -> int:
	if _start_ticks_msec <= 0:
		return int(round(float(_saved_runtime_msec) / 1000.0))
	return int(round(float(_saved_runtime_msec + Time.get_ticks_msec() - _start_ticks_msec) / 1000.0))

func get_report() -> Dictionary:
	return {
		"towers_placed": towers_placed,
		"cash_generated": cash_generated,
		"turtory_bombs_used": turtory_bombs_used,
		"lives_lost": lives_lost,
		"runtime_seconds": get_runtime_seconds()
	}

func get_save_data() -> Dictionary:
	var data := get_report()
	data["scene_path"] = scene_path
	return data

func restore_from_save(data: Dictionary) -> void:
	scene_path = str(data.get("scene_path", scene_path))
	towers_placed = int(data.get("towers_placed", 0))
	cash_generated = int(data.get("cash_generated", 0))
	turtory_bombs_used = int(data.get("turtory_bombs_used", 0))
	lives_lost = int(data.get("lives_lost", 0))
	_saved_runtime_msec = int(data.get("runtime_seconds", 0)) * 1000
	_start_ticks_msec = Time.get_ticks_msec()

func format_runtime(seconds: int) -> String:
	var minutes := seconds / 60
	var remaining_seconds := seconds % 60
	return "%02d:%02d" % [minutes, remaining_seconds]
