extends Area2D

@export var pull_strength: float = 150.0
@export var duration: float = 4.0
@export var friction: float = 0.08
@export var damage_per_second: float = 5.0

@onready var pull_area = $ExplosionArea
var target_pos: Vector2
var is_active: bool = false

func _process(delta):
	if not is_active:
		global_position = global_position.lerp(target_pos, friction)
		
		if global_position.distance_to(target_pos) < 3.0:
			activate_black_hole()
	else:
		visual_rotation(delta)
		pull_entities(delta)

func activate_black_hole():
	is_active = true
	
	var t = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	t.tween_property(self, "scale", Vector2(1.5, 1.5), 0.5)
	
	await get_tree().create_timer(duration).timeout
	
	var t2 = create_tween()
	t2.tween_property(self, "scale", Vector2.ZERO, 0.3)
	t2.finished.connect(queue_free)

func pull_entities(delta):
	var bodies = pull_area.get_overlapping_bodies()
	
	for body in bodies:
		if body.is_in_group("zombies"):
			var x_diff = abs(global_position.x - body.global_position.x)
			
			if x_diff < 15.0:
				var dist = global_position.distance_to(body.global_position)
				var soft_pull = pull_strength * (1.0 / max(dist, 1.0)) 
				
				var direction = (global_position - body.global_position).normalized()
				body.global_position += direction * soft_pull * delta
			
			if body.has_method("take_damage"):
				body.take_damage(damage_per_second * delta)
#func pull_entities(delta):
	#var bodies = pull_area.get_overlapping_bodies()
	#
	#for body in bodies:
		#if body.is_in_group("zombies"):
			#var direction = (global_position - body.global_position).normalized()
			#
			#body.global_position += direction * pull_strength * delta
			#
			#if body.has_method("take_damage"):
				#body.take_damage(damage_per_second * delta)

func visual_rotation(delta):
	rotation += delta * 10.0
