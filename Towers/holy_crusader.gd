extends Node2D

@export var fire_rate: float = 0.0001
@export var damage: int = 100

@onready var range_area = $Range
@onready var collision_shape = $Range/CollisionShape2D
@onready var timer = $Timer

var beam_scene = preload("res://towers/holybeam.tscn")
var targets_in_range: Array = []
var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	timer.wait_time = fire_rate
	
	range_area.body_entered.connect(_on_zombie_entered)
	range_area.body_exited.connect(_on_zombie_exited)
	timer.timeout.connect(_on_timer_timeout)

func _on_zombie_entered(body):
	if body.is_in_group("zombies"):
		targets_in_range.append(body)
		if timer.is_stopped():
			smite()
			timer.start()

func _on_zombie_exited(body):
	if body in targets_in_range:
		targets_in_range.erase(body)
	
	if targets_in_range.is_empty():
		timer.stop()

func _on_timer_timeout():
	if not targets_in_range.is_empty():
		smite()
	else:
		timer.stop()

func smite():
	var shape = collision_shape.shape
	if shape is CircleShape2D:
		var radius = shape.radius
		
		var angle = rng.randf_range(0, TAU)
		var dist = sqrt(rng.randf()) * radius
		var offset = Vector2(cos(angle), sin(angle)) * dist
		var spawn_pos = global_position + offset
		
		spawn_beam(spawn_pos)

func spawn_beam(pos: Vector2):
	var beam = beam_scene.instantiate()
	get_tree().current_scene.add_child(beam)
	beam.global_position = pos
	
	if beam.has_method("set_damage"):
		beam.set_damage(damage)
