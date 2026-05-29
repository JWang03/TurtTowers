extends TowerBase

@onready var attack_timer = $Timer
@onready var shoot_point = $Muzzle
@onready var sprite = $Sprite2D

var lightning_scene = preload("res://Towers/bolt.tscn")

@export var left_sprite: Texture2D
@export var right_sprite: Texture2D

@export var attack_damage = 30
@export var max_bounces = 6
@export var jump_range = 150.0
@export var attack_cooldown = 1.5

@export var buff_radius = 200.0
@export var damage_buff_multiplier = 2
@export var speed_buff_multiplier = 0.5

var buffed_towers_damage: Array = []
var buffed_towers_speed: Array = []
var left_level = 0
var right_level = 0
var chosen_branch = ""
var tower_name = "Mad Scienturt"

var recoil_tween: Tween

var upgrades = {
	"left": {
		"name": "The Physicist",
		"tiers": [
			{"label": "High Voltage", "cost": 200},
			{"label": "Superconductor", "cost": 600},
			{"label": "Tesla Overload", "cost": 2000}
		]
	},
	"right": {
		"name": "The Chemist",
		"tiers": [
			{"label": "Adrenaline Serum", "cost": 250},
			{"label": "Anabolic Catalyst", "cost": 900},
			{"label": "Elixir of Life", "cost": 8000}
		]
	}
}

func _ready():
	super._ready()
	cost = 100
	attack_timer.wait_time = attack_cooldown
	if !attack_timer.timeout.is_connected(_on_tower_heartbeat):
		attack_timer.timeout.connect(_on_tower_heartbeat)
	attack_timer.start()

func _process(_delta):
	attack_timer.wait_time = attack_cooldown
	
	if right_level >= 1:
		update_aura()
		
	var target = get_best_target()
	if target:
		look_at(target.global_position)
		
		if sprite.texture == left_sprite or sprite.texture == right_sprite:
			rotation += PI
		else:
			rotation += PI
			
		var angle = wrapf(rotation, -PI, PI)
		if abs(angle) > PI / 2:
			sprite.flip_v = true
		else:
			sprite.flip_v = false

func _on_tower_heartbeat():
	if starter.playing == true:
		if is_placed == false:
			return
		else:
			var targets = find_chain_targets()
			if targets.size() > 0:
				execute_chain_attack(targets)


func execute_chain_attack(targets):
	if recoil_tween:
		recoil_tween.kill()
	recoil_tween = create_tween()
	var recoil_dir = 8.0 if not sprite.flip_v else -8.0
	recoil_tween.tween_property(sprite, "offset:y", recoil_dir, 0.05).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	recoil_tween.tween_property(sprite, "offset:y", 0.0, 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)

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


func get_nearby_towers() -> Array:
	var towers = []
	for node in get_tree().get_nodes_in_group("towers"):
		if node == self: continue
		if global_position.distance_to(node.global_position) <= buff_radius:
			towers.append(node)
	return towers

func update_aura():
	var nearby = get_nearby_towers()

	for tower in buffed_towers_damage.duplicate():
		if tower not in nearby or !is_instance_valid(tower):
			if "attack_damage" in tower:
				tower.attack_damage /= damage_buff_multiplier
			buffed_towers_damage.erase(tower)

	for tower in buffed_towers_speed.duplicate():
		if tower not in nearby or !is_instance_valid(tower):
			if "attack_cooldown" in tower:
				tower.attack_cooldown /= speed_buff_multiplier
				if tower.has_node("Timer"):
					tower.get_node("Timer").wait_time = tower.attack_cooldown
			buffed_towers_speed.erase(tower)

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


func _refresh_visuals():
	if left_level >= 3 and left_sprite:
		sprite.texture = left_sprite
		sprite.scale*=.95
	elif right_level >= 3 and right_sprite:
		sprite.texture = right_sprite

func purchase_upgrade(branch: String):
	if chosen_branch != "" and chosen_branch != branch:
		return
	var ucost = 0
	if branch == "left":
		ucost = upgrades["left"]["tiers"][left_level]["cost"]
	elif branch == "right":
		ucost = upgrades["right"]["tiers"][right_level]["cost"]
	# block tier 3 if another tower already has it
	if branch == "left" and left_level == 2 and not UpgradeManager.can_purchase_tier3_left(tower_name):
		return
	if branch == "right" and right_level == 2 and not UpgradeManager.can_purchase_tier3_right(tower_name):
		return
	var currency_manager = get_node("/root/Game/UI/HUD/CurrencyManager")
	if currency_manager.shellings < ucost:
		return
	currency_manager.spend_shellings(ucost)
	if chosen_branch == "":
		chosen_branch = branch  # only set AFTER confirming purchase
	if branch == "left":
		apply_left_upgrade()
		left_level += 1
		if left_level == 3 and left_sprite:
			sprite.texture = left_sprite
			UpgradeManager.register_tier3_left(tower_name)
			
	elif branch == "right":
		apply_right_upgrade()
		right_level += 1
		if right_level == 3 and right_sprite:
			sprite.texture = right_sprite
			UpgradeManager.register_tier3_right(tower_name)
			
	refresh_range_indicator()
	_refresh_visuals()

func apply_left_upgrade():
	match left_level:
		0: max_bounces = 10
		1: attack_cooldown *= .5
		2: max_bounces = 20

func apply_right_upgrade():
	match right_level:
		0: set_process(true)
		1: pass
		2: grant_extra_life()

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

func sell() -> void:
	for tower in buffed_towers_damage:
		if is_instance_valid(tower) and "attack_damage" in tower:
			tower.attack_damage /= damage_buff_multiplier
	for tower in buffed_towers_speed:
		if is_instance_valid(tower) and "attack_cooldown" in tower:
			tower.attack_cooldown /= speed_buff_multiplier
			if tower.has_node("Timer"):
				tower.get_node("Timer").wait_time = tower.attack_cooldown
	if left_level >= 3:
		UpgradeManager.unregister_tier3_left(tower_name)
	if right_level >= 3:
		UpgradeManager.unregister_tier3_right(tower_name)
	super.sell()
