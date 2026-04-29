extends StaticBody2D
@export var fire_rate: float = 0.2
@export var is_placed: bool = false
@onready var muzzle = $Muzzle
@onready var timer = $Timer
@onready var detection_area = $Range
@onready var starter = get_node("/root/Game/UI/Start_Pause/PlayButton")
var targets_in_range: Array = []
var bullet_scene = preload("res://Towers/bullet.tscn")
var cost: int = 5
var damage_multiplier = 1.0
var double_shot = false

func _ready():
	set_process_input(true)
	timer.wait_time = fire_rate
	detection_area.body_entered.connect(_on_zombie_entered)
	detection_area.body_exited.connect(_on_zombie_exited)
	timer.timeout.connect(_on_timer_timeout)
	detection_area.input_pickable = true

func _input(event):
	if not is_placed:
		return
	if event is InputEventMouseButton and event.pressed:
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
	if body.is_in_group("zombies"):
		targets_in_range.append(body)
		if timer.is_stopped():
			attempt_shot()
			timer.start()

func _on_zombie_exited(body):
	targets_in_range.erase(body)
	if targets_in_range.is_empty():
		timer.stop()

func get_valid_target():
	targets_in_range = targets_in_range.filter(func(t): return is_instance_valid(t))
	for target in targets_in_range:
		if target.get("is_stealth") == true:
			continue
		return target
	return null

func get_shield_provider(zombie):
	var protectors = get_tree().get_nodes_in_group("shield_mobs")
	for p in protectors:
		if is_instance_valid(p) and p.get("is_shield_active"):
			var dist = p.global_position.distance_to(zombie.global_position)
			if dist <= p.shield_radius:
				return p
	return null

func attempt_shot():
	if is_placed:
		var target = get_valid_target()
		
		if target and bullet_scene:
			var shield_provider = get_shield_provider(target)
			var final_target = shield_provider if shield_provider else target
			
			if double_shot:
				var offsets = [-5, 5]
				for offset in offsets:
					var bullet = bullet_scene.instantiate()
					bullet.damage *= damage_multiplier
					get_tree().current_scene.add_child(bullet)
					bullet.global_position = muzzle.global_position
					bullet.look_at(final_target.global_position)
					var perp = Vector2(-sin(bullet.rotation), cos(bullet.rotation))
					bullet.global_position += perp * offset
					if bullet.has_method("set_hit_target"):
						bullet.set_hit_target(final_target)
			else:
				var bullet = bullet_scene.instantiate()
				bullet.damage *= damage_multiplier
				get_tree().current_scene.add_child(bullet)
				bullet.global_position = muzzle.global_position
				bullet.look_at(final_target.global_position)
				if bullet.has_method("set_hit_target"):
					bullet.set_hit_target(final_target)
		
		elif targets_in_range.is_empty():
			timer.stop()

func _on_timer_timeout():
	attempt_shot()

#Upgrading:
var tower_name = "Soldier Turtle"
var upgrades = {
	"left": {
		"name": "Machine Gunner Path",
		"tiers": [
			{"label": "+25% Fire Rate", "cost": 75},
			{"label": "+50% Fire Rate", "cost": 150},
			{"label": "Double Shot", "cost": 300}
		]
	},
	"right": {
		"name": "Sniper Path",
		"tiers": [
			{"label": "1.5x Range", "cost": 100},
			{"label": "3x Damage, .33x Fire Rate", "cost": 200},
			{"label": "Unlimited Range", "cost": 500}
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
	if branch == "left":
		apply_left_upgrade()
		left_level += 1
	elif branch == "right":
		apply_right_upgrade()
		right_level += 1

func apply_left_upgrade():
	match left_level:
		0: fire_rate *= 1.25
		1: fire_rate *= 1.5
		2: double_shot = true

func apply_right_upgrade():
	match right_level:
		0: detection_area.scale *= 1.5
		1:
			damage_multiplier *= 3.0
			fire_rate *= 0.33
		2: detection_area.scale *= 20
