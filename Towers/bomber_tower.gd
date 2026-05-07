extends StaticBody2D

@export var fire_rate: float = 2
@export var is_placed: bool = false
var occupied_cell: Vector2i
var tilemap: TileMapLayer
@onready var muzzle = $Muzzle
@onready var timer = $Timer
@onready var detection_area = $Range
@export var cost: float = 25
var damage_multiplier = 1.0
var double_shot = false
var triple_shot = false
var quad_shot = false
@onready var starter = get_node("/root/Game/UI/Start_Pause/PlayButton")
var targets_in_range: Array = []
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
	if starter.playing == true:
		if is_placed == false:
			return
		elif bomb_scene and not targets_in_range.is_empty():
			var valid_targets = targets_in_range.filter(func(t): 
				return t.get("is_stealth") != true
			)

			if valid_targets.is_empty(): return

			var target = valid_targets[0]
			var shield_provider = get_shield_provider(target)
			var final_target = shield_provider if shield_provider else target

			var offsets: Array
			if quad_shot:
				offsets = [-15, -5, 5, 15]
			elif triple_shot:
				offsets = [-10, 0, 10]
			elif double_shot:
				offsets = [-5, 5]
			else:
				offsets = [0]

			for offset in offsets:
				var bomb = bomb_scene.instantiate()
				bomb.damage *= damage_multiplier
				get_tree().current_scene.add_child(bomb)
				bomb.global_position = muzzle.global_position
				bomb.target_pos = final_target.global_position
				
				if offset != 0:
					var dir = (final_target.global_position - muzzle.global_position).normalized()
					var perp = Vector2(-dir.y, dir.x)
					bomb.global_position += perp * offset
					bomb.target_pos = final_target.global_position + perp * offset

func _on_timer_timeout():
	shoot()
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
#Upgrading:
var tower_name = "Demolition Turt"
var upgrades = {
	"left": {
		"name": "Cluster Bomber",
		"tiers": [
			{"label": "+1 Bomb", "cost": 75},
			{"label": "+1 Bomb", "cost": 150},
			{"label": "+1 Bomb", "cost": 300}
		]
	},
	"right": {
		"name": "Missile Menace",
		"tiers": [
			{"label": "Faster Fire", "cost": 100},
			{"label": "Increased Range","cost": 200},
			{"label": "Homing Missiles", "cost": 300}
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
	
	var cost = 0
	if branch == "left":
		cost = upgrades["left"]["tiers"][left_level]["cost"]
	elif branch == "right":
		cost = upgrades["right"]["tiers"][right_level]["cost"]
	
	var currency_manager = get_node("/root/Game/UI/HUD/CurrencyManager")
	if currency_manager.shellings < cost:
		return
	currency_manager.spend_shellings(cost)
	
	if branch == "left":
		apply_left_upgrade()
		left_level += 1
	elif branch == "right":
		apply_right_upgrade()
		right_level += 1

func apply_left_upgrade():
	match left_level:
		0: double_shot = true
		1:
			double_shot = false
			triple_shot = true
		2: 
			triple_shot = false
			quad_shot = true

func apply_right_upgrade():
	match right_level:
		2: bomb_scene = preload("res://Towers/missile.tscn")
		0:
			fire_rate *= 0.5
		1: detection_area.scale *= 2
		
func sell() -> void:
	var currency_manager = get_node("/root/Game/UI/HUD/CurrencyManager")
	currency_manager.add_shellings(cost / 2)
	if tilemap:
		tilemap.unoccupy_cell(occupied_cell)
	queue_free()
