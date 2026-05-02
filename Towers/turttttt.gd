extends StaticBody2D

@export var attack_damage: float = 5.0
@export var slow_factor: float = 0.2
@export var cost: float = 30

@onready var starter = get_tree().current_scene.find_child("PlayButton", true, false)
@onready var range_area = $Range
@onready var anim_sprite = $AnimatedSprite2D

var is_placed := false
var enemies_in_range: Array = []
var current_slow_target = null

func _ready():
	range_area.body_entered.connect(_on_body_entered)
	range_area.body_exited.connect(_on_body_exited)
	# Fire the attack at the end of each animation loop so the hit lines up with the animation
	anim_sprite.animation_looped.connect(_on_animation_looped)
	anim_sprite.stop()

func _on_body_entered(body):
	if body.is_in_group("zombies"):
		enemies_in_range.append(body)
		if is_placed and starter.playing and not anim_sprite.is_playing():
			anim_sprite.play()

func _on_body_exited(body):
	if body.is_in_group("zombies"):
		enemies_in_range.erase(body)
		if body == current_slow_target:
			clear_slow_effect(body)
			current_slow_target = null
	if enemies_in_range.is_empty():
		anim_sprite.stop()

func _process(_delta):
	if is_placed and starter.playing:
		enemies_in_range = enemies_in_range.filter(func(e): return is_instance_valid(e))
		if enemies_in_range.is_empty():
			anim_sprite.stop()
		elif not anim_sprite.is_playing():
			anim_sprite.play()

# Called at the end of each animation loop — this is when the hit lands
func _on_animation_looped():
	if not starter.playing or not is_placed:
		return
	enemies_in_range = enemies_in_range.filter(func(e): return is_instance_valid(e))
	var target = get_nearest_enemy()
	if target:
		_apply_hit(target)
	if enemies_in_range.is_empty():
		anim_sprite.stop()

func _apply_hit(target):
	if not is_instance_valid(target):
		return
	if target.has_method("take_damage"):
		target.take_damage(attack_damage)
	if current_slow_target and current_slow_target != target and is_instance_valid(current_slow_target):
		clear_slow_effect(current_slow_target)
	current_slow_target = target
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
