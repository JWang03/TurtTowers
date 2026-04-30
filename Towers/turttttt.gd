extends StaticBody2D

@export var attack_damage: float = 5.0
@export var attack_interval: float = 1.0
@export var slow_factor: float = 0.2
@export var cost: float = 30

@onready var starter = get_tree().current_scene.find_child("PlayButton", true, false)
@onready var range_area = $Range
@onready var head = $Head
@onready var attack_timer = $Timer

var is_placed := false
var enemies_in_range: Array = []

func _ready():
	attack_timer.wait_time = attack_interval
	attack_timer.one_shot = false
	range_area.body_entered.connect(_on_body_entered)
	range_area.body_exited.connect(_on_body_exited)
	attack_timer.timeout.connect(_on_attack_timer_timeout)

func _on_body_entered(body):
	if body.is_in_group("zombies"):
		enemies_in_range.append(body)
		if "speed_modifier" in body:
			body.speed_modifier = slow_factor
		if attack_timer.is_stopped():
			attack_timer.start()

func _on_body_exited(body):
	if body.is_in_group("zombies"):
		enemies_in_range.erase(body)
		if is_instance_valid(body) and "speed_modifier" in body:
			body.speed_modifier = 1.0
	if enemies_in_range.is_empty():
		attack_timer.stop()

func _process(_delta):
	if starter.playing and is_placed:
		enemies_in_range = enemies_in_range.filter(func(e): return is_instance_valid(e))
		var target = get_nearest_enemy()
		if target:
			head.look_at(target.global_position)

func _on_attack_timer_timeout():
	if not starter.playing or not is_placed:
		return
	enemies_in_range = enemies_in_range.filter(func(e): return is_instance_valid(e))
	var target = get_nearest_enemy()
	if target and target.has_method("take_damage"):
		target.take_damage(attack_damage)
	if enemies_in_range.is_empty():
		attack_timer.stop()

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
