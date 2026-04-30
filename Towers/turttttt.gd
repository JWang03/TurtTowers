extends StaticBody2D

@export var attack_damage: float = 5.0
@export var attack_interval: float = 1.0
@export var slow_factor: float = 0.2
@export var cost: float = 30

@onready var starter = get_tree().current_scene.find_child("PlayButton", true, false)
@onready var range_area = $Range
@onready var bat_pivot = $BatPivot
@onready var attack_timer = $Timer

const BAT_REST_ROTATION: float = -0.8
const BAT_SWING_ROTATION: float = 0.8

var is_placed := false
var enemies_in_range: Array = []
var current_slow_target = null
var bat_swinging := false

func _ready():
	attack_timer.wait_time = attack_interval
	attack_timer.one_shot = false
	range_area.body_entered.connect(_on_body_entered)
	range_area.body_exited.connect(_on_body_exited)
	attack_timer.timeout.connect(_on_attack_timer_timeout)
	bat_pivot.rotation = BAT_REST_ROTATION

func _on_body_entered(body):
	if body.is_in_group("zombies"):
		enemies_in_range.append(body)
		if attack_timer.is_stopped():
			attack_timer.start()

func _on_body_exited(body):
	if body.is_in_group("zombies"):
		enemies_in_range.erase(body)
		if body == current_slow_target:
			clear_slow_effect(body)
			current_slow_target = null
	if enemies_in_range.is_empty():
		attack_timer.stop()

func _process(_delta):
	if starter.playing and is_placed:
		enemies_in_range = enemies_in_range.filter(func(e): return is_instance_valid(e))

func _on_attack_timer_timeout():
	if not starter.playing or not is_placed:
		return
	enemies_in_range = enemies_in_range.filter(func(e): return is_instance_valid(e))
	var target = get_nearest_enemy()
	if target:
		swing_bat(target)
	if enemies_in_range.is_empty():
		attack_timer.stop()

func swing_bat(target):
	if bat_swinging:
		return
	bat_swinging = true
	if current_slow_target and current_slow_target != target:
		clear_slow_effect(current_slow_target)
	current_slow_target = target
	var tween = create_tween()
	tween.tween_property(bat_pivot, "rotation", BAT_SWING_ROTATION, 0.15)
	tween.tween_callback(_apply_hit.bind(target))
	tween.tween_property(bat_pivot, "rotation", BAT_REST_ROTATION, 0.2)
	tween.tween_callback(func(): bat_swinging = false)
	tween.finished.connect(func(): bat_swinging = false)

func _apply_hit(target):
	if not is_instance_valid(target):
		return
	if target.has_method("take_damage"):
		target.take_damage(attack_damage)
	if "speed_modifier" in target:
		target.speed_modifier = slow_factor

func clear_slow_effect(target):
	if is_instance_valid(target) and "speed_modifier" in target:
		target.speed_modifier = 1.0

func get_nearest_enemy():
	var nearest = null
	var min_dist = INF
	for enemy in enemies_in_range:
		if is_instance_valid(enemy):
			var dist = global_position.distance_to(enemy.global_position)
			if dist < min_dist:
				min_dist = dist
				nearest = enemy
	return nearest
