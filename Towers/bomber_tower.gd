extends StaticBody2D

#@export var bomb_scene: PackedScene
@export var fire_rate: float = 5

@onready var muzzle = $Muzzle
@onready var timer = $Timer
@onready var detection_area = $Range
@export var cost: float = 25
@onready var starter = get_tree().current_scene.find_child("PlayButton", true, false)
var targets_in_range: Array = []
var is_placed := false
var bomb_scene = preload("res://Towers/bomb.tscn")

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
	if starter.playing == true:
		if is_placed == false:
			return
		elif bomb_scene and not targets_in_range.is_empty():
			var target = targets_in_range[0]
			var bomb = bomb_scene.instantiate()
			
			get_tree().current_scene.add_child(bomb)
			bomb.global_position = muzzle.global_position
			
			bomb.target_pos = target.global_position
			

func _on_timer_timeout():
	if not targets_in_range.is_empty():
		shoot()
