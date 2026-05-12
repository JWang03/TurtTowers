extends TowerBase

@export var damage_per_second: float = 30
@export var rotation_speed: float = 5.0
@export var wobble_strength: float = 1.0
@export var wobble_speed: float = 50.0

@onready var head = $Head
@onready var laser_ray = $Head/RayCast2D
@onready var laser_line = $Head/Line2D
@onready var laser_ray2 = $Head/RayCast2D2
@onready var laser_line2 = $Head/Line2D2

var target_zombie: Node2D = null
var target_zombie2: Node2D = null
var dual_beam: bool = false

func _ready():
	super._ready()
	cost = 25
	hide_beam()

func _process(delta):
	if not is_placed or not starter or not starter.playing:
		hide_beam()
		return

	target_zombie = get_best_target()

	if is_instance_valid(target_zombie):
		head.look_at(target_zombie.global_position)
		laser_ray.force_raycast_update()
		if laser_ray.is_colliding():
			var hit_collider = laser_ray.get_collider()
			if hit_collider and hit_collider.is_in_group("zombies"):
				var shield_provider = get_shield_provider(hit_collider)
				var final_damage_target = shield_provider if shield_provider else hit_collider
				show_beam(laser_ray.get_collision_point(), laser_line)
				if final_damage_target.has_method("take_damage"):
					final_damage_target.take_damage(damage_per_second * delta)
			else:
				show_beam(laser_ray.get_collision_point(), laser_line)
		else:
			laser_line.visible = false
	else:
		laser_line.visible = false

	if dual_beam:
		# find a second target that isn't the first
		var bodies = detection_area.get_overlapping_bodies().filter(func(b):
			return b.is_in_group("zombies") and b != target_zombie and b.get("is_stealth") != true
		)
		if not bodies.is_empty():
			target_zombie2 = bodies[0]
			laser_ray2.look_at(target_zombie2.global_position)
			laser_ray2.force_raycast_update()
			if laser_ray2.is_colliding():
				var hit_collider2 = laser_ray2.get_collider()
				if hit_collider2 and hit_collider2.is_in_group("zombies"):
					var shield_provider2 = get_shield_provider(hit_collider2)
					var final_damage_target2 = shield_provider2 if shield_provider2 else hit_collider2
					show_beam(laser_ray2.get_collision_point(), laser_line2)
					if final_damage_target2.has_method("take_damage"):
						final_damage_target2.take_damage(damage_per_second * delta)
				else:
					show_beam(laser_ray2.get_collision_point(), laser_line2)
			else:
				laser_line2.visible = false
		else:
			laser_line2.visible = false
			target_zombie2 = null
	else:
		laser_line2.visible = false

func show_beam(hit_pos: Vector2, line: Line2D):
	line.visible = true
	line.set_point_position(0, Vector2.ZERO)
	var local_hit_pos = line.to_local(hit_pos)
	var wobble = sin(Time.get_ticks_msec() * 0.001 * wobble_speed) * wobble_strength
	line.set_point_position(1, Vector2(local_hit_pos.x, local_hit_pos.y + wobble))

func hide_beam():
	if laser_line:
		laser_line.visible = false
	if laser_line2:
		laser_line2.visible = false

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

var tower_name = "Turtranosaurus Rex"
var upgrades = {
	"left": {
		"name": "Twin Peaks",
		"tiers": [
			{"label": "Wider Beam", "cost": 75},
			{"label": "Widest Beam", "cost": 150},
			{"label": "Dual Beam", "cost": 300}
		]
	},
	"right": {
		"name": "Atomic",
		"tiers": [
			{"label": "Supercharged", "cost": 100},
			{"label": "Critical Mass", "cost": 200},
			{"label": "Meltdown", "cost": 700}
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
			damage_per_second *= 1.5
			laser_line.width *= 1.5
		1:
			damage_per_second *= 1.5
			laser_line.width *= 1.5
		2:
			dual_beam = true
			laser_line2.width = laser_line.width

func apply_right_upgrade():
	match right_level:
		0:
			damage_per_second *= 2
			laser_line.width *= 2
		1:
			damage_per_second *= 2
		2:
			damage_per_second *= 2
			laser_line.width *= 2
