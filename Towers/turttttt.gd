extends TowerBase

@export var attack_damage: float = 5.0
@export var slow_factor: float = 0.2
@onready var anim_sprite = $AnimatedSprite2D
var current_slow_target = null
var max_targets: int = 1

func _ready():
	super._ready()
	cost = 250
	anim_sprite.animation_looped.connect(_on_animation_looped)
	anim_sprite.stop()
	detection_area.body_entered.connect(_on_body_entered)
	detection_area.body_exited.connect(_on_body_exited)

func get_multiple_targets() -> Array:
	var bodies = detection_area.get_overlapping_bodies()
	var targets = []
	for body in bodies:
		if body.is_in_group("zombies") and body.get("is_stealth") != true:
			targets.append(body)
		if targets.size() >= max_targets:
			break
	return targets

func _on_body_entered(body):
	if body.is_in_group("zombies"):
		if is_placed and starter and starter.playing and not anim_sprite.is_playing():
			anim_sprite.play()

func _on_body_exited(body):
	if body == current_slow_target:
		clear_slow_effect(body)
		current_slow_target = null
	if get_multiple_targets().is_empty():
		anim_sprite.stop()

func _process(_delta):
	if is_placed and starter and starter.playing:
		if not get_multiple_targets().is_empty():
			if not anim_sprite.is_playing():
				anim_sprite.play()
		else:
			anim_sprite.stop()

func _on_animation_looped():
	if not starter or not starter.playing or not is_placed:
		return
	var targets = get_multiple_targets()
	if targets.is_empty():
		anim_sprite.stop()
		return
	for target in targets:
		_apply_hit(target)

func _apply_hit(target):
	if not is_instance_valid(target):
		return
	if target.has_method("take_damage"):
		target.take_damage(attack_damage)
	if max_targets == 1:
		if current_slow_target and current_slow_target != target and is_instance_valid(current_slow_target):
			clear_slow_effect(current_slow_target)
		current_slow_target = target
		if "speed_modifier" in target:
			target.speed_modifier = slow_factor
	else:
		if "speed_modifier" in target:
			target.speed_modifier = slow_factor

func clear_slow_effect(target):
	if is_instance_valid(target) and "speed_modifier" in target:
		target.speed_modifier = 1.0

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

var tower_name = "Turt Turt Turt Sahur"
var upgrades = {
	"left": {
		"name": "Tung",
		"tiers": [
			{"label": "Tung", "cost": 75},
			{"label": "Tung^2", "cost": 150},
			{"label": "Tung^3", "cost": 300}
		]
	},
	"right": {
		"name": "Larp",
		"tiers": [
			{"label": "Larp", "cost": 100},
			{"label": "Larp^2", "cost": 200},
			{"label": "Larp^3", "cost": 700}
		]
	}
}
var left_level = 0
var right_level = 0
var chosen_branch = ""

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
	elif branch == "right":
		apply_right_upgrade()
		right_level += 1
	refresh_range_indicator()
func apply_left_upgrade():
	match left_level:
		0:
			fire_rate *= .5
			tower_name = "Tung Turt Turt Sahur"
		1:
			detection_area.scale *= 1.5
			tower_name = "Tung Tung Turt Sahur"
		2:
			fire_rate *= .5
			tower_name = "Tung Tung Tung Sahur"

func apply_right_upgrade():
	match right_level:
		0:
			slow_factor *= .5
			tower_name = "Larp Turt Turt Sahur"
		1:
			max_targets = 3
			tower_name = "Larp Larp Turt Sahur"
		2:
			max_targets = 6
			tower_name = "Larp Larp Larp Sahur"
