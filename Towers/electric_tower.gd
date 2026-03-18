extends StaticBody2D

@export var attack_damage = 10
@export var max_bounces = 6
@export var jump_range = 150.0
@export var attack_cooldown = 1.5
@export var cost: float = 25

@onready var detection_area = $Range
@onready var attack_timer = $Timer
@onready var shoot_point = $Muzzle

var lightning_scene = preload("res://Towers/bolt.tscn")

func _ready():
	if !attack_timer.timeout.is_connected(_on_tower_heartbeat):
		attack_timer.timeout.connect(_on_tower_heartbeat)
	attack_timer.wait_time = attack_cooldown
	attack_timer.start()

#func _ready():
	#for connection in attack_timer.timeout.get_connections():
		#attack_timer.timeout.disconnect(connection.callable)
		#
	#attack_timer.timeout.connect(_on_tower_heartbeat)
	#attack_timer.wait_time = attack_cooldown
	#attack_timer.start()

func _on_tower_heartbeat():
	print("signal received")
	var targets = find_chain_targets()
	if targets.size() > 0:
		execute_chain_attack(targets)
	else:
		print("no zombies in range yet")
#func _ready():
	#print("tower ready")
	#attack_timer.wait_time = attack_cooldown
	#attack_timer.start()
	#print("Timer started. Waiting ", attack_cooldown, " seconds...")

#func _on_attack_timer_timeout():
	#print("timer fired")
	#var targets = find_chain_targets()
	#print("Found ", targets.size(), " enemies in range.")
	#if targets.size() > 0:
		#execute_chain_attack(targets)
	#else:
		#print("no enemy detected")

func find_chain_targets():
	var chain = []
	var zombies = detection_area.get_overlapping_bodies()
	
	if zombies.size() == 0:
		return chain

	zombies.sort_custom(func(a, b): 
		return global_position.distance_to(a.global_position) < global_position.distance_to(b.global_position)
	)
	var current_target = zombies[0]
	chain.append(current_target)

	for i in range(max_bounces - 1):
		var next_target = find_next_jump(current_target, chain)
		if next_target:
			chain.append(next_target)
			current_target = next_target
		else:
			break
	return chain

func find_next_jump(current, excluded):
	var all_zombies = get_tree().get_nodes_in_group("zombies")
	var best_next = null
	var min_dist = jump_range

	for zombie in all_zombies:
		if zombie in excluded: continue
		
		var dist = current.global_position.distance_to(zombie.global_position)
		if dist < min_dist:
			min_dist = dist
			best_next = zombie
	return best_next

func execute_chain_attack(targets):
	var start_pos = shoot_point.global_position
	
	for target in targets:
		var bolt = lightning_scene.instantiate()
		get_tree().current_scene.add_child(bolt)
		#get_parent().add_child(bolt)
		bolt.create_bolt(start_pos, target.global_position)
		
		if target.has_method("take_damage"):
			target.take_damage(attack_damage)
		
		start_pos = target.global_position
