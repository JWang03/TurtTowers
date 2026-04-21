extends "res://enemies/zombie.gd"
var speed_modifier
func _ready():
	super._ready()
	
	speed_modifier = 1.0
	speed = 40.0
	health = 11.0
	attack_damage = 1
	
	scale = Vector2(0.8, 0.8)
