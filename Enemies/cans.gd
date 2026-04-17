extends "res://enemies/zombie.gd"

func _ready():
	super._ready()
	
	speed = -55.0
	health = 11.0
	attack_damage = 1
	
	scale = Vector2(0.8, 0.8)
