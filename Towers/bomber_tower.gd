#extends StaticBody2D
#
##@export var bomb_scene: PackedScene
#@export var fire_rate: float = 5
#
#@export var cost: int = 5
#@export var is_placed: bool = false
#
#
#@onready var muzzle = $Muzzle
#@onready var timer = $Timer
#@onready var detection_area = $Range
#
#var targets_in_range: Array = []
#
#var bomb_scene = preload("res://Towers/bomb.tscn")
#
#func _ready():
	#timer.wait_time = fire_rate
	#
	#detection_area.body_entered.connect(_on_zombie_entered)
	#detection_area.body_exited.connect(_on_zombie_exited)
	#timer.timeout.connect(_on_timer_timeout)
#
#func _on_zombie_entered(body):
	#if body.is_in_group("zombies"):
		#targets_in_range.append(body)
		#if timer.is_stopped():
			#shoot()
			#timer.start()
#
#func _on_zombie_exited(body):
	#if body in targets_in_range:
		#targets_in_range.erase(body)
	#if targets_in_range.is_empty():
		#timer.stop()
#
##func shoot():
	##if bomb_scene and not targets_in_range.is_empty():
		##var target = targets_in_range.filter(func(t): return is_instance_valid(t) and !t.get("is_stealth")).front()
		###var target = targets_in_range[0]
		##var bomb = bomb_scene.instantiate()
		##
		##get_tree().current_scene.add_child(bomb)
		##bomb.global_position = muzzle.global_position
		##
		##bomb.target_pos = target.global_position
		##
#
#func shoot():
	#if bomb_scene and not targets_in_range.is_empty():
		#var valid_targets = targets_in_range.filter(func(t): 
			#return is_instance_valid(t) and t.get("is_stealth") != true
		#)
		#
		#if valid_targets.is_empty():
			#print("No visible targets, skipping shot")
			#return
			#
		#var target = valid_targets[0]
		#
		#print("Spawning bomb")
		#var bomb = bomb_scene.instantiate()
		#get_tree().current_scene.add_child(bomb)
		#
		#bomb.global_position = muzzle.global_position
		#bomb.target_pos = target.global_position
#
#func _on_timer_timeout():
	#if not targets_in_range.is_empty():
		#shoot()

extends StaticBody2D

@export var fire_rate: float = 2
@export var is_placed: bool = false

@onready var muzzle = $Muzzle
@onready var timer = $Timer
@onready var detection_area = $Range

var targets_in_range: Array = []
var bomb_scene = preload("res://Towers/bomb.tscn")
var cost: int = 5

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
	targets_in_range.erase(body)
	if targets_in_range.is_empty():
		timer.stop()

func get_shield_provider(zombie):
	var protectors = get_tree().get_nodes_in_group("shield_mobs")
	for p in protectors:
		if is_instance_valid(p) and p.get("is_shield_active"):
			if p.global_position.distance_to(zombie.global_position) <= p.shield_radius:
				return p
	return null

func shoot():
	targets_in_range = targets_in_range.filter(func(t): return is_instance_valid(t))
	
	if bomb_scene and not targets_in_range.is_empty():
		var valid_targets = targets_in_range.filter(func(t): 
			return t.get("is_stealth") != true
		)
		
		if valid_targets.is_empty(): return
			
		var target = valid_targets[0]
		
		var shield_provider = get_shield_provider(target)
		var final_target = shield_provider if shield_provider else target
		
		var bomb = bomb_scene.instantiate()
		get_tree().current_scene.add_child(bomb)
		
		bomb.global_position = muzzle.global_position
		bomb.target_pos = final_target.global_position

func _on_timer_timeout():
	shoot()
