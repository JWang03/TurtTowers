extends TowerBase

@onready var muzzle = $Muzzle
@onready var timer = $Timer
var bullet_scene = preload("res://Towers/bullet.tscn")
var damage_multiplier = 1.0
var double_shot = false
var hitscan = false



func _ready():
	super._ready()
	cost = 25
	fire_rate = 0.2
	timer.wait_time = fire_rate
	timer.one_shot = false
	timer.timeout.connect(_on_timer_timeout)
	detection_area.body_entered.connect(_on_zombie_entered)

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

func _on_zombie_entered(body):
	if body.is_in_group("zombies") and timer.is_stopped():
		attempt_shot()
		timer.start()

func _on_timer_timeout():
	attempt_shot()
	if detection_area.has_overlapping_bodies():
		if timer.is_stopped():
			timer.start()
	else:
		timer.stop()

func attempt_shot():
	if not is_placed:
		return
	var target = get_best_target()
	if not target or not bullet_scene:
		return

	var shield_provider = get_shield_provider(target)
	var final_target = shield_provider if shield_provider else target

	if double_shot:
		for offset in [-5, 5]:
			_fire_bullet(final_target, offset)
	else:
		_fire_bullet(final_target, 0)

func _fire_bullet(final_target: Node2D, side_offset: float):
	var bullet = bullet_scene.instantiate()
	bullet.damage *= damage_multiplier
	if hitscan:
		bullet.speed *= 1000
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = muzzle.global_position
	bullet.look_at(final_target.global_position)
	if side_offset != 0:
		var perp = Vector2(-sin(bullet.rotation), cos(bullet.rotation))
		bullet.global_position += perp * side_offset
	if bullet.has_method("set_hit_target"):
		bullet.set_hit_target(final_target)

func _process(_delta: float) -> void:
	timer.wait_time = fire_rate

var tower_name = "Soldier Turt"
var upgrades = {
	"left": {
		"name": "Gunner",
		"tiers": [
			{"label": "Faster Shooting", "cost": 75},
			{"label": "Faster Shooting 2", "cost": 150},
			{"label": "Double Shot", "cost": 300}
		]
	},
	"right": {
		"name": "Marksman",
		"tiers": [
			{"label": "Increased Range", "cost": 100},
			{"label": "High Caliber Bullets", "cost": 200},
			{"label": "Aimbot", "cost": 700}
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

func apply_left_upgrade():
	match left_level:
		0: fire_rate *= .8
		1: fire_rate *= .667
		2: double_shot = true

func apply_right_upgrade():
	match right_level:
		0: detection_area.scale *= 1.5
		1:
			damage_multiplier *= 15.0
			fire_rate = 2
		2:
			detection_area.scale *= 20
			hitscan = true
