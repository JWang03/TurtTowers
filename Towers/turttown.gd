extends StaticBody2D

@export var cost: float = 75

var is_placed := false:
	set(value):
		is_placed = value
		if value:
			call_deferred("_scan_existing_towers")
var _buffed_towers: Dictionary = {}

@onready var range_area = $Range

func _ready():
	range_area.body_entered.connect(_on_body_entered)
	range_area.body_exited.connect(_on_body_exited)

func _scan_existing_towers():
	for body in range_area.get_overlapping_bodies():
		_on_body_entered(body)

func _on_body_entered(body):
	if not is_placed:
		return
	if body == self:
		return
	if not (body is StaticBody2D):
		return
	if body.is_in_group("zombies"):
		return
	if _buffed_towers.has(body):
		return
	_apply_buff(body)

func _on_body_exited(body):
	if _buffed_towers.has(body):
		_remove_buff(body)

func _apply_buff(tower):
	if not is_instance_valid(tower):
		return
	var buff_data = {}

	# Fire rate buff: reduce Timer wait_time by 10% (tower fires ~11% more shots per second)
	var timer = _find_timer(tower)
	if timer != null:
		buff_data["timer"] = timer
		buff_data["original_wait_time"] = timer.wait_time
		timer.wait_time = timer.wait_time * 0.9

	# Attack radius buff: increase Range Area2D collision shape radius by 5%
	var range_node = tower.find_child("Range", false, false)
	if range_node is Area2D:
		var shape_node = _find_collision_shape(range_node)
		if shape_node != null and shape_node.shape != null:
			var shape = shape_node.shape
			if shape is CircleShape2D:
				buff_data["shape_node"] = shape_node
				buff_data["original_radius"] = shape.radius
				shape.radius = shape.radius * 1.05
			elif shape is CapsuleShape2D:
				buff_data["shape_node"] = shape_node
				buff_data["original_capsule_radius"] = shape.radius
				shape.radius = shape.radius * 1.05

	_buffed_towers[tower] = buff_data

func _remove_buff(tower):
	if not _buffed_towers.has(tower):
		return
	var buff_data = _buffed_towers[tower]

	if buff_data.has("timer") and is_instance_valid(buff_data.get("timer")):
		buff_data["timer"].wait_time = buff_data.get("original_wait_time", buff_data["timer"].wait_time)

	if buff_data.has("shape_node") and is_instance_valid(buff_data.get("shape_node")):
		var shape_node = buff_data["shape_node"]
		if shape_node.shape != null:
			var shape = shape_node.shape
			if shape is CircleShape2D and buff_data.has("original_radius"):
				shape.radius = buff_data["original_radius"]
			elif shape is CapsuleShape2D and buff_data.has("original_capsule_radius"):
				shape.radius = buff_data["original_capsule_radius"]

	_buffed_towers.erase(tower)

func _find_timer(node: Node) -> Timer:
	for child in node.get_children():
		if child is Timer:
			return child
	return null

func _find_collision_shape(node: Node) -> CollisionShape2D:
	for child in node.get_children():
		if child is CollisionShape2D:
			return child
	return null

func _exit_tree():
	for tower in _buffed_towers.keys():
		if is_instance_valid(tower):
			_remove_buff(tower)
	_buffed_towers.clear()
