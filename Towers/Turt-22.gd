extends TowerBase

@export var flight_speed: float = 45.0
@export var spread_count: int = 4
@export var spread_angle: float = 5.0

@onready var path_follow = $Path2D/PathFollow2D
@onready var muzzle = $Path2D/PathFollow2D/Muzzle
@onready var shoot_timer = $Timer

var bullet_scene = preload("res://Towers/bullet.tscn")
var damage_multiplier: float = 1.0

func _ready():
	super._ready()
	cost = 50
	fire_rate = 0.1
	shoot_timer.wait_time = fire_rate
	shoot_timer.one_shot = false
	if not shoot_timer.timeout.is_connected(_on_shoot_timer_timeout):
		shoot_timer.timeout.connect(_on_shoot_timer_timeout)
		shoot_timer.start()

func _process(delta):
	path_follow.progress += flight_speed * delta

func _on_shoot_timer_timeout():
	shoot()

func shoot():
	if not starter.playing or not is_placed:
		return
	var start_angle = -(spread_angle * (spread_count - 1)) / 2.0
	for i in range(spread_count):
		var b = bullet_scene.instantiate()
		get_tree().root.add_child(b)
		if "damage" in b:
			b.damage = int(b.damage * damage_multiplier)
		var shot_rotation = muzzle.global_rotation + deg_to_rad(start_angle + (i * spread_angle))
		b.activate(muzzle.global_position, shot_rotation)

func _input(event):
	if not is_placed:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var mouse_pos = get_global_mouse_position()
		if global_position.distance_to(mouse_pos) <= 30.0:
			Signal_Bus.tower_selected.emit(self)

var tower_name = "Fighturt Jet"
var upgrades = {
	"left": {
		"name": "Spread",
		"tiers": [
			{"label": "Wide Burst", "cost": 100},
			{"label": "Hemisphere Fire", "cost": 250},
			{"label": "Omnidirectional", "cost": 500}
		]
	},
	"right": {
		"name": "Focused Fire",
		"tiers": [
			{"label": "Faster Shooting", "cost": 75},
			{"label": "High Caliber", "cost": 175},
			{"label": "Railgun Mode", "cost": 500}
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
			# widen spread, add more bullets to cover the arc
			spread_angle = 20.0
			spread_count = 8
		1:
			# half circle
			spread_angle = 180.0 / 7.0  # evenly covers 180 degrees with 8 bullets
			spread_count = 12
		2:
			# full 360 — evenly space bullets around the full circle
			spread_count = 24
			spread_angle = 360.0 / 24.0

func apply_right_upgrade():
	match right_level:
		0:
			# tighten to single stream, fire faster
			spread_count = 3
			spread_angle = 15
			fire_rate *= 0.5
			shoot_timer.wait_time = fire_rate
		1:
			damage_multiplier *= 2.0
			spread_count = 2
			spread_angle = 7
		2:
			# railgun — massive damage, even faster
			spread_count = 1
			spread_angle = 0
			damage_multiplier *= 2.0
			fire_rate *= 0.5
			shoot_timer.wait_time = fire_rate
