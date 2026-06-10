extends "res://enemies/zombie.gd"

@export var spawn_count: int = 6
@export var scatter_range: float = 40.0
var child_enemy_scene = preload("res://enemies/cans.tscn")

func _ready():
	super._ready()
	
	max_health = 400
	speed = 40.0
	attack_damage = 20
	shelling_drop = 6
func _process(delta):
	if starter.playing == true:
		var follow = get_parent()
		if follow is PathFollow2D:
			follow.progress += speed * delta * speed_modifier
		
			var path_length = follow.get_parent().curve.get_baked_length()
			if follow.progress >= path_length:
				follow.queue_free()
				if wave_manager != null:
					wave_manager.enemy_removed()
				loss_conditions.spend_lives(attack_damage)

func die():
	spawn_children()
	super.die()
func take_damage(amount):
	super.take_damage(amount)
func spawn_children():
	if child_enemy_scene == null:
		return

	var parent_follow = get_parent()
	if parent_follow == null or not (parent_follow is PathFollow2D):
		return

	var path = parent_follow.get_parent()
	if path == null or not (path is Path2D):
		return

	var death_progress = parent_follow.progress

	for i in range(spawn_count):
		var new_follow = PathFollow2D.new()
		new_follow.loop = false
		path.add_child(new_follow)
		new_follow.progress = death_progress + i * 8.0

		var can = child_enemy_scene.instantiate()
		new_follow.add_child(can)

		# register each can with the wave manager
		can.set("WaveSpawner", wave_manager)
		if wave_manager != null:
			wave_manager.enemies_alive += 1

		can.scale = Vector2(0.5, 0.5)
		var tween = can.create_tween()
		tween.tween_property(can, "scale", Vector2(1, 1), 0.3)\
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
