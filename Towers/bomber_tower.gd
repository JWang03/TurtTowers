extends TowerBase

@onready var muzzle = $Muzzle
@onready var timer = $Timer
@onready var sprite = $Sprite2D

@export var cluster_bomber_sprite: Texture2D
@export var missile_menace_sprite: Texture2D

var damage_multiplier = 1.0
var double_shot = false
var triple_shot = false
var quad_shot = false
var bomb_scene = preload("res://Towers/bomb.tscn")

var tower_name = "TNTurt"
var left_level = 0
var right_level = 0
var chosen_branch = ""
var recoil_tween: Tween

var upgrades = {
	"left": {
		"name": "Cluster Bomber",
		"tiers": [
			{"label": "+1 Bomb", "cost": 75},
			{"label": "+1 Bomb", "cost": 150},
			{"label": "+1 Bomb", "cost": 300}
		]
	},
	"right": {
		"name": "Missile Menace",
		"tiers": [
			{"label": "Faster Fire", "cost": 100},
			{"label": "Increased Range", "cost": 200},
			{"label": "Homing Missiles", "cost": 300}
		]
	}
}

func _ready():
	super._ready()
	cost = 75
	fire_rate = 2.0
	timer.wait_time = fire_rate
	timer.timeout.connect(_on_timer_timeout)
	detection_area.body_entered.connect(_on_zombie_entered)

func _process(_delta: float) -> void:
	timer.wait_time = fire_rate
	
	var target = get_best_target()
	if target:
		look_at(target.global_position)
		if sprite.texture == cluster_bomber_sprite or sprite.texture == missile_menace_sprite:
			rotation += PI
		else:
			rotation += PI 
		
		var angle = wrapf(rotation, -PI, PI)
		if abs(angle) > PI / 2:
			sprite.flip_v = true
		else:
			sprite.flip_v = false

func _on_zombie_entered(body):
	if body.is_in_group("zombies") and timer.is_stopped():
		shoot()
		timer.start()

func _on_timer_timeout():
	shoot()
	if not detection_area.has_overlapping_bodies():
		timer.stop()

func shoot():
	if not is_placed:
		return

	var target = get_best_target()
	if not target or not bomb_scene:
		return

	if recoil_tween:
		recoil_tween.kill()
	
	recoil_tween = create_tween()
	var recoil_dir = 15.0 if not sprite.flip_v else -15.0
	
	# Fast kick out, smooth return
	recoil_tween.tween_property(sprite, "offset:y", recoil_dir, 0.05).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	recoil_tween.tween_property(sprite, "offset:y", 0.0, 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)

	var shield_provider = get_shield_provider(target)
	var final_target = shield_provider if shield_provider else target

	var offsets: Array
	if quad_shot:
		offsets = [-15, -5, 5, 15]
	elif triple_shot:
		offsets = [-10, 0, 10]
	elif double_shot:
		offsets = [-5, 5]
	else:
		offsets = [0]

	for offset in offsets:
		var bomb = bomb_scene.instantiate()
		bomb.damage *= damage_multiplier
		get_tree().current_scene.add_child(bomb)
		bomb.global_position = muzzle.global_position
		bomb.target_pos = final_target.global_position
		
		if offset != 0:
			var dir = (final_target.global_position - muzzle.global_position).normalized()
			var perp = Vector2(-dir.y, dir.x)
			bomb.global_position += perp * offset
			bomb.target_pos = final_target.global_position + perp * offset

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

func purchase_upgrade(branch: String):
	if chosen_branch != "" and chosen_branch != branch:
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
	if chosen_branch == "":
		chosen_branch = branch  # only set AFTER confirming purchase
	if branch == "left":
		apply_left_upgrade()
		left_level += 1
		if left_level == 3 and cluster_bomber_sprite:
			sprite.texture = cluster_bomber_sprite
			
	elif branch == "right":
		apply_right_upgrade()
		right_level += 1
		if right_level == 3 and missile_menace_sprite:
			sprite.texture = missile_menace_sprite
			
	refresh_range_indicator()

func apply_left_upgrade():
	match left_level:
		0: double_shot = true
		1:
			double_shot = false
			triple_shot = true
		2:
			triple_shot = false
			quad_shot = true

func apply_right_upgrade():
	match right_level:
		0: fire_rate *= 0.5
		1: detection_area.scale *= 2
		2: bomb_scene = preload("res://Towers/missile.tscn")
