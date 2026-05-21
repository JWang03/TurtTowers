extends Area2D

@onready var telegraph_sprite = $TelegraphSprite
@onready var beam_sprite = $BeamSprite
@onready var particles = $GPUParticles2D

var damage: int = 100
var target: Node2D = null
var beam_type: String = "standard"

var line_core: Line2D
var line_glow: Line2D

func set_damage(d: int):
	damage = d

func _ready():
	beam_sprite.visible = false
	particles.emitting = false
	telegraph_sprite.modulate.a = 0.0
	
	if beam_type != "standard":
		setup_custom_beam()
	
	play_strike_sequence()

func setup_custom_beam():
	telegraph_sprite.visible = false
	beam_sprite.visible = false
	
	line_glow = Line2D.new()
	line_core = Line2D.new()
	
	for l in [line_glow, line_core]:
		l.width = 0
		l.begin_cap_mode = Line2D.LINE_CAP_ROUND
		l.end_cap_mode = Line2D.LINE_CAP_ROUND
		l.points = PackedVector2Array([Vector2(0, -1000), Vector2(0, 0)])
		add_child(l)

	if beam_type == "angelic":
		line_glow.default_color = Color(1, 0.9, 0, 0.6)
		line_core.default_color = Color(1, 1, 1, 1)
	elif beam_type == "demonic":
		line_glow.default_color = Color(0.718, 0.0, 0.0, 0.8)
		line_core.default_color = Color(0.0, 0.0, 0.0, 0.635)

func _process(_delta):
	if target and is_instance_valid(target):
		global_position = target.global_position

func play_strike_sequence():
	var tween = create_tween()

	if beam_type != "standard":
		var telegraphed_width = 15.0 if beam_type == "angelic" else 25.0
		tween.tween_property(line_glow, "width", telegraphed_width, 0.4).set_trans(Tween.TRANS_SINE)
		
		tween.tween_callback(func():
			target = null 
			particles.emitting = true
			apply_damage()
			line_glow.width = 45.0
			line_core.width = 25.0
		)
		
		tween.tween_interval(0.3) 
		
		tween.tween_property(line_core, "width", 0, 0.5)
		tween.parallel().tween_property(line_glow, "width", 0, 0.5)
		tween.parallel().tween_property(line_core, "modulate:a", 0, 0.5)
		tween.parallel().tween_property(line_glow, "modulate:a", 0, 0.5)
		
	else:
		tween.tween_property(telegraph_sprite, "modulate:a", 1.0, 1.0)
		tween.parallel().tween_property(telegraph_sprite, "scale", Vector2(0.1, 0.1), 0.3)

		tween.tween_callback(func():
			target = null 
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
