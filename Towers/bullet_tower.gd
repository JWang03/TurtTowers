extends TowerBase

@onready var muzzle = $Muzzle
@onready var timer = $Timer
var bullet_scene = preload("res://Towers/bullet.tscn")

@export var cost: float = 5.0

func _ready():
	super._ready()
	fire_rate = 0.2
	timer.wait_time = fire_rate
	timer.one_shot = false
	timer.timeout.connect(_on_timer_timeout)
	detection_area.body_entered.connect(_on_zombie_entered)

func _on_zombie_entered(body):
	if body.is_in_group("zombies"):
		if timer.is_stopped():
			attempt_shot()
			timer.start()

func _on_timer_timeout():
	attempt_shot()
	if detection_area.has_overlapping_bodies():
		if timer.is_stopped():
			timer.start()
	else:
		timer.stop()

func attempt_shot():
	if not is_placed or not starter or not starter.playing:
		timer.stop()
		return

	var target = get_best_target()
	
	if target:
		var shield_provider = get_shield_provider(target)
		var final_target = shield_provider if shield_provider else target
		var bullet = bullet_scene.instantiate()
		get_tree().current_scene.add_child(bullet)
		bullet.global_position = muzzle.global_position
		bullet.look_at(final_target.global_position)
		if bullet.has_method("set_hit_target"):
			bullet.set_hit_target(final_target)
	else:
		timer.stop()
