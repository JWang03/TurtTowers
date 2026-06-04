extends "res://enemies/zombie.gd"

@export var stealth_alpha: float = 0.2
@export var stealth_duration: float = 2
@export var visible_duration: float = 3

var is_stealth: bool = false

func _ready():
	super._ready()
	health = 300
	speed = 200.0
	shelling_drop = 10
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

func take_damage(amount):
	health -= amount * damage_taken_multiplier
	
	if health_bar:
		health_bar.update(health, max_health)
		
	modulate = Color(2.0, 0.5, 0.5, stealth_alpha if is_stealth else 1.0)
	await get_tree().create_timer(0.1).timeout
	
	if is_stealth:
		modulate = Color(1, 1, 1, stealth_alpha)
	else:
		modulate = Color.WHITE

	if health <= 0:
		die()
