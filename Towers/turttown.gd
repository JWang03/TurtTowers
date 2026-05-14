extends TowerBase

const BASE_ATTACK_SPEED_MULTIPLIER := 1.3
const BASE_ATTACK_RANGE_MULTIPLIER := 1.2
const TILE_SIZE := 54.0
const SELF_EXCLUSION_THRESHOLD := 0.5
const RANGE_NODE_NAME := "Range"
const MIN_TIMER_WAIT := 0.01

var attack_speed_multiplier := BASE_ATTACK_SPEED_MULTIPLIER
var attack_range_multiplier := BASE_ATTACK_RANGE_MULTIPLIER
var damage_multiplier_buff := 1.0
var buff_radius_tiles := 1
var _buffed: Dictionary = {}
var _turrets: Array = []

# economy path
var income_active: bool = false
var income_amount: float = 20.0
var income_interval: float = 8.0
var kill_bonus_active: bool = false
var kill_bonus_amount: float = 5.0
var income_timer: Timer = null

var soldier_scene = preload("res://Towers/bullet_tower.tscn")

func _ready():
	super._ready()
	cost = 350
	income_timer = Timer.new()
	income_timer.one_shot = false
	income_timer.timeout.connect(_on_income_tick)
	add_child(income_timer)

func _on_placed() -> void:
	var parent := get_parent()
	if not is_instance_valid(parent):
		return
	for child in parent.get_children():
		_try_buff(child)
	if not parent.child_entered_tree.is_connected(_on_sibling_entered):
		parent.child_entered_tree.connect(_on_sibling_entered)

func _exit_tree() -> void:
	var parent := get_parent()
	if is_instance_valid(parent) and parent.child_entered_tree.is_connected(_on_sibling_entered):
		parent.child_entered_tree.disconnect(_on_sibling_entered)
	for tower in _buffed.keys():
		if is_instance_valid(tower):
			_remove_buff(tower)
	_buffed.clear()
	for turret in _turrets:
		if is_instance_valid(turret):
			turret.queue_free()
	_turrets.clear()

func _process(_delta):
	if income_active:
		if starter and starter.playing and income_timer.is_stopped():
			income_timer.wait_time = income_interval
			income_timer.start()
		elif starter and not starter.playing and not income_timer.is_stopped():
			income_timer.stop()

func _on_income_tick():
	if not starter or not starter.playing or not is_placed:
		return
	var currency_manager = get_node_or_null("/root/Game/UI/HUD/CurrencyManager")
	if currency_manager:
		currency_manager.add_shellings(income_amount)
		_spawn_popup("+%d" % int(income_amount), right_level - 1)

func _spawn_popup(text: String, tier: int = 0):
	var label = Label.new()
	label.text = text
	label.z_index = 200
	label.z_as_relative = false

	match tier:
		0:
			# Tax Office — small plain yellow
			label.add_theme_font_size_override("font_size", 16)
			label.add_theme_color_override("font_color", Color(1, 0.85, 0.1, 1))
			label.add_theme_constant_override("outline_size", 3)
			label.add_theme_color_override("font_outline_color", Color(0.4, 0.3, 0, 1))
		1:
			# Trade Routes — bigger, brighter gold
			label.add_theme_font_size_override("font_size", 22)
			label.add_theme_color_override("font_color", Color(1, 0.9, 0.2, 1))
			label.add_theme_constant_override("outline_size", 5)
			label.add_theme_color_override("font_outline_color", Color(0.6, 0.4, 0, 1))
		2:
			# Boom Town — big flashy green money energy
			label.add_theme_font_size_override("font_size", 30)
			label.add_theme_color_override("font_color", Color(0.2, 1, 0.3, 1))
			label.add_theme_constant_override("outline_size", 6)
			label.add_theme_color_override("font_outline_color", Color(0, 0.3, 0, 1))

	get_tree().current_scene.add_child(label)
	label.global_position = global_position + Vector2(-20, -30)

	var float_height = 40.0 + (tier * 15.0)
	var duration = 1.0 + (tier * 0.3)

	var tween = label.create_tween()
	tween.tween_property(label, "position", label.position + Vector2(0, -float_height), duration)
	tween.parallel().tween_property(label, "modulate:a", 0.0, duration)
	tween.tween_callback(label.queue_free)

