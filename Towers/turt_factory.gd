extends TowerBase

var turt_scene = preload("res://Towers/turt_mine.tscn")

@export var spawn_interval: float = 0.125
@export var search_radius: float = 120.0 

var path_node: Path2D = null
var spawn_offset: float = 0.0
var factory_active: bool = false

@onready var spawn_timer: Timer = Timer.new()

func _ready():
	super._ready()
	
	path_node = get_tree().get_first_node_in_group("EnemyPath")
	
	add_child(spawn_timer)
	spawn_timer.wait_time = spawn_interval
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)

func _process(_delta):
	if path_node == null:
		path_node = get_tree().get_first_node_in_group("EnemyPath")

	if is_placed and not factory_active and path_node != null:
		if starter and starter.playing:
			calculate_best_spawn_point()
			spawn_timer.start()
			factory_active = true
	
	if factory_active and starter and not starter.playing:
		spawn_timer.stop()
		factory_active = false
	
	if not is_placed and factory_active:
		spawn_timer.stop()
		factory_active = false

func calculate_best_spawn_point():
	if path_node == null:
		return

	var curve = path_node.curve
	var local_pos = path_node.to_local(global_position)
	var closest_offset = curve.get_closest_offset(local_pos)
	var closest_pos = curve.sample_baked(closest_offset)
	var global_closest = path_node.to_global(closest_pos)
	
	if global_closest.distance_to(global_position) <= search_radius:
		spawn_offset = closest_offset
	else:
		factory_active = false
		spawn_timer.stop()
func _on_spawn_timer_timeout():
	if is_placed and path_node and turt_scene:
		if starter and starter.playing:
			spawn_turt()

func spawn_turt():
	var follower = PathFollow2D.new()
	follower.loop = false
	follower.rotates = true
	
	path_node.add_child(follower)
	follower.progress = spawn_offset
	
	var turt = turt_scene.instantiate()
	follower.add_child(turt)
	
	if turt.has_method("set_follower"):
		turt.set_follower(follower)
