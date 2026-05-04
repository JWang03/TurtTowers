extends TowerBase

@export var attack_damage = 10
@export var max_bounces = 6
@export var jump_range = 150.0
@export var attack_cooldown = 1.5
@export var cost: int = 5

@onready var attack_timer = $Timer
@onready var shoot_point = $Muzzle

var lightning_scene = preload("res://Towers/bolt.tscn")

func _ready():
	super._ready()
	attack_timer.wait_time = attack_cooldown
	if !attack_timer.timeout.is_connected(_on_tower_heartbeat):
		attack_timer.timeout.connect(_on_tower_heartbeat)
	attack_timer.start()

func _on_tower_heartbeat():
	if not is_placed or not starter or not starter.playing:
		return
		
	var targets = find_chain_targets()
	if targets.size() > 0:
		execute_chain_attack(targets)

func find_chain_targets():
	var chain = []
	
	var first_target = get_best_target()
	
	if not first_target:
		return chain

	chain.append(first_target)
	var current_target = first_target

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
		if !is_instance_valid(zombie) or zombie in excluded: 
			continue
		if zombie.get("is_stealth") == true:
			continue
		
		var dist = current.global_position.distance_to(zombie.global_position)
		if dist < min_dist:
			min_dist = dist
			best_next = zombie
	return best_next

func execute_chain_attack(targets):
	var start_pos = shoot_point.global_position
	var shields_hit_this_chain = {}

	for target in targets:
		if !is_instance_valid(target): continue
		
		var shield_provider = get_shield_provider(target)
		var final_target = shield_provider if shield_provider else target
		var target_pos = final_target.global_position
		
		var bolt = lightning_scene.instantiate()
		get_tree().current_scene.add_child(bolt)
		
		if bolt.has_method("create_bolt"):
			bolt.create_bolt(start_pos, target_pos)
		
		if shield_provider:
			if !shields_hit_this_chain.has(shield_provider):
				shield_provider.take_damage(attack_damage)
				shields_hit_this_chain[shield_provider] = true
		else:
			target.take_damage(attack_damage)
		
		start_pos = target_pos
