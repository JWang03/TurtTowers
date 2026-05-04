extends TowerBase

@onready var muzzle = $Muzzle
@onready var timer = $Timer
@export var cost: float = 25

var bomb_scene = preload("res://Towers/bomb.tscn")

func _ready():
	super._ready()
	fire_rate = 2.0
	timer.wait_time = fire_rate
	timer.timeout.connect(_on_timer_timeout)
	detection_area.body_entered.connect(_on_zombie_entered)

func _on_zombie_entered(body):
	if body.is_in_group("zombies") and timer.is_stopped():
		shoot()
		timer.start()

func shoot():
	if not is_placed or not starter or not starter.playing:
		timer.stop()
		return

	var target = get_best_target()
	
	if target and bomb_scene:
		var shield_provider = get_shield_provider(target)
		var final_target = shield_provider if shield_provider else target

		var bomb = bomb_scene.instantiate()
		get_tree().current_scene.add_child(bomb)

		bomb.global_position = muzzle.global_position
		bomb.target_pos = final_target.global_position
	else:
		timer.stop()

func _on_timer_timeout():
	shoot()
