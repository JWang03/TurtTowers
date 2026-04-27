extends CharacterBody2D

@export var flight_speed: float = 15.0
@export var rotation_speed: float = 5.0
@export var fire_rate: float = 0.2
@export var cost: int = 5
@export var is_placed: bool = false


var target: Node2D = null
var enemies_in_range: Array = []

@onready var path_follow = $Path2D/PathFollow2D
@onready var muzzle = $Path2D/PathFollow2D/Muzzle
@onready var shoot_timer = $Timer

var bullet_scene = preload("res://Towers/bullet.tscn")

func _ready():
	shoot_timer.wait_time = fire_rate
	shoot_timer.one_shot = false
	
	if not shoot_timer.timeout.is_connected(_on_shoot_timer_timeout):
		shoot_timer.timeout.connect(_on_shoot_timer_timeout)
		shoot_timer.start()

func _process(delta):
	if Engine.get_frames_drawn() % 60 == 0:
		print("Enemies currently in array: ", enemies_in_range.size())
	path_follow.progress += flight_speed * delta
	_update_target()

	if is_instance_valid(target):
		muzzle.look_at(target.global_position)

func _on_shoot_timer_timeout():
	if is_instance_valid(target):
		shoot()

func shoot():
	var b = bullet_scene.instantiate()
	get_tree().current_scene.add_child(b)
	
	b.global_transform = muzzle.global_transform

func _on_range_body_entered(body):
	print("zombie detected")
	if body.is_in_group("zombies"):
		enemies_in_range.append(body)
		_update_target()

func _on_range_body_exited(body):
	if body in enemies_in_range:
		enemies_in_range.erase(body)
		_update_target()

func _update_target():
	enemies_in_range = enemies_in_range.filter(func(e): return is_instance_valid(e))
	
	if enemies_in_range.size() > 0:
		target = enemies_in_range[0]
	else:
		target = null
