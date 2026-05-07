extends TowerBase

@export var attack_damage: float = 5.0
@export var slow_factor: float = 0.2


@onready var anim_sprite = $AnimatedSprite2D

var current_slow_target = null

func _ready():
	super._ready()
	cost = 25
	anim_sprite.animation_looped.connect(_on_animation_looped)
	anim_sprite.stop()
	
	detection_area.body_entered.connect(_on_body_entered)
	detection_area.body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.is_in_group("zombies"):
		if is_placed and starter and starter.playing and not anim_sprite.is_playing():
			anim_sprite.play()

func _on_body_exited(body):
	if body == current_slow_target:
		clear_slow_effect(body)
		current_slow_target = null
	
	if not detection_area.has_overlapping_bodies():
		anim_sprite.stop()

func _process(_delta):
	if is_placed and starter and starter.playing:
		var target = get_best_target()
		if target:
			if not anim_sprite.is_playing():
				anim_sprite.play()
		else:
			anim_sprite.stop()

func _on_animation_looped():
	if not starter or not starter.playing or not is_placed:
		return
		
	var target = get_best_target()
	if target:
		_apply_hit(target)
	else:
		anim_sprite.stop()

func _apply_hit(target):
	if not is_instance_valid(target):
		return
	
	if target.has_method("take_damage"):
		target.take_damage(attack_damage)
	
	if current_slow_target and current_slow_target != target and is_instance_valid(current_slow_target):
		clear_slow_effect(current_slow_target)
	
	current_slow_target = target
	if "speed_modifier" in target:
		target.speed_modifier = slow_factor

func clear_slow_effect(target):
	if is_instance_valid(target) and "speed_modifier" in target:
		target.speed_modifier = 1.0
