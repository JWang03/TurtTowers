extends "res://enemies/zombie.gd"

@export var is_boss: bool = true
var is_stealth: bool = false
var has_triggered_stealth: bool = false
@export var base_boss_speed: float = 10.0
@export var fast_speed: float = 40.0
@export var slow_speed: float = 5.0
var last_position: Vector2 = Vector2.ZERO

var speed_timer: float = 0.0
@export var speed_cycle_duration: float = 5.0 
var current_speed_state: int = 0              

@export var buff_scene: PackedScene = preload("res://enemies/buff_range.tscn")
@export var buff_cooldown: float = 4.0        
var buff_timer: float = 0.0

@export var stealth_alpha: float = 0.4

func _ready():
	super._ready()
	
	if has_node("walk"):
		$walk.play("default")
	
	last_position = global_position
	
	max_health = 100000.0
	health = max_health
	speed = base_boss_speed
	damage = 25              
	shelling_drop = 150      
	
	if health_bar:
		health_bar.update(health, max_health)

func _process(delta):
	if has_node("walk"):
		if starter.playing:
			if not $walk.is_playing():
				$walk.play()
		else:
			if $walk.is_playing():
				$walk.pause()

	if not starter.playing:
		return
	super._process(delta)
	
	if health > 0:
		_handle_sprite_flipping()
		_handle_speed_cycles(delta)
		_handle_algae_drops(delta)

func _handle_speed_cycles(delta: float):
	speed_timer += delta
	if speed_timer >= speed_cycle_duration:
		speed_timer = 0.0
		current_speed_state = (current_speed_state + 1) % 3
		
		var target_speed: float = base_boss_speed
		match current_speed_state:
			0: target_speed = base_boss_speed
			1: target_speed = fast_speed
			2: target_speed = slow_speed
			
		var speed_tween = create_tween()
		speed_tween.tween_property(self, "speed", target_speed, 0.8).set_trans(Tween.TRANS_SINE)

func _handle_algae_drops(delta: float):
	buff_timer += delta
	if buff_timer >= buff_cooldown:
		buff_timer = 0.0
		_spawn_algae_buff()

func _spawn_algae_buff():
	if buff_scene == null:
		return
		
	var buff = buff_scene.instantiate()
	buff.global_position = global_position
	get_tree().current_scene.add_child(buff)

func take_damage(amount):
	health -= amount * damage_taken_multiplier
	
	if health_bar:
		health_bar.update(health, max_health)
		
	modulate = Color(2.0, 0.5, 0.5, stealth_alpha if is_stealth else 1.0)
	await get_tree().create_timer(0.1).timeout
	
	if is_stealth:
		modulate = Color(1, 1, 1, stealth_alpha)
	else:
		modulate = Color.WHITE

	if health <= (max_health * 0.25) and not has_triggered_stealth:
		_activate_permanent_stealth()

	if health <= 0:
		die()

func _activate_permanent_stealth():
	has_triggered_stealth = true
	is_stealth = true
	
	modulate.a = stealth_alpha

func _handle_sprite_flipping():
	if has_node("walk"):
		var movement_x = global_position.x - last_position.x
		
		if movement_x > 0.1:
			$walk.flip_h = true
		elif movement_x < -0.1:
			$walk.flip_h = false
			
	last_position = global_position
