extends "res://enemies/zombie.gd"

var buff_scene = preload("res://enemies/buff_range.tscn")
var speed_modifier: float = 1.0
func _ready():
	super._ready()
	
	speed = 50.0
	health = 30.0
	attack_damage = 5.0

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
				loss_conditions.spend_lives(damage)
func take_damage(amount):
	health -= amount
	modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	modulate = Color.WHITE
	
	if health <= 0:
		die()

func die():
	currency.add_shellings(2)
	if wave_manager != null:
		wave_manager.enemy_removed()

	spawn_buff()
	queue_free()


func spawn_buff():
	if buff_scene == null:
		return
	
	var buff = buff_scene.instantiate()
	buff.global_position = global_position
	
	get_tree().current_scene.add_child(buff)
