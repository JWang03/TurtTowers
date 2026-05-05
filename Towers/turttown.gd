extends StaticBody2D

const ATTACK_SPEED_MULTIPLIER := 3.0   
const ATTACK_RANGE_MULTIPLIER := 10.0  
const TILE_SIZE := 54.0                
const ADJACENCY_MULTIPLIER := 1.5      
const SELF_EXCLUSION_THRESHOLD := 0.5  
const RANGE_NODE_NAME := "Range"      
const MIN_TIMER_WAIT := 0.01           

@export var cost: float = 10

var is_placed := false:
	set(value):
		is_placed = value
		if value:
			call_deferred("_on_placed")

var _buffed_towers: Dictionary = {}

func _on_placed() -> void:
	_scan_existing_towers()
	var parent := get_parent()
	if is_instance_valid(parent) and not parent.child_entered_tree.is_connected(_on_sibling_entered):
		parent.child_entered_tree.connect(_on_sibling_entered)

func _exit_tree() -> void:
	var parent := get_parent()
	if is_instance_valid(parent) and parent.child_entered_tree.is_connected(_on_sibling_entered):
		parent.child_entered_tree.disconnect(_on_sibling_entered)
	for tower in _buffed_towers.keys():
		if is_instance_valid(tower):
			_remove_buff(tower)
	_buffed_towers.clear()

func _scan_existing_towers() -> void:
	var parent := get_parent()
	if not is_instance_valid(parent):
		return
	for child in parent.get_children():
		_try_buff(child)

func _on_sibling_entered(node: Node) -> void:
	# Defer so the new tower has its position and is_placed set before we check it
	call_deferred("_try_buff", node)

func _is_adjacent(node: Node) -> bool:
	if node is Node2D:
		var dist := global_position.distance_to((node as Node2D).global_position)
		return dist > SELF_EXCLUSION_THRESHOLD and dist <= TILE_SIZE * ADJACENCY_MULTIPLIER
	return false

func _try_buff(node: Node) -> void:
	if node == self or not is_instance_valid(node):
		return
	if node.is_in_group("zombies"):
		return
	if not (node is Node2D):
		return
	var placed = node.get("is_placed")
	if placed != null and placed == false:
		return
	if _buffed_towers.has(node):
		return
	if not _is_adjacent(node):
		return
	_apply_buff(node)
	if not node.tree_exiting.is_connected(_on_tower_exiting.bind(node)):
		node.tree_exiting.connect(_on_tower_exiting.bind(node))

func _on_tower_exiting(tower: Node) -> void:
	# Tower is being freed – just drop it from the tracking dict
	_buffed_towers.erase(tower)

func _apply_buff(tower: Node) -> void:
	if not is_instance_valid(tower):
		return

	var adj_count: int = tower.get_meta("turttown_buff_count", 0)
	tower.set_meta("turttown_buff_count", adj_count + 1)

	if adj_count > 0:
		_buffed_towers[tower] = {}
		return

	var buff_data := {}

	var attack_timer := _find_child_of_type(tower, Timer) as Timer
	if attack_timer:
		buff_data["timer"] = attack_timer
		buff_data["original_wait_time"] = attack_timer.wait_time
		attack_timer.wait_time = max(attack_timer.wait_time / ATTACK_SPEED_MULTIPLIER, MIN_TIMER_WAIT)

	var anim_sprite := _find_child_of_type(tower, AnimatedSprite2D) as AnimatedSprite2D
	if anim_sprite:
		buff_data["anim_sprite"] = anim_sprite
		buff_data["original_speed_scale"] = anim_sprite.speed_scale
		anim_sprite.speed_scale *= ATTACK_SPEED_MULTIPLIER

	var fire_rate = tower.get("fire_rate")
	if fire_rate != null and typeof(fire_rate) in [TYPE_FLOAT, TYPE_INT]:
		buff_data["fire_rate_node"] = tower
		buff_data["original_fire_rate"] = float(fire_rate)
		tower.set("fire_rate", max(float(fire_rate) / ATTACK_SPEED_MULTIPLIER, MIN_TIMER_WAIT))

	var tower_range := tower.find_child(RANGE_NODE_NAME, true, false) as Area2D
	if tower_range:
		var collision_shape := _find_child_of_type(tower_range, CollisionShape2D) as CollisionShape2D
		if collision_shape and collision_shape.shape:
			_apply_radius_buff(collision_shape, buff_data)

	_buffed_towers[tower] = buff_data
	tower.set_meta("turttown_buff_data", buff_data)

func _apply_radius_buff(collision_shape: CollisionShape2D, buff_data: Dictionary) -> void:
	var shape := collision_shape.shape
	buff_data["shape_node"] = collision_shape
	if shape is CircleShape2D:
		buff_data["original_radius"] = shape.radius
		shape.radius *= ATTACK_RANGE_MULTIPLIER
	elif shape is CapsuleShape2D:
		buff_data["original_capsule_radius"] = shape.radius
		shape.radius *= ATTACK_RANGE_MULTIPLIER

func _remove_buff(tower: Node) -> void:
	if not _buffed_towers.has(tower):
		return

	if not tower.has_meta("turttown_buff_count"):
		push_error("turttown: turttown_buff_count missing for tower '%s' during buff removal" % tower.name)
		_buffed_towers.erase(tower)
		return
	var adj_count: int = tower.get_meta("turttown_buff_count")
	if adj_count <= 0:
		push_error("turttown: turttown_buff_count is %d (expected ≥ 1) for tower '%s'" % [adj_count, tower.name])
		tower.remove_meta("turttown_buff_count")
		_buffed_towers.erase(tower)
		return
	var new_count := adj_count - 1
	if new_count > 0:
		tower.set_meta("turttown_buff_count", new_count)
		_buffed_towers.erase(tower)
		return

	tower.remove_meta("turttown_buff_count")

	if not tower.has_meta("turttown_buff_data"):
		push_error("turttown: turttown_buff_data missing for tower '%s'; cannot restore original stats" % tower.name)
		_buffed_towers.erase(tower)
		return
	var buff_data: Dictionary = tower.get_meta("turttown_buff_data")
	tower.remove_meta("turttown_buff_data")

	var attack_timer := buff_data.get("timer") as Timer
	if attack_timer and is_instance_valid(attack_timer):
		attack_timer.wait_time = buff_data.get("original_wait_time", attack_timer.wait_time)

	var anim_sprite := buff_data.get("anim_sprite") as AnimatedSprite2D
	if anim_sprite and is_instance_valid(anim_sprite):
		anim_sprite.speed_scale = buff_data.get("original_speed_scale", anim_sprite.speed_scale)

	var fire_rate_node = buff_data.get("fire_rate_node")
	if fire_rate_node != null and is_instance_valid(fire_rate_node) and buff_data.has("original_fire_rate"):
		fire_rate_node.set("fire_rate", buff_data["original_fire_rate"])

	var collision_shape := buff_data.get("shape_node") as CollisionShape2D
	if collision_shape and is_instance_valid(collision_shape) and collision_shape.shape:
		var shape := collision_shape.shape
		if shape is CircleShape2D and buff_data.has("original_radius"):
			shape.radius = buff_data["original_radius"]
		elif shape is CapsuleShape2D and buff_data.has("original_capsule_radius"):
			shape.radius = buff_data["original_capsule_radius"]

	_buffed_towers.erase(tower)

func _find_child_of_type(node: Node, type: Variant) -> Node:
	for child in node.get_children():
		if is_instance_of(child, type):
			return child
	return null
