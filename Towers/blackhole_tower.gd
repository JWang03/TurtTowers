extends StaticBody2D

#@export var black_hole_scene: PackedScene
@export var fire_rate: float = 3.0
@export var pull_offset: float = 80.0

@onready var muzzle = $Muzzle
@onready var timer = $Timer
@onready var detection_area = $Range

var targets_in_range: Array = []

var black_hole_scene = preload("res://Towers/blackhole.tscn")

func _ready():
	timer.wait_time = fire_rate
	detection_area.body_entered.connect(_on_zombie_entered)
	detection_area.body_exited.connect(_on_zombie_exited)
	timer.timeout.connect(_on_timer_timeout)

func _on_zombie_entered(body):
	if body.is_in_group("zombies"):
		targets_in_range.append(body)
		if timer.is_stopped():
			shoot()
			timer.start()

func _on_zombie_exited(body):
	if body in targets_in_range:
		targets_in_range.erase(body)
	if targets_in_range.is_empty():
		timer.stop()

func shoot():
	if black_hole_scene and not targets_in_range.is_empty():
		var target = targets_in_range[0]
		if not is_instance_valid(target): return
		
		var bh = black_hole_scene.instantiate()
		
		var spawn_destination = target.global_position 
		
		get_tree().current_scene.add_child(bh)
		bh.global_position = muzzle.global_position
		bh.target_pos = spawn_destination
#func shoot():
	#if black_hole_scene and not targets_in_range.is_empty():
		#var target = targets_in_range[0]
		#var bh = black_hole_scene.instantiate()
		#
		#var behind_vector = Vector2(-1, 0) * pull_offset 
		#var spawn_destination = target.global_position + behind_vector
		#
		#get_tree().current_scene.add_child(bh)
		#bh.global_position = muzzle.global_position
		#
		#bh.target_pos = spawn_destination

func _on_timer_timeout():
	if not targets_in_range.is_empty():
		shoot()
