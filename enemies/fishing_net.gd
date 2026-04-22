extends "res://enemies/original_zombie.gd"

@export var stealth_alpha: float = 0.2
@export var stealth_duration: float = 2
@export var visible_duration: float = 3

var is_stealth: bool = false

func _ready():
	super._ready()
	health = 60
	speed = 15
	
	start_stealth_loop()

func start_stealth_loop():
	var tween = create_tween().set_loops()
	
	tween.tween_callback(set_stealth.bind(true))
	tween.tween_property(self, "modulate:a", stealth_alpha, 0.5).set_trans(Tween.TRANS_SINE)
	tween.tween_interval(stealth_duration)
	
	tween.tween_callback(set_stealth.bind(false))
	tween.tween_property(self, "modulate:a", 1.0, 0.5).set_trans(Tween.TRANS_SINE)
	tween.tween_interval(visible_duration)

func set_stealth(value: bool):
	is_stealth = value
	var pulse = create_tween()
	pulse.tween_property(self, "scale", Vector2(1.1, 1.1), 0.1)
	pulse.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)
