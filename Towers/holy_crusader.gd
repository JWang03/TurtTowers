extends Node2D

@export var fire_rate: float = 0.5
@export var damage: int = 100
@export var cost: int = 5
@export var is_placed: bool = false


@onready var range_area = $Range
@onready var collision_shape = $Range/CollisionShape2D
@onready var starter = get_tree().current_scene.find_child("PlayButton", true, false)
var beam_scene = preload("res://towers/holybeam.tscn")
var targets_in_range: Array = []
var rng = RandomNumberGenerator.new()
var time_since_last_shot: float = 0.0

func _ready():
	rng.randomize()
	range_area.body_entered.connect(_on_zombie_entered)
	range_area.body_exited.connect(_on_zombie_exited)

func _process(delta):
	if not is_placed or targets_in_range.is_empty():
		return
	if starter.playing == true:
		time_since_last_shot += delta
		if time_since_last_shot >= fire_rate:
			smite()
			time_since_last_shot = 0.0

func _on_zombie_entered(body):
	if is_placed:
		if body.is_in_group("zombies"):
			targets_in_range.append(body)

func _on_zombie_exited(body):
	if is_placed:
		if body in targets_in_range:
			targets_in_range.erase(body)

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
