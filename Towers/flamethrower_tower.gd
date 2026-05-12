extends TowerBase

@export var damage_per_tick: float = 5
@export var damage_frequency: float = 0.15
@onready var head = $Head
@onready var flame_anim = $Head/AnimatedSprite2D
@onready var fire_area = $Head/FireDamageArea
@onready var damage_timer = $Head/DamageTimer

var target_zombie: Node2D = null
var slow_active: bool = false
var armor_shred_active: bool = false
var flashpoint_active: bool = false

func _ready():
	super._ready()
	cost = 50
	flame_anim.stop()
	damage_timer.wait_time = damage_frequency
	damage_timer.one_shot = false
	damage_timer.timeout.connect(_on_damage_tick)

func _process(_delta):
	if not is_placed or not starter or not starter.playing:
		stop_flame()
		return
	target_zombie = get_best_target()
	if is_instance_valid(target_zombie):
		head.look_at(target_zombie.global_position)
		start_flame()
	else:
		stop_flame()

func _on_damage_tick():
	var bodies_in_fire = fire_area.get_overlapping_bodies()
	if bodies_in_fire.is_empty():
		return

	for body in bodies_in_fire:
		if body.is_in_group("zombies") and is_instance_valid(body):
			var is_stealth = body.get_parent().get("is_stealth")
			if not is_stealth:
				var shield_provider = get_shield_provider(body)
				var final_damage_target = shield_provider if shield_provider else body

				if slow_active:
					if "speed_modifier" in body:
						body.speed_modifier = 0.6

				if armor_shred_active:
					if "damage_taken_multiplier" in body:
						body.damage_taken_multiplier = 1.3

				if flashpoint_active:
					body.is_burning = true

				if final_damage_target.has_method("take_damage"):
					final_damage_target.take_damage(damage_per_tick)

func start_flame():
	if not flame_anim.is_playing():
		flame_anim.play()
	if damage_timer.is_stopped():
		damage_timer.start()

func stop_flame():
	flame_anim.stop()
	damage_timer.stop()
	# clear debuffs when flame stops
	if slow_active or armor_shred_active:
		for body in fire_area.get_overlapping_bodies():
			if body.is_in_group("zombies") and is_instance_valid(body):
				if "speed_modifier" in body:
					body.speed_modifier = 1.0
				if "damage_taken_multiplier" in body:
					body.damage_taken_multiplier = 1.0

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

var tower_name = "Flameturter"
var upgrades = {
	"left": {
		"name": "Inferno",
		"tiers": [
			{"label": "Hotter Flames", "cost": 75},
			{"label": "Wider Spread", "cost": 150},
			{"label": "Napalm", "cost": 300}
		]
	},
	"right": {
		"name": "Crowd Control",
		"tiers": [
			{"label": "Scorched Earth", "cost": 100},
			{"label": "Weaken", "cost": 200},
			{"label": "Flashpoint", "cost": 700}
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
		0:
			damage_per_tick *= 2.0
		1:
			fire_area.scale *= 1.5
		2:
			# Napalm handled in zombie script via is_burning
			flashpoint_active = true

func apply_right_upgrade():
	match right_level:
		0:
			slow_active = true
		1:
			armor_shred_active = true
		2:
			flashpoint_active = true