func _on_sibling_entered(node: Node) -> void:
	call_deferred("_try_buff", node)

func _try_buff(node: Node) -> void:
	if node == self or not is_instance_valid(node) or not (node is Node2D):
		return
	if node.is_in_group("zombies") or _buffed.has(node):
		return
	if _turrets.has(node):
		return
	if node.has_meta("is_turtret"):
		return
	var placed = node.get("is_placed")
	if placed != null and placed == false:
		return
	if node.has_meta("turttown_buffed"):
		var adj_count: int = node.get_meta("turttown_buff_count", 0)
		node.set_meta("turttown_buff_count", adj_count + 1)
		_buffed[node] = {}
		if not node.tree_exiting.is_connected(_on_tower_exiting):
			node.tree_exiting.connect(_on_tower_exiting.bind(node))
		return
	var dist := global_position.distance_to((node as Node2D).global_position)
	var max_dist = TILE_SIZE * (buff_radius_tiles + 0.5)
	if dist <= SELF_EXCLUSION_THRESHOLD or dist > max_dist:
		return
	_apply_buff(node)
	if not node.tree_exiting.is_connected(_on_tower_exiting):
		node.tree_exiting.connect(_on_tower_exiting.bind(node))

func _on_tower_exiting(tower: Node) -> void:
	_buffed.erase(tower)

func _apply_buff(tower: Node) -> void:
	if not is_instance_valid(tower):
		return
	tower.set_meta("turttown_buff_count", 1)
	tower.set_meta("turttown_buffed", true)
	var buff_data := {}

	var attack_timer := _find_child_of_type(tower, Timer) as Timer
	if attack_timer:
		buff_data["timer"] = attack_timer
		buff_data["original_wait_time"] = attack_timer.wait_time
		attack_timer.wait_time = max(attack_timer.wait_time / attack_speed_multiplier, MIN_TIMER_WAIT)

	var anim_sprite := _find_child_of_type(tower, AnimatedSprite2D) as AnimatedSprite2D
	if anim_sprite:
		buff_data["anim_sprite"] = anim_sprite
		buff_data["original_speed_scale"] = anim_sprite.speed_scale
		anim_sprite.speed_scale *= attack_speed_multiplier

	var fire_rate = tower.get("fire_rate")
	if fire_rate != null and typeof(fire_rate) in [TYPE_FLOAT, TYPE_INT]:
		buff_data["fire_rate_node"] = tower
		buff_data["original_fire_rate"] = float(fire_rate)
		tower.set("fire_rate", max(float(fire_rate) / attack_speed_multiplier, MIN_TIMER_WAIT))

	if damage_multiplier_buff > 1.0:
		var dmg = tower.get("damage_multiplier")
		if dmg != null:
			buff_data["damage_multiplier_node"] = tower
			buff_data["original_damage_multiplier"] = float(dmg)
			tower.set("damage_multiplier", float(dmg) * damage_multiplier_buff)

	var tower_range := tower.find_child(RANGE_NODE_NAME, true, false) as Area2D
	if tower_range:
		var collision_shape := _find_child_of_type(tower_range, CollisionShape2D) as CollisionShape2D
		if collision_shape and collision_shape.shape:
			_apply_radius_buff(collision_shape, buff_data)

	_buffed[tower] = buff_data
	tower.set_meta("turttown_buff_data", buff_data)

func _apply_radius_buff(collision_shape: CollisionShape2D, buff_data: Dictionary) -> void:
	var shape := collision_shape.shape
	buff_data["shape_node"] = collision_shape
	if shape is CircleShape2D:
		buff_data["original_radius"] = shape.radius
		shape.radius *= attack_range_multiplier
	elif shape is CapsuleShape2D:
		buff_data["original_capsule_radius"] = shape.radius
		shape.radius *= attack_range_multiplier

