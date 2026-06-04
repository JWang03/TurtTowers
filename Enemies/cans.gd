extends "res://enemies/zombie.gd"
func _ready():
	super._ready()
	
	speed_modifier = 1.0
	speed = 200.0
	health = 50.0
	attack_damage = 1
	
	scale = Vector2(0.8, 0.8)
