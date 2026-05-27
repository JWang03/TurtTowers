extends TowerBase

@export var damage: int = 100

@export var demonic_sprite: Texture2D
@export var angelic_sprite: Texture2D

var damage_multiplier = 1
@onready var range_area = $Range
@onready var collision_shape = $Range/CollisionShape2D
@onready var sprite = $Sprite2D

var beam_scene = preload("res://towers/holybeam.tscn")
var targets_in_range: Array = []
var rng = RandomNumberGenerator.new()
var time_since_last_shot: float = 0.0
var aim = false

func _ready():
	super._ready()
	cost = 125
	fire_rate = 0.4
	rng.randomize()
	range_area.body_entered.connect(_on_zombie_entered)
	range_area.body_exited.connect(_on_zombie_exited)
	

func _process(delta):
	if not is_placed or targets_in_range.is_empty():
		return
	if starter.playing == true:
		time_since_last_shot += delta
		if time_since_last_shot >= fire_rate:
			smite()
			time_since_last_shot = 0.0

func _on_zombie_entered(body):
	if is_placed:
		if body.is_in_group("zombies"):
			targets_in_range.append(body)

func _on_zombie_exited(body):
	if is_placed:
		if body in targets_in_range:
			targets_in_range.erase(body)

func smite():
	var shape = collision_shape.shape
	
	if shape is CircleShape2D:
		var radius = shape.radius

		if aim:
			var target = _get_furthest_zombie()
			if target:
				spawn_beam(target.global_position, target)
			else:
				var angle = rng.randf_range(0, TAU)
				var dist = sqrt(rng.randf()) * radius
				spawn_beam(global_position + Vector2(cos(angle), sin(angle)) * dist, null)
		else:
			var angle = rng.randf_range(0, TAU)
			var dist = sqrt(rng.randf()) * radius
			spawn_beam(global_position + Vector2(cos(angle), sin(angle)) * dist, null)

func _get_furthest_zombie() -> Node2D:
	var furthest: Node2D = null
	var furthest_ratio = -INF

	for zombie in targets_in_range:
		if not is_instance_valid(zombie):
			continue
		if zombie.get_parent().progress_ratio > furthest_ratio:
			furthest = zombie
			furthest_ratio = zombie.get_parent().progress_ratio

	return furthest

func spawn_beam(pos: Vector2, target: Node2D = null):
	var beam = beam_scene.instantiate()
	beam.damage *= damage_multiplier
	beam.target = target
	
	if chosen_branch == "right" and right_level >= 3:
		beam.beam_type = "angelic"
	elif chosen_branch == "left" and left_level >= 3:
		beam.beam_type = "demonic"
	else:
		beam.beam_type = "standard"
		
	get_tree().current_scene.add_child(beam)
	beam.global_position = pos
	if beam.has_method("set_damage"):
		beam.set_damage(damage)

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

var tower_name = "Holy Crusaturt"
var upgrades = {
	"left": {
		"name": "Demonic",
		"tiers": [
			{"label": "Sinful Speed", "cost": 75},
			{"label": "Corrupted Reach", "cost": 150},
			{"label": "Abyssal Frenzy", "cost": 300}
		]
	},
	"right": {
		"name": "Angelic",
		"tiers": [
			{"label": "Righteous Wrath", "cost": 100},
			{"label": "Hallowed Might", "cost": 200},
			{"label": "Divine Providence", "cost": 700}
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
		if left_level == 3 and demonic_sprite:
			sprite.texture = demonic_sprite
			sprite.scale = Vector2(0.2, 0.2)
			
	elif branch == "right":
		apply_right_upgrade()
		right_level += 1
		if right_level == 3 and angelic_sprite:
			sprite.texture = angelic_sprite
			sprite.scale = Vector2(0.2, 0.2)
			
	refresh_range_indicator()

func apply_left_upgrade():
	match left_level:
		0: fire_rate *= .67
		1: range_area.scale *= 1.5
		2: fire_rate *= 0.5

func apply_right_upgrade():
	match right_level:
		0: 
			damage_multiplier *= 2
			fire_rate *= 1.5
		1:
			damage_multiplier *= 2
			fire_rate *= 1.5
		2: 
			aim = true
