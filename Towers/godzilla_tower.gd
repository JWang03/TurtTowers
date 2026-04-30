extends StaticBody2D

@export var damage_per_second: float = 30
@export var rotation_speed: float = 5.0
@export var wobble_strength: float = 1.0
@export var wobble_speed: float = 50.0
@export var cost: float = 25

@onready var starter = get_tree().current_scene.find_child("PlayButton", true, false)
@onready var head = $Head
@onready var laser_ray = $Head/RayCast2D
@onready var laser_line = $Head/Line2D
@onready var range_area = $Range

var is_placed := false
var target_zombie: CharacterBody2D = null

func _process(delta):
	if starter.playing == true:
		if is_placed == false:
			return
		else:
			update_target()
			if target_zombie and is_instance_valid(target_zombie):
				head.look_at(target_zombie.global_position)
				
				laser_ray.force_raycast_update()
				
				if laser_ray.is_colliding():
					var hit_collider = laser_ray.get_collider()
					if hit_collider.is_in_group("zombies"):
						show_beam(laser_ray.get_collision_point())
						hit_collider.take_damage(damage_per_second * delta)
					else:
						hide_beam()
				else:
					hide_beam()
			else:
				hide_beam()
	#update_target()
	#
	#if target_zombie and is_instance_valid(target_zombie):
		#var target_dir = (target_zombie.global_position - head.global_position).angle()
		#head.rotation = lerp_angle(head.rotation, target_dir, rotation_speed * delta)
		#
		#if laser_ray.is_colliding() and laser_ray.get_collider() == target_zombie:
			#print("hitting: ", laser_ray.get_collider().name)
			#show_beam(laser_ray.get_collision_point())
			#target_zombie.take_damage(damage_per_second * delta)
		#else:
			#hide_beam()
	#else:
		#hide_beam()

func update_target():
	var bodies = range_area.get_overlapping_bodies()
	var zombies = []
	for b in bodies:
		if b.is_in_group("zombies"):
			zombies.append(b)
	
	if zombies.size() > 0:
		zombies.sort_custom(func(a, b): return a.global_position.x < b.global_position.x)
		target_zombie = zombies[0]
	else:
		target_zombie = null
func show_beam(hit_pos):
	laser_line.visible = true
	laser_line.set_point_position(0, Vector2.ZERO)
	var local_hit_pos = laser_line.to_local(hit_pos)
	var wobble = sin(Time.get_ticks_msec() * 0.001 * wobble_speed) * wobble_strength
	var final_pos = Vector2(local_hit_pos.x, local_hit_pos.y + wobble)
	
	laser_line.set_point_position(1, final_pos)
	
	#laser_line.visible = true
	#laser_line.set_point_position(0, Vector2.ZERO) 
	##var local_hit_pos = head.to_local(hit_pos)
	##laser_line.set_point_position(1, local_hit_pos)
	#laser_line.set_point_position(1, head.to_local(hit_pos))
func hide_beam():
	laser_line.visible = false
