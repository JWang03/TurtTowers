extends Area2D

@onready var telegraph_sprite = $TelegraphSprite
@onready var beam_sprite = $BeamSprite
@onready var particles = $GPUParticles2D

var damage: int = 100

func set_damage(d: int):
	damage = d

func _ready():
	beam_sprite.visible = false
	particles.emitting = false
	telegraph_sprite.modulate.a = 0.0
	#telegraph_sprite.scale = Vector2(0.1, 0.1)
	
	play_strike_sequence()

func play_strike_sequence():
	var tween = create_tween()
	
	tween.tween_property(telegraph_sprite, "modulate:a", 1.0, 1.0)
	tween.parallel().tween_property(telegraph_sprite, "scale", Vector2(0.1, 0.1), 0.3)
	
	tween.tween_callback(func():
		telegraph_sprite.visible = false
		beam_sprite.visible = true
		particles.emitting = true
		apply_damage()
	)
	
	tween.tween_property(beam_sprite, "modulate:a", 0, 1.0)
	tween.parallel().tween_property(beam_sprite, "scale:x", 0.4, 1.8)
	
	#tween.tween_interval(1.0) 
	tween.tween_callback(queue_free)

func apply_damage():
	await get_tree().physics_frame
	var bodies = get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("zombies") and body.has_method("take_damage"):
			body.take_damage(damage)
