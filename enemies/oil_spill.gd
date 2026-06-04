extends "res://enemies/zombie.gd"
  # override before _ready fires

func _ready():
	super._ready()
	max_health = 2000
	speed = 30.0
	attack_damage = 15
	shelling_drop = 15
	
	
