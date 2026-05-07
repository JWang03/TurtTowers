extends StaticBody2D

const ATTACK_SPEED_MULTIPLIER := 3.0
const ATTACK_RANGE_MULTIPLIER := 10.0
const TILE_SIZE := 54.0
const ADJ_MULT := 1.5
const SELF_EXCLUSION_THRESHOLD := 0.5
const RANGE_NODE_NAME := "Range"
const MIN_TIMER_WAIT := 0.01

@export var cost: float = 100

var is_placed := false:
	set(value):
		is_placed = value
		if value:
			call_deferred("_on_placed")

var _buffed: Dictionary = {}

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

func _on_sibling_entered(node: Node) -> void:
	call_deferred("_try_buff", node)

func _try_buff(node: Node) -> void:
	if node == self or not is_instance_valid(node) or not (node is Node2D):
		return
	if node.is_in_group("zombies") or _buffed.has(node):
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
	if dist <= SELF_EXCLUSION_THRESHOLD or dist > TILE_SIZE * ADJ_MULT:
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

	_buffed[tower] = buff_data
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
	if not _buffed.has(tower):
		return

	if not tower.has_meta("turttown_buff_count"):
		push_error("turttown: turttown_buff_count missing for tower '%s'" % tower.name)
		_buffed.erase(tower)
		return

	var adj_count: int = tower.get_meta("turttown_buff_count")
	if adj_count <= 0:
		push_error("turttown: turttown_buff_count is %d (expected >= 1) for tower '%s'" % [adj_count, tower.name])
		tower.remove_meta("turttown_buff_count")
		_buffed.erase(tower)
		return

	var new_count := adj_count - 1
	if new_count > 0:
		tower.set_meta("turttown_buff_count", new_count)
		_buffed.erase(tower)
		return

	tower.remove_meta("turttown_buff_count")

	if not tower.has_meta("turttown_buff_data"):
		push_error("turttown: turttown_buff_data missing for tower '%s'; cannot restore stats" % tower.name)
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

	var cs := buff_data.get("shape_node") as CollisionShape2D
	if cs and is_instance_valid(cs) and cs.shape:
		if cs.shape is CircleShape2D and buff_data.has("original_radius"):
			cs.shape.radius = buff_data["original_radius"]
		elif cs.shape is CapsuleShape2D and buff_data.has("original_capsule_radius"):
			cs.shape.radius = buff_data["original_capsule_radius"]

	_buffed.erase(tower)
	if is_instance_valid(tower) and tower.has_meta("turttown_buffed"):
		tower.remove_meta("turttown_buffed")

func _find_child_of_type(node: Node, type: Variant) -> Node:
	for child in node.get_children():
		if is_instance_of(child, type):
			return child
	return null
