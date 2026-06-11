extends TowerBase

var turt_scene = preload("res://Towers/turt_mine.tscn")
@export var spawn_interval: float = 0.4
@export var search_radius: float = 120.0

@export var left_sprite: Texture2D
@export var right_sprite: Texture2D

var path_node: Path2D = null
var spawn_offset: float = 0.0
var factory_active: bool = false

var double_spawn: bool = false
var explosive_shell: bool = false
var mega_turt: bool = false
var turt_damage_multiplier: float = 1.0
var turt_scale_multiplier: float = 1.0
var turt_health: int = 1

@onready var spawn_timer: Timer = Timer.new()
@onready var sprite = $Sprite2D 

func _ready():
	super._ready()
	cost = 400
	path_node = get_tree().get_first_node_in_group("EnemyPath")
	add_child(spawn_timer)
	spawn_timer.wait_time = spawn_interval
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)


func _process(_delta):
	if starter.playing == true:
		if path_node == null:
			path_node = get_tree().get_first_node_in_group("EnemyPath")
		if is_placed and not factory_active and path_node != null:
			if starter and starter.playing:
				calculate_best_spawn_point()
				spawn_timer.start()
				factory_active = true
		if factory_active and starter and not starter.playing:
			spawn_timer.stop()
			factory_active = false
		if not is_placed and factory_active:
			spawn_timer.stop()
			factory_active = false

func calculate_best_spawn_point():
	if path_node == null:
		return
	var curve = path_node.curve
	var local_pos = path_node.to_local(global_position)
	var closest_offset = curve.get_closest_offset(local_pos)
	var closest_pos = curve.sample_baked(closest_offset)
	var global_closest = path_node.to_global(closest_pos)
	if global_closest.distance_to(global_position) <= search_radius:
		spawn_offset = closest_offset
	else:
		factory_active = false
		spawn_timer.stop()

func _on_spawn_timer_timeout():
	if is_placed and path_node and turt_scene:
		if starter and starter.playing:
			if double_spawn:
				spawn_turt(0.0, -12.0)
				spawn_turt(0.0, 12.0)
			else:
				spawn_turt()

func spawn_turt(progress_offset: float = 0.0, lateral_offset: float = 0.0):
	var follower = PathFollow2D.new()
	follower.loop = false
	follower.rotates = true
	follower.set_meta("is_turt", true)  # tag it
	path_node.add_child(follower)
	follower.progress = spawn_offset + progress_offset

	var turt = turt_scene.instantiate()
	turt.damage *= turt_damage_multiplier
	turt.health = turt_health
	turt.explosive = explosive_shell
	turt.scale *= turt_scale_multiplier
	turt.scale.y *= -1  # flips vertically
	if lateral_offset != 0.0:
		turt.position.y = lateral_offset
	follower.add_child(turt)

	if turt.has_method("set_follower"):
		turt.set_follower(follower)

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

var tower_name = "Shell Facturtory"
var upgrades = {
	"left": {
		"name": "Assembly Line",
		"tiers": [
			{"label": "Overclocked Conveyor", "cost": 275},
			{"label": "Dual-Lane Logistics", "cost": 575},
			{"label": "Automated Swarm", "cost": 3000}
		]
	},
	"right": {
		"name": "Heavy Shell",
		"tiers": [
			{"label": "Ironclad Scutes", "cost": 500},
			{"label": "Volatile Payload", "cost": 1000},
			{"label": "The Behemoth Project", "cost": 6500}
		]
	}
}
var left_level = 0
var right_level = 0
var chosen_branch = ""

func _refresh_visuals():
	if left_level >= 3 and left_sprite:
		sprite.texture = left_sprite
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
		0:
			spawn_interval *= 0.6
			spawn_timer.wait_time = spawn_interval
		1:
			double_spawn = true
		2:
			spawn_interval *= 0.35
			spawn_timer.wait_time = spawn_interval
			turt_scale_multiplier = 0.7
			turt_damage_multiplier *= 0.7

func apply_right_upgrade():
	match right_level:
		0:
			turt_health = 3
			turt_damage_multiplier *= 1.5
		1:
			explosive_shell = true
			turt_damage_multiplier *= 1.5
		2:
			mega_turt = true
			spawn_interval *= 3.0
			spawn_timer.wait_time = spawn_interval
			turt_scale_multiplier = 2.5
			turt_damage_multiplier *= 5.0
			turt_health = 10

func sell() -> void:
		if left_level >= 3:
			UpgradeManager.unregister_tier3_left(tower_name)
		if right_level >= 3:
			UpgradeManager.unregister_tier3_right(tower_name)
		super.sell()