func _remove_buff(tower: Node) -> void:
	if not _buffed.has(tower):
		return
	if not tower.has_meta("turttown_buff_count"):
		_buffed.erase(tower)
		return
	var adj_count: int = tower.get_meta("turttown_buff_count")
	var new_count := adj_count - 1
	if new_count > 0:
		tower.set_meta("turttown_buff_count", new_count)
		_buffed.erase(tower)
		return
	tower.remove_meta("turttown_buff_count")
	if not tower.has_meta("turttown_buff_data"):
		_buffed.erase(tower)
		return
	var buff_data: Dictionary = tower.get_meta("turttown_buff_data")
	tower.remove_meta("turttown_buff_data")

	var attack_timer := buff_data.get("timer") as Timer
	if attack_timer and is_instance_valid(attack_timer):
		attack_timer.wait_time = buff_data.get("original_wait_time", attack_timer.wait_time)

	var anim := buff_data.get("anim_sprite") as AnimatedSprite2D
	if anim and is_instance_valid(anim):
		anim.speed_scale = buff_data.get("original_speed_scale", anim.speed_scale)

	var fr_node = buff_data.get("fire_rate_node")
	if fr_node != null and is_instance_valid(fr_node) and buff_data.has("original_fire_rate"):
		fr_node.set("fire_rate", buff_data["original_fire_rate"])

	if buff_data.has("damage_multiplier_node"):
		var dm_node = buff_data["damage_multiplier_node"]
		if is_instance_valid(dm_node) and buff_data.has("original_damage_multiplier"):
			dm_node.set("damage_multiplier", buff_data["original_damage_multiplier"])

	var cs := buff_data.get("shape_node") as CollisionShape2D
	if cs and is_instance_valid(cs) and cs.shape:
		if cs.shape is CircleShape2D and buff_data.has("original_radius"):
			cs.shape.radius = buff_data["original_radius"]
		elif cs.shape is CapsuleShape2D and buff_data.has("original_capsule_radius"):
			cs.shape.radius = buff_data["original_capsule_radius"]

	_buffed.erase(tower)
	if is_instance_valid(tower) and tower.has_meta("turttown_buffed"):
		tower.remove_meta("turttown_buffed")

func _spawn_turret(offset: Vector2):
	if not soldier_scene:
		return
	var turret = soldier_scene.instantiate()
	add_child(turret)
	turret.position = offset
	turret.scale = Vector2(0.5, 0.5)
	turret.is_placed = true
	turret.modulate.a = 1.0
	turret.set_meta("is_turtret", true)
	_turrets.append(turret)

func _rebuff_all():
	for tower in _buffed.keys().duplicate():
		if is_instance_valid(tower):
			_remove_buff(tower)
	_buffed.clear()
	var parent = get_parent()
	if is_instance_valid(parent):
		for child in parent.get_children():
			_try_buff(child)

func _find_child_of_type(node: Node, type: Variant) -> Node:
	for child in node.get_children():
		if is_instance_of(child, type):
			return child
	return null

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

var tower_name = "Turt Town"
var upgrades = {
	"left": {
		"name": "Turt-rets",
		"tiers": [
			{"label": "Watchtower", "cost": 150},
			{"label": "The Buddy System", "cost": 300},
			{"label": "Fortified", "cost": 600}
		]
	},
	"right": {
		"name": "Economy",
		"tiers": [
			{"label": "Tax Office", "cost": 125},
			{"label": "Trade Routes", "cost": 275},
			{"label": "Boom Town", "cost": 650}
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
	refresh_range_indicator()

func apply_left_upgrade():
	match left_level:
		0:
			_spawn_turret(Vector2(-10, -10))
		1:
			_spawn_turret(Vector2(10, 10))
		2:
			for turret in _turrets:
				if is_instance_valid(turret) and turret.has_node("Timer"):
					turret.get_node("Timer").wait_time *= 0.5
			buff_radius_tiles = 2
			_rebuff_all()

func apply_right_upgrade():
	match right_level:
		0:
			income_active = true
			income_interval = 8.0
			income_amount = 20.0
		1:
			income_interval = 5.0
			income_amount = 30.0
		2:
			income_interval = 3.0
			income_amount = 50.0
			var currency_manager = get_node_or_null("/root/Game/UI/HUD/CurrencyManager")
			if currency_manager:
				currency_manager.add_shellings(300)
				_spawn_popup("+300", 2)
	# restart timer with new interval every time
	if income_active and not income_timer.is_stopped():
		income_timer.stop()
		income_timer.wait_time = income_interval
		income_timer.start()

func sell() -> void:
	for tower in _buffed.keys().duplicate():
		if is_instance_valid(tower):
			_remove_buff(tower)
	_buffed.clear()
	super.sell()
