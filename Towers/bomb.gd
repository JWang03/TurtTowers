extends Area2D

@export var damage: float = 3
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
	exploded = true
	print("bomb settled")
	
	await get_tree().physics_frame 
	
	var bodies = explosion_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("zombies"):
			body.take_damage(damage)
	
	queue_free()
