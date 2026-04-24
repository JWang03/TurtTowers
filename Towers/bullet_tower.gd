extends StaticBody2D

@export var fire_rate: float = 0.3
@export var cost: float = 25
@export var damage_multiplier: float = 1.0
@export var spread_count: int = 1
@onready var muzzle = $Muzzle
@onready var timer = $Timer
@onready var detection_area = $Range
@onready var starter = get_node("/root/Game/UI/Start_Pause/PlayButton")
@onready var upgrade_panel = get_node("/root/Game/UI/UpgradePanel")
@onready var CurrencyManager = get_node("/root/Game/UI/CurrencyManager")
var targets_in_range: Array = []
var is_placed := false
var upgrade_branch: int = -1
var upgrade_tier: int = 0

const UPGRADES = {
	0: [
		{"label": "Increased Damage - $50", "cost": 50, "damage_multiplier": 2.0},
		{"label": "Faster Fire Rate - $75", "cost": 75, "fire_rate": 0.15},
		{"label": "Double Shot - $100", "cost": 100, "spread_count": 2}
	],
	1: [
		{"label": "Increased Range - $50", "cost": 50, "range": 250},
		{"label": "Unlimited Range - $75", "cost": 75, "range": 9999},
		{"label": "Sniper - $100", "cost": 100, "damage_multiplier": 5.0, "fire_rate": 1.2}
	]
}

func _ready():
	timer.wait_time = fire_rate
	timer.one_shot = false
	detection_area.body_entered.connect(_on_zombie_entered)
	detection_area.body_exited.connect(_on_zombie_exited)
	timer.timeout.connect(_on_timer_timeout)

func _on_zombie_entered(body):
	if body.is_in_group("zombies"):
		targets_in_range.append(body)
		if timer.is_stopped():
			shoot()
			timer.start()

func _on_zombie_exited(body):
	if body in targets_in_range:
		targets_in_range.erase(body)
	if targets_in_range.is_empty():
		timer.stop()

func shoot():
	if starter.playing == true:
		if is_placed == false:
			return
		elif not targets_in_range.is_empty():
			var target = targets_in_range[0]
			var start_angle = -(0.0 * (spread_count - 1)) / 2.0
			var spread_angle = 15.0

			for i in range(spread_count):
				var bullet = BulletPool.get_bullet()
				if bullet == null:
					continue
				bullet.damage_multiplier = damage_multiplier
				var shot_rotation = muzzle.global_rotation + deg_to_rad(start_angle + (i * spread_angle)) if spread_count > 1 else muzzle.global_position.angle_to_point(target.global_position)
				bullet.activate(muzzle.global_position, shot_rotation)

func _on_timer_timeout():
	if not targets_in_range.is_empty():
		shoot()
	else:
		timer.stop()

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		upgrade_panel.show_for(self)

func apply_upgrade(branch: int):
	if upgrade_branch != -1 and upgrade_branch != branch:
		return
	if upgrade_tier >= 3:
		return
	
	var stats = UPGRADES[branch][upgrade_tier]
	var cost = stats["cost"]
	
	if CurrencyManager.current_money < cost:
		return
	
	CurrencyManager.current_money -= cost
	upgrade_branch = branch
	
	if stats.has("damage_multiplier"):
		damage_multiplier = stats["damage_multiplier"]
	if stats.has("fire_rate"):
		fire_rate = stats["fire_rate"]
		timer.wait_time = fire_rate
	if stats.has("range"):
		$Range/CollisionShape2D.shape.radius = stats["range"]
	if stats.has("spread_count"):
		spread_count = stats["spread_count"]
	
	upgrade_tier += 1
