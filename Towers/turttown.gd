extends StaticBody2D

const SPEED_MULT := 3.0
const RANGE_MULT := 10.0
const TILE_SIZE := 54.0
const ADJ_MULT := 1.5
const MIN_WAIT := 0.01
const RANGE_NODE := "Range"

@export var cost: float = 10

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
		return
	var dist := global_position.distance_to((node as Node2D).global_position)
	if dist <= 0.5 or dist > TILE_SIZE * ADJ_MULT:
		return
	_apply_buff(node)
	node.tree_exiting.connect(_on_tower_exiting.bind(node))

func _on_tower_exiting(tower: Node) -> void:
	_buffed.erase(tower)

func _apply_buff(tower: Node) -> void:
	var d := {}

	var timer := _child_of_type(tower, Timer) as Timer
	if timer:
		d["timer"] = timer; d["orig_wait"] = timer.wait_time
		timer.wait_time = max(timer.wait_time / SPEED_MULT, MIN_WAIT)

	var anim := _child_of_type(tower, AnimatedSprite2D) as AnimatedSprite2D
	if anim:
		d["anim"] = anim; d["orig_speed"] = anim.speed_scale
		anim.speed_scale *= SPEED_MULT

	var fr = tower.get("fire_rate")
	if fr != null and typeof(fr) in [TYPE_FLOAT, TYPE_INT]:
		d["fr_node"] = tower; d["orig_fr"] = float(fr)
		tower.set("fire_rate", max(float(fr) / SPEED_MULT, MIN_WAIT))

	var rng := tower.find_child(RANGE_NODE, true, false) as Area2D
	if rng:
		var cs := _child_of_type(rng, CollisionShape2D) as CollisionShape2D
		if cs and cs.shape:
			d["shape"] = cs
			if cs.shape is CircleShape2D:
				d["orig_r"] = cs.shape.radius; cs.shape.radius *= RANGE_MULT
			elif cs.shape is CapsuleShape2D:
				d["orig_cr"] = cs.shape.radius; cs.shape.radius *= RANGE_MULT

	_buffed[tower] = d
	tower.set_meta("turttown_buffed", true)

func _remove_buff(tower: Node) -> void:
	if not _buffed.has(tower):
		return
	var d: Dictionary = _buffed[tower]

	var timer := d.get("timer") as Timer
	if timer and is_instance_valid(timer):
		timer.wait_time = d.get("orig_wait", timer.wait_time)

	var anim := d.get("anim") as AnimatedSprite2D
	if anim and is_instance_valid(anim):
		anim.speed_scale = d.get("orig_speed", anim.speed_scale)

	var fr_node = d.get("fr_node")
	if fr_node != null and is_instance_valid(fr_node) and d.has("orig_fr"):
		fr_node.set("fire_rate", d["orig_fr"])

	var cs := d.get("shape") as CollisionShape2D
	if cs and is_instance_valid(cs) and cs.shape:
		if cs.shape is CircleShape2D and d.has("orig_r"):
			cs.shape.radius = d["orig_r"]
		elif cs.shape is CapsuleShape2D and d.has("orig_cr"):
			cs.shape.radius = d["orig_cr"]

	_buffed.erase(tower)
	if is_instance_valid(tower) and tower.has_meta("turttown_buffed"):
		tower.remove_meta("turttown_buffed")

func _child_of_type(node: Node, type: Variant) -> Node:
	for child in node.get_children():
		if is_instance_of(child, type):
			return child
	return null
