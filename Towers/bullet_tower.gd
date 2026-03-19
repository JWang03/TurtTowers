extends StaticBody2D

#@export var bullet_scene: PackedScene 
@export var fire_rate: float = 0.3
@export var cost: float = 25
@onready var muzzle = $Muzzle
@onready var timer = $Timer
@onready var detection_area = $Range
@onready var starter = get_node("/root/Game/UI/Start_Pause/PlayButton")
var targets_in_range: Array = []

var bullet_scene = preload("res://Towers/bullet.tscn")

func _ready():
	print("searching")
	timer.wait_time = fire_rate
	timer.one_shot = false
	
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
	if starter.playing == true:
		if bullet_scene and not targets_in_range.is_empty():
			
			var target = targets_in_range[0]
			var bullet = bullet_scene.instantiate()
			get_tree().current_scene.add_child(bullet)
			
			bullet.global_position = muzzle.global_position
			
			bullet.look_at(target.global_position)
		else:
			print("no bullet scene")
	#if bullet_scene:
		#var bullet = bullet_scene.instantiate()
		#get_tree().current_scene.add_child(bullet)
		#bullet.global_position = muzzle.global_position

func _on_timer_timeout():
	if not targets_in_range.is_empty():
		shoot()
	else:
		timer.stop()
