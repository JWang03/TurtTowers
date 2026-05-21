extends TowerBase

@onready var head = $Head
@onready var sprite = $Sprite2D
@onready var laser_ray = $Head/RayCast2D
@onready var laser_ray2 = $Head/RayCast2D2

var laser_glow: Line2D
var laser_core: Line2D
var laser_glow2: Line2D
var laser_core2: Line2D

var left_level = 0
var right_level = 0
var chosen_branch = ""

@export var twin_peaks_sprite: Texture2D
@export var atomic_sprite: Texture2D

@export var damage_per_second: float = 30
@export var rotation_speed: float = 5.0
@export var wobble_strength: float = 1.0
@export var wobble_speed: float = 50.0

var base_beam_width: float = 10.0

var target_zombie: Node2D = null
var target_zombie2: Node2D = null
var dual_beam: bool = false

var is_recoiling: bool = false
var recoil_tween: Tween

func _ready():
	super._ready()
	cost = 50
	
	if has_node("Head/Line2D"): $Head/Line2D.queue_free()
	if has_node("Head/Line2D2"): $Head/Line2D2.queue_free()
	
	laser_glow = Line2D.new()
	laser_core = Line2D.new()
	setup_beam_pair(laser_glow, laser_core, Color(0.0, 0.6, 1.0, 0.5)) 
	
	laser_glow2 = Line2D.new()
	laser_core2 = Line2D.new()
	setup_beam_pair(laser_glow2, laser_core2, Color(0.0, 0.6, 1.0, 0.5))
	
	hide_beam()

func setup_beam_pair(glow: Line2D, core: Line2D, glow_color: Color):
	glow.begin_cap_mode = Line2D.LINE_CAP_ROUND
	glow.end_cap_mode = Line2D.LINE_CAP_ROUND
	glow.default_color = glow_color
	glow.width = base_beam_width
	glow.points = PackedVector2Array([Vector2.ZERO, Vector2.ZERO])
	
	core.begin_cap_mode = Line2D.LINE_CAP_ROUND
	core.end_cap_mode = Line2D.LINE_CAP_ROUND
	core.default_color = Color(1.0, 1.0, 1.0, 1.0)
	core.width = base_beam_width * 0.45
	core.points = PackedVector2Array([Vector2.ZERO, Vector2.ZERO])
	
	head.add_child(glow)
	head.add_child(core)

func _process(delta):
	if not is_placed or not starter or not starter.playing:
		hide_beam()
		reset_recoil()
		return

	target_zombie = get_best_target()

	if is_instance_valid(target_zombie):
		head.look_at(target_zombie.global_position)
		
		var target_rot = head.rotation
		
		if sprite.texture == twin_peaks_sprite or sprite.texture == atomic_sprite:
			sprite.rotation = target_rot + PI
		else:
			sprite.rotation = target_rot + PI
			
		var angle = wrapf(sprite.rotation, -PI, PI)
		if abs(angle) > PI / 2:
			sprite.flip_v = true
		else:
			sprite.flip_v = false
			
		laser_ray.force_raycast_update()
		if laser_ray.is_colliding():
			var hit_collider = laser_ray.get_collider()
			if hit_collider and hit_collider.is_in_group("zombies"):
				var shield_provider = get_shield_provider(hit_collider)
				var final_damage_target = shield_provider if shield_provider else hit_collider
				show_beam(laser_ray.get_collision_point(), laser_glow, laser_core)
				apply_laser_recoil()
				
				if final_damage_target.has_method("take_damage"):
					final_damage_target.take_damage(damage_per_second * delta)
			else:
				show_beam(laser_ray.get_collision_point(), laser_glow, laser_core)
		else:
			laser_glow.visible = false
			laser_core.visible = false
			if not dual_beam or not target_zombie2:
				reset_recoil()
	else:
		laser_glow.visible = false
		laser_core.visible = false
		reset_recoil()

	if dual_beam:
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
					show_beam(laser_ray2.get_collision_point(), laser_glow2, laser_core2)
					if final_damage_target2.has_method("take_damage"):
						final_damage_target2.take_damage(damage_per_second * delta)
				else:
					show_beam(laser_ray2.get_collision_point(), laser_glow2, laser_core2)
			else:
				laser_glow2.visible = false
				laser_core2.visible = false
		else:
			laser_glow2.visible = false
			laser_core2.visible = false
			target_zombie2 = null
	else:
		laser_glow2.visible = false
		laser_core2.visible = false


func apply_laser_recoil():
	var recoil_amount = 5.0 if not sprite.flip_v else -5.0
	var jitter = randf_range(-0.5, 0.5)
	sprite.offset.y = recoil_amount + jitter
	is_recoiling = true

func reset_recoil():
	if is_recoiling:
		if recoil_tween: recoil_tween.kill()
		recoil_tween = create_tween()
		recoil_tween.tween_property(sprite, "offset:y", 0.0, 0.2)
		is_recoiling = false

func show_beam(hit_pos: Vector2, glow: Line2D, core: Line2D):
	glow.visible = true
	core.visible = true
	
	glow.set_point_position(0, Vector2.ZERO)
	core.set_point_position(0, Vector2.ZERO)
	
	var local_hit_pos = head.to_local(hit_pos)
	var wobble = sin(Time.get_ticks_msec() * 0.001 * wobble_speed) * wobble_strength
	var final_target = Vector2(local_hit_pos.x, local_hit_pos.y + wobble)
	
	glow.set_point_position(1, final_target)
	core.set_point_position(1, final_target)
	
	core.width = glow.width * 0.45

func hide_beam():
	if is_instance_valid(laser_glow): laser_glow.visible = false
	if is_instance_valid(laser_core): laser_core.visible = false
	if is_instance_valid(laser_glow2): laser_glow2.visible = false
	if is_instance_valid(laser_core2): laser_core2.visible = false


var tower_name = "Turtosaurus Rex"
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
	
	if branch == "left":
		apply_left_upgrade()
		left_level += 1
		if left_level == 3 and twin_peaks_sprite:
			sprite.texture = twin_peaks_sprite
			
	elif branch == "right":
		apply_right_upgrade()
		right_level += 1
		if right_level == 3 and atomic_sprite:
			sprite.texture = atomic_sprite
			
	refresh_range_indicator()

func apply_left_upgrade():
	match left_level:
		0:
			damage_per_second *= 1.5
			laser_glow.width *= 1.5
		1:
			damage_per_second *= 1.5
			laser_glow.width *= 1.5
		2:
			dual_beam = true
			laser_glow2.width = laser_glow.width

func apply_right_upgrade():
	match right_level:
		0:
			damage_per_second *= 2
			laser_glow.width *= 2
		1:
			damage_per_second *= 2
		2:
			damage_per_second *= 2
			laser_glow.width *= 2
			laser_glow.default_color = Color(0.647, 0.0, 0.929, 1.0) * 6.0


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
