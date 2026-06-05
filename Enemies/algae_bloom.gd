extends "res://enemies/zombie.gd"

var buff_scene = preload("res://enemies/buff_area.tscn")

func _ready():
	super._ready()
	speed = 125.0
	health = 40
	attack_damage = 5.0
	shelling_drop = 8

func _process(delta):
	if is_dead:
		return
	if starter.playing == true:
		var follow = get_parent()
		if follow is PathFollow2D:
			follow.progress += speed * delta * speed_modifier
			var path_length = follow.get_parent().curve.get_baked_length()
			if follow.progress >= path_length:
				is_dead = true
				follow.queue_free()
				if wave_manager != null:
					wave_manager.enemy_removed()
				loss_conditions.spend_lives(damage)

func take_damage(amount):
	if is_dead:
		return
	health -= amount
	health_bar.update(health, max_health)
	modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	if not is_instance_valid(self):
		return
	modulate = Color.WHITE
	if health <= 0:
		die()

func die():
	if is_dead:
		return
	is_dead = true
	currency.add_shellings(shelling_drop)
	if wave_manager != null:
		wave_manager.enemy_removed()
	spawn_buff()
	var follow = get_parent()
	if follow is PathFollow2D:
		follow.queue_free()
	else:
		queue_free()

func spawn_buff():
	if buff_scene == null:
		return
	var buff = buff_scene.instantiate()
	buff.global_position = global_position
	get_tree().current_scene.add_child(buff)
