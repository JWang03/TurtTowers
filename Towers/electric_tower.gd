extends StaticBody2D

@export var attack_damage = 10
@export var max_bounces = 6
@export var jump_range = 150.0
@export var attack_cooldown = 1.5
@export var cost: int = 30
@export var is_placed: bool = false
@export var buff_radius = 200.0
@export var damage_buff_multiplier = 2
@export var speed_buff_multiplier = 0.5

@onready var starter = get_node("/root/Game/UI/Start_Pause/PlayButton")
@onready var detection_area = $Range
@onready var attack_timer = $Timer
@onready var shoot_point = $Muzzle
var occupied_cell: Vector2i
var tilemap: TileMapLayer
var lightning_scene = preload("res://Towers/bolt.tscn")

var buffed_towers_damage: Array = []
var buffed_towers_speed: Array = []

func _ready():
	set_process(false)
	if !attack_timer.timeout.is_connected(_on_tower_heartbeat):
		attack_timer.timeout.connect(_on_tower_heartbeat)
	attack_timer.wait_time = attack_cooldown
	attack_timer.start()

func _process(_delta):
	if right_level >= 1:
		update_aura()

func get_shield_provider(zombie):
	var protectors = get_tree().get_nodes_in_group("shield_mobs")
	for p in protectors:
		if is_instance_valid(p) and p.get("is_shield_active"):
			if p.global_position.distance_to(zombie.global_position) <= p.shield_radius:
				return p
	return null

func _on_tower_heartbeat():
	if starter.playing == true:
		if is_placed == false:
			return
		else:
			print("signal received")
			var targets = find_chain_targets()
			if targets.size() > 0:
				execute_chain_attack(targets)
			else:
				print("no zombies in range yet")

func find_chain_targets():
	var chain = []
	var zombies = detection_area.get_overlapping_bodies().filter(func(b): return b.is_in_group("zombies"))
	
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
		if zombie in excluded or !is_instance_valid(zombie): continue
		
		var dist = current.global_position.distance_to(zombie.global_position)
		if dist < min_dist:
			min_dist = dist
			best_next = zombie
	return best_next

func _input(event):
	if not is_placed:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var mouse_pos = get_global_mouse_position()
		var space = get_world_2d().direct_space_state
		var query = PhysicsPointQueryParameters2D.new()
		query.position = mouse_pos
		query.collide_with_bodies = true
		var results = space.intersect_point(query)
		for result in results:
			if result["collider"] == self:
				Signal_Bus.tower_selected.emit(self)
				break

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
		bolt.create_bolt(start_pos, target_pos)
		
		if shield_provider:
			if !shields_hit_this_chain.has(shield_provider):
				shield_provider.take_damage(attack_damage)
				shields_hit_this_chain[shield_provider] = true
		else:
			target.take_damage(attack_damage)
		
		start_pos = target_pos

# Aura buffing:
func get_nearby_towers() -> Array:
	var towers = []
	for node in get_tree().get_nodes_in_group("towers"):
		if node == self: continue
		if global_position.distance_to(node.global_position) <= buff_radius:
			towers.append(node)
	return towers

func update_aura():
	var nearby = get_nearby_towers()

	# Remove damage buff from towers that left range
	for tower in buffed_towers_damage.duplicate():
		if tower not in nearby or !is_instance_valid(tower):
			if "attack_damage" in tower:
				tower.attack_damage /= damage_buff_multiplier
			buffed_towers_damage.erase(tower)

	# Remove speed buff from towers that left range
	for tower in buffed_towers_speed.duplicate():
		if tower not in nearby or !is_instance_valid(tower):
			if "attack_cooldown" in tower:
				tower.attack_cooldown /= speed_buff_multiplier
				if tower.has_node("Timer"):
					tower.get_node("Timer").wait_time = tower.attack_cooldown
			buffed_towers_speed.erase(tower)

	# Apply damage buff to newly in-range towers (tier 0+)
	if right_level >= 1:
		for tower in nearby:
			if tower not in buffed_towers_damage:
				if "attack_damage" in tower:
					tower.attack_damage *= damage_buff_multiplier
				elif "damage" in tower:
					tower.damage *= damage_buff_multiplier
				elif "damage_multiplier" in tower:
					tower.damage_multiplier *= damage_buff_multiplier
				buffed_towers_damage.append(tower)

	# Apply speed buff to newly in-range towers (tier 2+)
	if right_level >= 2:
		for tower in nearby:
			if tower not in buffed_towers_speed:
				if "attack_cooldown" in tower:
					tower.attack_cooldown *= speed_buff_multiplier
					if tower.has_node("Timer"):
						tower.get_node("Timer").wait_time = tower.attack_cooldown
				elif "fire_rate" in tower:
					tower.fire_rate *= speed_buff_multiplier
					if tower.has_node("Timer"):
						tower.get_node("Timer").wait_time = tower.fire_rate
				buffed_towers_speed.append(tower)

func grant_extra_life():
	var life_manager = get_node_or_null("/root/Game/UI/HUD/LossConditions")
	if life_manager and life_manager.has_method("add_lives"):
		life_manager.add_lives(100)

# Upgrading:
var tower_name = "Mad Scienturt"
var upgrades = {
	"left": {
		"name": "God of Thunder",
		"tiers": [
			{"label": "Farther Chain Lightning", "cost": 75},
			{"label": "Faster Shooting", "cost": 150},
			{"label": "Farthest Chain Lightning", "cost": 300}
		]
	},
	"right": {
		"name": "The Chemist",
		"tiers": [
			{"label": "Increased Damage to Nearby Towers", "cost": 100},
			{"label": "Faster Shooting to Nearby Towers", "cost": 200},
			{"label": "Synthesizes Extra Lives", "cost": 700}
		]
	}
}
var left_level = 0
var right_level = 0
var chosen_branch = ""

func purchase_upgrade(branch: String):
	if chosen_branch == "":
		chosen_branch = branch
	elif chosen_branch != branch:
		return
	
	var ucost = 0
	if branch == "left":
		ucost = upgrades["left"]["tiers"][left_level]["cost"]
	elif branch == "right":
		ucost = upgrades["right"]["tiers"][right_level]["cost"]
	
	var currency_manager = get_node("/root/Game/UI/HUD/CurrencyManager")
	if currency_manager.shellings < ucost:
		return
	currency_manager.spend_shellings(ucost)
	
	if branch == "left":
		apply_left_upgrade()
		left_level += 1
	elif branch == "right":
		apply_right_upgrade()
		right_level += 1

func apply_left_upgrade():
	match left_level:
		0: max_bounces = 10
		1: attack_cooldown *= .5
		2: max_bounces = 20

func apply_right_upgrade():
	match right_level:
		0:
			set_process(true)
		1:
			pass  # aura loop already running, speed buff picks up automatically
		2:
			grant_extra_life()

func sell() -> void:
	# Clean up all active buffs before freeing
	for tower in buffed_towers_damage:
		if is_instance_valid(tower) and "attack_damage" in tower:
			tower.attack_damage /= damage_buff_multiplier
	for tower in buffed_towers_speed:
		if is_instance_valid(tower) and "attack_cooldown" in tower:
			tower.attack_cooldown /= speed_buff_multiplier
			if tower.has_node("Timer"):
				tower.get_node("Timer").wait_time = tower.attack_cooldown

	var currency_manager = get_node("/root/Game/UI/HUD/CurrencyManager")
	currency_manager.add_shellings(cost / 2)
	if tilemap:
		tilemap.unoccupy_cell(occupied_cell)
	queue_free()
