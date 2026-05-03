extends StaticBody2D

const ATTACK_SPEED_MULTIPLIER := 5
const ATTACK_RADIUS_MULTIPLIER := 1.05
const ADJACENT_ATTACK_SPEED_MULTIPLIER := 3
const TILE_SIZE := 64.0

@export var cost: float = 10
@onready var range_area: Area2D = $Range

var is_placed := false:
	set(value):
		is_placed = value
		if value:
			call_deferred("_scan_existing_towers")

var _buffed_towers: Dictionary = {}

func _ready() -> void:
	range_area.body_entered.connect(_on_body_entered)
	range_area.body_exited.connect(_on_body_exited)

func _exit_tree() -> void:
	for tower in _buffed_towers.keys():
		if is_instance_valid(tower):
			_remove_buff(tower)
	_buffed_towers.clear()

func _scan_existing_towers() -> void:
	for body in range_area.get_overlapping_bodies():
		_on_body_entered(body)

func _on_body_entered(body: Node) -> void:
	if not is_placed or body == self:
		return
	if not (body is StaticBody2D) or body.is_in_group("zombies"):
		return
	if _buffed_towers.has(body):
		return
	_apply_buff(body)

func _on_body_exited(body: Node) -> void:
	if _buffed_towers.has(body):
		_remove_buff(body)

func _get_speed_multiplier_for(tower: Node) -> float:
	var dist := global_position.distance_to(tower.global_position)
	if dist <= TILE_SIZE * 1.5:  # within 1-tile radius (diagonal included)
		return ADJACENT_ATTACK_SPEED_MULTIPLIER
	return ATTACK_SPEED_MULTIPLIER

func _apply_buff(tower: Node) -> void:
	if not is_instance_valid(tower):
		return

	var buff_data := {}
	var speed_multiplier := _get_speed_multiplier_for(tower)
	buff_data["speed_multiplier_used"] = speed_multiplier

	var attack_timer := _find_child_of_type(tower, Timer) as Timer
	if attack_timer:
		buff_data["timer"] = attack_timer
		buff_data["original_wait_time"] = attack_timer.wait_time
		attack_timer.wait_time /= speed_multiplier  # lower wait_time = faster attacks

	var tower_range := tower.find_child("Range", false, false) as Area2D
	if tower_range:
		var collision_shape := _find_child_of_type(tower_range, CollisionShape2D) as CollisionShape2D
		if collision_shape and collision_shape.shape:
			_apply_radius_buff(collision_shape, buff_data)

	_buffed_towers[tower] = buff_data

func _apply_radius_buff(collision_shape: CollisionShape2D, buff_data: Dictionary) -> void:
	var shape := collision_shape.shape
	buff_data["shape_node"] = collision_shape
	if shape is CircleShape2D:
		buff_data["original_radius"] = shape.radius
		shape.radius *= ATTACK_RADIUS_MULTIPLIER
	elif shape is CapsuleShape2D:
		buff_data["original_capsule_radius"] = shape.radius
		shape.radius *= ATTACK_RADIUS_MULTIPLIER

func _remove_buff(tower: Node) -> void:
	if not _buffed_towers.has(tower):
		return

	var buff_data: Dictionary = _buffed_towers[tower]

	var attack_timer := buff_data.get("timer") as Timer
	if attack_timer and is_instance_valid(attack_timer):
		attack_timer.wait_time = buff_data.get("original_wait_time", attack_timer.wait_time)

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
