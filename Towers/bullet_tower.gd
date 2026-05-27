extends TowerBase

@onready var muzzle = $Muzzle
@onready var timer = $Timer
@onready var sprite = $Sprite2D

@export var gunner_sprite: Texture2D
@export var marksman_sprite: Texture2D

var bullet_scene = preload("res://Towers/bullet.tscn")
var damage_multiplier = 1.0
var double_shot = false
var aimbot = false

var left_level = 0
var right_level = 0
var chosen_branch = ""
var tower_name = "The Lieuturtant"

var upgrades = {
	"left": {
		"name": "Commando",
		"tiers": [
			{"label": "Trigger Finger", "cost": 75},
			{"label": "Belt-Fed Shells", "cost": 150},
			{"label": "Dual-Wield Sergeant", "cost": 300}
		]
	},
	"right": {
		"name": "Marksman",
		"tiers": [
			{"label": "Eagle Eye", "cost": 100},
			{"label": "High Caliber Bullets", "cost": 200},
			{"label": "Targeting Matrix", "cost": 700}
		]
	}
}

func _ready():
	super._ready()
	cost = 25.0
	fire_rate = 0.2
	timer.wait_time = fire_rate
	timer.one_shot = false
	
	timer.timeout.connect(_on_timer_timeout)
	detection_area.body_entered.connect(_on_zombie_entered)

func _process(_delta: float) -> void:
	timer.wait_time = fire_rate
	
	var target = get_best_target()
	if target:
		look_at(target.global_position)
		
		if sprite.texture == marksman_sprite or sprite.texture == gunner_sprite:
			rotation += 0
		else:
			rotation += PI 
		
		var angle = wrapf(rotation, -PI, PI)
		
		if abs(angle) > PI / 2:
			sprite.flip_v = true
		else:
			sprite.flip_v = false

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
	if not detection_area.has_overlapping_bodies():
		timer.stop()

func attempt_shot():
	if not is_placed:
		return
	var target = get_best_target()
	if not target or not bullet_scene:
		return
	
	var tween = create_tween()
	tween.tween_property(sprite, "offset:y", 10.0, 0.05) 
	tween.tween_property(sprite, "offset:y", 0.0, 0.1)
	
	var shield_provider = get_shield_provider(target)
	var final_target = shield_provider if shield_provider else target
	
	if double_shot:
		for offset_val in [-5, 5]:
			_fire_bullet(final_target, offset_val)
	else:
		_fire_bullet(final_target, 0)

func _fire_bullet(final_target: Node2D, side_offset: float):
	var bullet = bullet_scene.instantiate()
	bullet.damage *= damage_multiplier
	
	if aimbot:
		bullet.speed *= 1.5
		
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = muzzle.global_position
	bullet.look_at(final_target.global_position)
	
	if side_offset != 0:
		var perp = Vector2(-sin(bullet.rotation), cos(bullet.rotation))
		bullet.global_position += perp * side_offset
		
	if bullet.has_method("set_hit_target"):
		bullet.set_hit_target(final_target)


func purchase_upgrade(branch: String):
	if chosen_branch != "" and chosen_branch != branch:
		return
	var ucost = 0
	if branch == "left":
		ucost = upgrades["left"]["tiers"][left_level]["cost"]
	elif branch == "right":
		ucost = upgrades["right"]["tiers"][right_level]["cost"]
	# block tier 3 if another tower already has it
	if branch == "left" and left_level == 2 and not UpgradeManager.can_purchase_tier3_left():
		return
	if branch == "right" and right_level == 2 and not UpgradeManager.can_purchase_tier3_right():
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
		if left_level == 3 and gunner_sprite:
			sprite.texture = gunner_sprite
			UpgradeManager.register_tier3_left()
			
	elif branch == "right":
		apply_right_upgrade()
		right_level += 1
		if right_level == 3 and marksman_sprite:
			sprite.texture = marksman_sprite
			UpgradeManager.register_tier3_right()
			
	refresh_range_indicator()

func apply_left_upgrade():
	match left_level:
		0: fire_rate *= .8
		1: fire_rate *= .667
		2: double_shot = true

func apply_right_upgrade():
	match right_level:
		0: detection_area.scale *= 1.5
		1: 
			damage_multiplier *= 5.0
			fire_rate *= 1.5
		2:
			aimbot = true
			detection_area.scale *= 2
			damage_multiplier *= 3
			fire_rate *= 2.2

func sell() -> void:
		if left_level >= 3:
			UpgradeManager.unregister_tier3_left()
		if right_level >= 3:
			UpgradeManager.unregister_tier3_right()
		super.sell()
