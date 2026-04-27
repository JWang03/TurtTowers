#extends StaticBody2D
#
##@export var bullet_scene: PackedScene 
#@export var fire_rate: float = 0.2
#@export var cost: int = 5
#@export var is_placed: bool = false
#
#
#
#@onready var muzzle = $Muzzle
#@onready var timer = $Timer
#@onready var detection_area = $Range
#
#var targets_in_range: Array = []
#
#var bullet_scene = preload("res://Towers/bullet.tscn")
#
#func _ready():
	#print("searching")
	#timer.wait_time = fire_rate
	#timer.one_shot = false
	#
	#detection_area.body_entered.connect(_on_zombie_entered)
	#detection_area.body_exited.connect(_on_zombie_exited)
	#timer.timeout.connect(_on_timer_timeout)
#
#func _on_zombie_entered(body):
	#if body.is_in_group("zombies"):
		#print("Zombie Detected")
		#for b in body:
			#if "is_stealth" in b and b.is_stealth:
				#continue
		#targets_in_range.append(body)
		#if timer.is_stopped():
			#shoot()
			#timer.start()
#
#func _on_zombie_exited(body):
	#if body in targets_in_range:
		#targets_in_range.erase(body)
		#
	#if targets_in_range.is_empty():
		#timer.stop()
#
#func shoot():
	#print("Shoot function called")
	#if bullet_scene and not targets_in_range.is_empty():
		#print("Spawning bullet")
		#var target = targets_in_range[0]
		#var bullet = bullet_scene.instantiate()
		#get_tree().current_scene.add_child(bullet)
		#
		#bullet.global_position = muzzle.global_position
		#
		#bullet.look_at(target.global_position)
	#else:
		#print("no bullet scene")
	##if bullet_scene:
		##var bullet = bullet_scene.instantiate()
		##get_tree().current_scene.add_child(bullet)
		##bullet.global_position = muzzle.global_position
#
#func _on_timer_timeout():
	#if not targets_in_range.is_empty():
		#shoot()
	#else:
		#timer.stop()


extends StaticBody2D

@export var fire_rate: float = 0.2
@export var is_placed: bool = false

@onready var muzzle = $Muzzle
@onready var timer = $Timer
@onready var detection_area = $Range
@onready var starter = get_node("/root/Game/UI/Start_Pause/PlayButton")
var targets_in_range: Array = []
var bullet_scene = preload("res://Towers/bullet.tscn")
var cost: int = 5

var is_placed := false
func _ready():
	timer.wait_time = fire_rate
	detection_area.body_entered.connect(_on_zombie_entered)
	detection_area.body_exited.connect(_on_zombie_exited)
	timer.timeout.connect(_on_timer_timeout)

func _on_zombie_entered(body):
	if body.is_in_group("zombies"):
		targets_in_range.append(body)
		if timer.is_stopped():
			attempt_shot()
			timer.start()

func _on_zombie_exited(body):
	targets_in_range.erase(body)
	if targets_in_range.is_empty():
		timer.stop()

func get_valid_target():
	targets_in_range = targets_in_range.filter(func(t): return is_instance_valid(t))
	
	for target in targets_in_range:
		if target.get("is_stealth") == true:
			continue
		return target
	return null

func get_shield_provider(zombie):
	var protectors = get_tree().get_nodes_in_group("shield_mobs")
	for p in protectors:
		if is_instance_valid(p) and p.get("is_shield_active"):
			var dist = p.global_position.distance_to(zombie.global_position)
			if dist <= p.shield_radius:
				return p
	return null

func attempt_shot():
	var target = get_valid_target()
	
	if target and bullet_scene:
		var shield_provider = get_shield_provider(target)
		
		var final_target = shield_provider if shield_provider else target
		
		var bullet = bullet_scene.instantiate()
		get_tree().current_scene.add_child(bullet)
		bullet.global_position = muzzle.global_position
		
		bullet.look_at(final_target.global_position)
func shoot():
	if starter.playing == true:
		if is_placed == false:
			return
		elif bullet_scene and not targets_in_range.is_empty():
			
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

		if bullet.has_method("set_hit_target"):
			bullet.set_hit_target(final_target)
	
	elif targets_in_range.is_empty():
		timer.stop()

func _on_timer_timeout():
	attempt_shot()
