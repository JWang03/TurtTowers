extends "res://enemies/zombie.gd"

#@export var child_enemy_scene: PackedScene 
@export var spawn_count: int = 6
@export var scatter_range: float = 40.0

var child_enemy_scene = preload("res://enemies/cans.tscn")

func _ready():
	super._ready()
	
	health = 100
	speed = -3.0
	attack_damage = 20

func die():
	spawn_children()
	super.die()

func spawn_children():
	if not child_enemy_scene:
		return
		
	for i in range(spawn_count):
		var can = child_enemy_scene.instantiate()
		get_parent().add_child(can)
		can.global_position = self.global_position
		
		can.is_eating = true 
		
		var random_direction = Vector2(randf_range(-1, 1), randf_range(-0.5, 0.5)).normalized()
		var target_pos = can.global_position + (random_direction * randf_range(20, scatter_range))
		
		var tween = can.create_tween()
		tween.set_parallel(true)
		
		tween.tween_property(can, "global_position", target_pos, 0.3)\
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		
		can.scale = Vector2(0.5, 0.5)
		tween.tween_property(can, "scale", Vector2(1, 1), 0.3)\
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		
		tween.finished.connect(
			func():
				if is_instance_valid(can):
					can.is_eating = false
		)
