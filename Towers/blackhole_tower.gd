extends TowerBase

@export var pull_offset: float = 4000.0
@export var cost: int = 5

@onready var muzzle = $Muzzle
@onready var timer = $Timer

var black_hole_scene = preload("res://Towers/blackhole.tscn")

func _ready():
	super._ready()
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
	
	if target and black_hole_scene:
		var bh = black_hole_scene.instantiate()
		
		var spawn_destination = target.global_position 

		get_tree().current_scene.add_child(bh)
		bh.global_position = muzzle.global_position
		bh.target_pos = spawn_destination
	else:
		timer.stop()

func _on_timer_timeout():
	shoot()
