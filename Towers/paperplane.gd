extends CharacterBody2D

@export var flight_speed: float = 45.0
@export var fire_rate: float = 0.05
@export var spread_count: int = 24
@export var spread_angle: float = 15
@export var cost: int = 20
@export var is_placed: bool = false
@onready var path_follow = $Path2D/PathFollow2D
@onready var muzzle = $Path2D/PathFollow2D/Muzzle
@onready var shoot_timer = $Timer
@onready var starter = get_node("/root/Game/UI/Start_Pause/PlayButton")
var bullet_scene = preload("res://Towers/bullet.tscn")

func _ready():
	shoot_timer.wait_time = fire_rate
	shoot_timer.one_shot = false
	
	if not shoot_timer.timeout.is_connected(_on_shoot_timer_timeout):
		shoot_timer.timeout.connect(_on_shoot_timer_timeout)
		shoot_timer.start()

func _process(delta):
	path_follow.progress += flight_speed * delta

func _on_shoot_timer_timeout():
	shoot()

func shoot():
	if starter.playing == true:
		var start_angle = -(spread_angle * (spread_count - 1)) / 2.0
	
		for i in range(spread_count):
			var b = bullet_scene.instantiate()
			get_tree().current_scene.add_child(b)
			
			b.global_position = muzzle.global_position
			
			var shot_rotation = muzzle.global_rotation + deg_to_rad(start_angle + (i * spread_angle))
			b.global_rotation = shot_rotation
