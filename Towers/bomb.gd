#extends Area2D
#
#@export var damage: float = 30
#@export var friction: float = 0.1
#@onready var explosion_area = $ExplosionArea
#
#var target_pos: Vector2
#var exploded: bool = false
#
#func _process(_delta):
	#if exploded: return
	#global_position = global_position.lerp(target_pos, friction)
	#if global_position.distance_to(target_pos) < 2.0:
		#global_position = target_pos
		#explode()
#
#func explode():
	#exploded = true
	#print("bomb settled")
	#
	#await get_tree().physics_frame 
	#
	#var bodies = explosion_area.get_overlapping_bodies()
	#for body in bodies:
		#if body.is_in_group("zombies"):
			#body.take_damage(damage)
	#
	#queue_free()

extends Area2D

@export var damage: float = 15
@export var friction: float = 0.1
@onready var explosion_area = $ExplosionArea

var target_pos: Vector2
var exploded: bool = false

func _process(_delta):
	if exploded: return
	global_position = global_position.lerp(target_pos, friction)
	if global_position.distance_to(target_pos) < 2.0:
		global_position = target_pos
		explode()

func explode():
	if exploded: return
	exploded = true
	
	await get_tree().physics_frame 
	
	var bodies = explosion_area.get_overlapping_bodies()
	
	
	var shields_hit = {} 

	for body in bodies:
		if body.is_in_group("zombies") and is_instance_valid(body):
			var shield = get_shield_provider(body)
			
			if shield:
				shields_hit[shield] = true 
			else:
				body.take_damage(damage)
	
	for shield in shields_hit.keys():
		if is_instance_valid(shield):
			shield.take_damage(damage)
	
	queue_free()

func get_shield_provider(zombie):
	var protectors = get_tree().get_nodes_in_group("shield_mobs")
	for p in protectors:
		if is_instance_valid(p) and p.get("is_shield_active"):
			if p.global_position.distance_to(zombie.global_position) <= p.shield_radius:
				return p
	return null
