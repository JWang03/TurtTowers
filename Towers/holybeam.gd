extends Area2D

@onready var telegraph_sprite = $TelegraphSprite
@onready var beam_sprite = $BeamSprite
@onready var particles = $GPUParticles2D

var damage: int = 100
var target: Node2D = null  # set this from the tower when aim = true

func set_damage(d: int):
	damage = d

func _ready():
	beam_sprite.visible = false
	particles.emitting = false
	telegraph_sprite.modulate.a = 0.0
	play_strike_sequence()

func _process(_delta):
	if target and is_instance_valid(target):
		global_position = target.global_position

func play_strike_sequence():
	var tween = create_tween()

	tween.tween_property(telegraph_sprite, "modulate:a", 1.0, 1.0)
	tween.parallel().tween_property(telegraph_sprite, "scale", Vector2(0.1, 0.1), 0.3)

	tween.tween_callback(func():
		target = null  # stop tracking, lock in place
		telegraph_sprite.visible = false
		beam_sprite.visible = true
		particles.emitting = true
		apply_damage()
	)

	tween.tween_property(beam_sprite, "modulate:a", 0, 1.0)
	tween.parallel().tween_property(beam_sprite, "scale:x", 0.4, 1.8)
	tween.tween_callback(queue_free)

func get_shield_provider(zombie):
	var protectors = get_tree().get_nodes_in_group("shield_mobs")
	for p in protectors:
		if is_instance_valid(p) and p.get("is_shield_active"):
			var dist = p.global_position.distance_to(zombie.global_position)
			if dist <= p.shield_radius:
				return p
	return null

func apply_damage():
	await get_tree().physics_frame
	var bodies = get_overlapping_bodies()
	
	var shields_hit = {} 

	for body in bodies:
		if body.is_in_group("zombies") and is_instance_valid(body):
			var shield = get_shield_provider(body)
			
			if shield:
				shields_hit[shield] = true 
			else:
				if body.has_method("take_damage"):
					body.take_damage(damage)
	
	for shield in shields_hit.keys():
		if is_instance_valid(shield):
			shield.take_damage(damage)
