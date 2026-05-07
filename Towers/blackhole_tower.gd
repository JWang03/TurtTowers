extends TowerBase

@onready var muzzle = $Muzzle
@onready var timer = $Timer

var black_hole_scene = preload("res://Towers/blackhole.tscn")

@export var cost: float = 25.0
@export var lead_distance: float = 60.0

func _ready():
	super._ready()
	fire_rate = 4.0 
	timer.wait_time = fire_rate
	timer.one_shot = false
	timer.timeout.connect(_on_timer_timeout)
	detection_area.body_entered.connect(_on_zombie_entered)

func _on_zombie_entered(body):
	if body.is_in_group("zombies") and timer.is_stopped():
		attempt_shot()
		timer.start()

func _on_timer_timeout():
	if detection_area.has_overlapping_bodies():
		attempt_shot()
	else:
		timer.stop()

func attempt_shot():
	if not is_placed or not starter or not starter.playing:
		timer.stop()
		return

	var target = get_best_target()
	
	if target:
		var bh = black_hole_scene.instantiate()
		
		var follower = get_path_follower(target)
		if follower:
			var path = follower.get_parent()
			var future_progress = follower.progress + lead_distance
			future_progress = min(future_progress, path.curve.get_baked_length())
			
			var local_future_pos = path.curve.sample_baked(future_progress)
			bh.target_pos = path.to_global(local_future_pos)
		else:
			bh.target_pos = target.global_position
		
		get_tree().current_scene.add_child(bh)
		bh.global_position = muzzle.global_position
	else:
		timer.stop()

func get_path_follower(node: Node) -> PathFollow2D:
	var current = node
	while current != null:
		if current is PathFollow2D:
			return current
		current = current.get_parent()
	return null
