extends TowerBase

@export var damage_per_second: float = 30
@export var rotation_speed: float = 5.0
@export var wobble_strength: float = 1.0
@export var wobble_speed: float = 50.0


@onready var head = $Head
@onready var laser_ray = $Head/RayCast2D
@onready var laser_line = $Head/Line2D

var target_zombie: Node2D = null

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

				show_beam(laser_ray.get_collision_point())

				if final_damage_target.has_method("take_damage"):
					final_damage_target.take_damage(damage_per_second * delta)
			else:
				show_beam(laser_ray.get_collision_point())
		else:
			hide_beam()
	else:
		hide_beam()

func show_beam(hit_pos):
	laser_line.visible = true
	laser_line.set_point_position(0, Vector2.ZERO)
	
	var local_hit_pos = laser_line.to_local(hit_pos)
	
	var wobble = sin(Time.get_ticks_msec() * 0.001 * wobble_speed) * wobble_strength
	var final_pos = Vector2(local_hit_pos.x, local_hit_pos.y + wobble)
	
	laser_line.set_point_position(1, final_pos)

func hide_beam():
	if laser_line:
		laser_line.visible = false
