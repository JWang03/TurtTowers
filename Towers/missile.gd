extends Area2D
@export var damage: float = 30
@export var speed: float = 400.0
@export var turn_speed: float = 8.0
@onready var explosion_area = $ExplosionArea
var target: Node2D = null
var target_pos: Vector2
var exploded: bool = false

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("zombies"):
		explode()
func _process(delta):
	if exploded: return
	
	# If we have a live target, track its current position
	if is_instance_valid(target):
		target_pos = target.global_position
	
	var dir = (target_pos - global_position).normalized()
	
	# Rotate smoothly toward the target direction
	var target_angle = dir.angle()
	rotation = lerp_angle(rotation, target_angle, turn_speed * delta)
	
	# Move forward at speed
	global_position += dir * speed * delta
	
	if global_position.distance_to(target_pos) < 6.0:
		explode()

func set_hit_target(t: Node2D) -> void:
	target = t
	target_pos = t.global_position

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
