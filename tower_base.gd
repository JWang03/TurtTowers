extends StaticBody2D
class_name TowerBase
enum TargetMode {FIRST, WEAKEST, STRONGEST, CLOSEST}
@export var target_priority: TargetMode = TargetMode.FIRST
@export var is_placed: bool = false 
@export var fire_rate: float = 1.0
@onready var starter = get_node_or_null("/root/Game/UI/Buttons/PlayButton")
@onready var detection_area = $Range
@export var occupied_cell: Vector2i
@export var tilemap: TileMapLayer
@export var cost: float
var range_fill: Polygon2D
var range_indicator: Line2D
func _ready():
	add_to_group("towers")
	_create_range_indicator()
	Signal_Bus.tower_selected.connect(_on_tower_selected)
	Signal_Bus.tower_deselected.connect(_on_tower_deselected)
	

func _create_range_indicator():
	range_fill = Polygon2D.new()
	range_fill.color = Color(0.502, 0.502, 0.502, 0.2)
	range_fill.z_index = 100
	range_fill.z_as_relative = false
	add_child(range_fill)
	range_fill.visible = false

	range_indicator = Line2D.new()
	range_indicator.width = 3.0
	range_indicator.default_color = Color(0.0, 0.922, 0.0, 0.5)
	range_indicator.closed = true
	range_indicator.z_index = 101
	range_indicator.z_as_relative = false
	add_child(range_indicator)
	range_indicator.visible = false

func _on_tower_selected(tower):
	if tower == self:
		_show_range()
	else:
		_hide_range()

func _on_tower_deselected():
	_hide_range()

func _show_range():
	var collision = detection_area.get_node_or_null("CollisionShape2D")
	if not collision:
		return
	var shape = collision.shape
	if shape is CircleShape2D:
		var radius = shape.radius * detection_area.scale.x
		var points = PackedVector2Array()
		var segments = 64
		for i in range(segments + 1):
			var angle = (TAU / segments) * i
			points.append(Vector2(cos(angle), sin(angle)) * radius)
		range_indicator.points = points
		range_indicator.visible = true
		range_fill.polygon = points
		range_fill.visible = true

func _hide_range():
	if range_indicator:
		range_indicator.visible = false
	if range_fill:
		range_fill.visible = false

func refresh_range_indicator():
	if range_indicator and range_indicator.visible:
		_show_range()

func get_best_target() -> Node2D:
	if not is_placed or (starter and !starter.playing):
		return null
	var targets = detection_area.get_overlapping_bodies().filter(func(b): 
		var is_stealth = b.is_stealth if "is_stealth" in b else false
		return b.is_in_group("zombies") and not is_stealth
	)
	if targets.is_empty():
		return null
	match target_priority:
		TargetMode.FIRST:
			targets.sort_custom(func(a, b): 
				return (a.progress if "progress" in a else 0.0) > (b.progress if "progress" in b else 0.0))
		TargetMode.WEAKEST:
			targets.sort_custom(func(a, b): 
				return (a.health if "health" in a else 0) < (b.health if "health" in b else 0))
		TargetMode.STRONGEST:
			targets.sort_custom(func(a, b): 
				return (a.health if "health" in a else 0) > (b.health if "health" in b else 0))
		TargetMode.CLOSEST:
			targets.sort_custom(func(a, b): 
				return global_position.distance_to(a.global_position) < global_position.distance_to(b.global_position))
	return targets[0]

func get_shield_provider(zombie):
	var protectors = get_tree().get_nodes_in_group("shield_mobs")
	for p in protectors:
		if is_instance_valid(p) and p.get("is_shield_active"):
			if p.global_position.distance_to(zombie.global_position) <= p.shield_radius:
				return p
	return null

func cycle_target_mode():
	var current_index = target_priority as int
	var next_index = (current_index + 1) % TargetMode.size()
	target_priority = next_index as TargetMode
	print("Tower mode changed to: ", TargetMode.keys()[target_priority])

func _input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			var ui_node = get_node_or_null("/root/Game/UI/tower_targeting")
			if ui_node:
				ui_node.set_selected_tower(self)

func set_target_priority(new_mode_index: int):
	target_priority = new_mode_index as TargetMode
	print(name, " changed mode to: ", target_priority)

func sell() -> void:
	var currency_manager = get_node("/root/Game/UI/HUD/CurrencyManager")
	currency_manager.add_shellings(cost / 2)
	if tilemap:
		tilemap.unoccupy_cell(occupied_cell)
	queue_free()
