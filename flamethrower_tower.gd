extends TowerBase

@export var damage_per_tick: float = 5
@export var damage_frequency: float = 0.15
@onready var head = $Head
@onready var flame_anim = $Head/AnimatedSprite2D
@onready var fire_area = $Head/FireDamageArea
@onready var damage_timer = $Head/DamageTimer

var target_zombie: Node2D = null

func _ready():
	super._ready() 
	
	flame_anim.stop()
	
	damage_timer.wait_time = damage_frequency
	damage_timer.one_shot = false
	damage_timer.timeout.connect(_on_damage_tick)

func _process(_delta):
	if not is_placed or not starter or not starter.playing:
		stop_flame()
		return

	target_zombie = get_best_target()

	if is_instance_valid(target_zombie):
		head.look_at(target_zombie.global_position)
		
		start_flame()
	else:
		stop_flame()

func _on_damage_tick():
	var bodies_in_fire = fire_area.get_overlapping_bodies()
	if bodies_in_fire.is_empty():
		return
		
	for body in bodies_in_fire:
		if body.is_in_group("zombies") and is_instance_valid(body):
			
			var is_stealth = body.get_parent().get("is_stealth")
			
			if not is_stealth:
				var shield_provider = get_shield_provider(body)
				var final_damage_target = shield_provider if shield_provider else body

				if final_damage_target.has_method("take_damage"):
					final_damage_target.take_damage(damage_per_tick)

func start_flame():
	if not flame_anim.is_playing():
		flame_anim.play()
	if damage_timer.is_stopped():
		damage_timer.start()

func stop_flame():
	flame_anim.stop()
	damage_timer.stop()
