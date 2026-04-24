extends "res://enemies/zombie.gd"

var buff_scene = preload("res://enemies/buff_range.tscn")

func _ready():
	super._ready()
	
	speed = 5.0
	health = 40
	attack_damage = 5.0

func die():
	spawn_buff()
	super.die()

func spawn_buff():
	if not buff_scene:
		return
	
	var buff = buff_scene.instantiate()
	buff.global_position = self.global_position
	get_parent().add_child(buff)
