extends TowerBase

@onready var muzzle = $Muzzle
@onready var timer = $Timer
@onready var sprite = $Sprite2D

var black_hole_scene = preload("res://Towers/blackhole.tscn")

@export var left_sprite: Texture2D
@export var right_sprite: Texture2D

@export var lead_distance: float = 60.0
var multi_hole_active: bool = false
var hole_count: int = 1
var hole_pull_multiplier: float = 1.0
var hole_scale_multiplier: float = 1.0
var hole_duration_multiplier: float = 1.0

var left_level = 0
var right_level = 0
var chosen_branch = ""
var tower_name = "Graviturt"

var recoil_tween: Tween

var upgrades = {
	"left": {
		"name": "Scatter",
		"tiers": [
			{"label": "Twin Holes", "cost": 200},
			{"label": "Triple Alpha Process", "cost": 800},
			{"label": "Hole Barrage", "cost": 4000}
		]
	},
	"right": {
		"name": "Singularity",
		"tiers": [
			{"label": "Stronger Pull", "cost": 500},
			{"label": "Extended Duration", "cost": 1000},
			{"label": "Event Horizon", "cost": 10000}
		]
	}
}

func _ready():
	super._ready()
	cost = 225
	fire_rate = 4.0
	timer.wait_time = fire_rate
	timer.one_shot = false
	timer.timeout.connect(_on_timer_timeout)
	detection_area.body_entered.connect(_on_zombie_entered)



func _process(_delta: float) -> void:
	if starter.playing == true:
		timer.wait_time = fire_rate
	
		var target = get_best_target()
		if target:
			look_at(target.global_position)
		
			rotation += PI
		
			var angle = wrapf(rotation, -PI, PI)
			if abs(angle) > PI / 2:
				sprite.flip_v = true
			else:
				sprite.flip_v = false

func _on_zombie_entered(body):
	if body.is_in_group("zombies") and timer.is_stopped():
		attempt_shot()
		timer.start()

func _on_timer_timeout():
	if detection_area.has_overlapping_bodies():
		attempt_shot()
	else:
		timer.stop()

func attempt_shot():
	if not is_placed:
		timer.stop()
		return
	var target = get_best_target()
	if not target:
		timer.stop()
		return

	if recoil_tween:
		recoil_tween.kill()
	recoil_tween = create_tween()
	var recoil_dir = 12.0 if not sprite.flip_v else -12.0
	recoil_tween.tween_property(sprite, "offset:y", recoil_dir, 0.05).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	recoil_tween.tween_property(sprite, "offset:y", 0.0, 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)

	var follower = get_path_follower(target)
	var path = follower.get_parent() if follower else null

	if multi_hole_active and follower and path:
		var path_len = path.curve.get_baked_length()
		var spacing = 80.0
		
		var half_spread = (spacing * (hole_count - 1)) / 2.0
		var start_progress = follower.progress + lead_distance - half_spread
		
		for i in range(hole_count):
			var future_progress = start_progress + (spacing * i)
			
			future_progress = clamp(future_progress, 0, path_len)
			
			var local_pos = path.curve.sample_baked(future_progress)
			var spawn_pos = path.to_global(local_pos)
			_spawn_hole(spawn_pos)
	else:
		var spawn_pos = target.global_position
		if follower and path:
			var future_progress = follower.progress + lead_distance
			future_progress = min(future_progress, path.curve.get_baked_length())
			spawn_pos = path.to_global(path.curve.sample_baked(future_progress))
		_spawn_hole(spawn_pos)

func _spawn_hole(pos: Vector2):
	var bh = black_hole_scene.instantiate()
	bh.target_pos = pos
	bh.pull_strength *= hole_pull_multiplier
	bh.duration *= hole_duration_multiplier
	bh.base_scale = hole_scale_multiplier
	get_tree().current_scene.add_child(bh)
	bh.global_position = muzzle.global_position

func get_path_follower(node: Node) -> PathFollow2D:
	var current = node
	while current != null:
		if current is PathFollow2D:
			return current
		current = current.get_parent()
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

func _refresh_visuals():
	if left_level >= 3 and left_sprite:
		sprite.texture = left_sprite
	elif right_level >= 3 and right_sprite:
		sprite.texture = right_sprite
		sprite.scale*=.8

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
		0:
			multi_hole_active = true
			hole_count = 2
			hole_pull_multiplier = 0.7
			hole_scale_multiplier = 0.6
		1:
			hole_count = 3
		2:
			hole_count = 5
			fire_rate *= 0.75

func apply_right_upgrade():
	match right_level:
		0:
			hole_pull_multiplier = 1.8
			hole_scale_multiplier = 1.4
		1:
			hole_duration_multiplier = 2.0
			hole_scale_multiplier = 1.7
		2:
			hole_pull_multiplier = 3
			hole_scale_multiplier = 2.4
			hole_duration_multiplier = 1.8

func sell() -> void:
		if left_level >= 3:
			UpgradeManager.unregister_tier3_left(tower_name)
		if right_level >= 3:
			UpgradeManager.unregister_tier3_right(tower_name)
		super.sell()
	
