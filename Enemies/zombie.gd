extends CharacterBody2D

var progress: float:
	get:
		return get_parent().progress if get_parent() is PathFollow2D else 0.0

@export var speed: float = 100.0 
@export var attack_damage: int = 1
@export var damage = 5
@export var speed_modifier = 1.0
@export var shelling_drop: int

@onready var starter = get_tree().current_scene.find_child("PlayButton", true, false)
@onready var ray_cast = $RayCast2D 
@onready var loss_conditions = get_node("/root/Game/UI/HUD/LossConditions")
@onready var currency = get_node("/root/Game/UI/HUD/CurrencyManager")
@onready var wave_manager = null

@export var max_health: float = 75.0
var health: float = max_health
@onready var health_bar = $HealthBar  # or preload and add manually
const HEALTH_BAR = preload("res://SandyShores/Scenes/HealthBar.tscn")

var bob_time: float = 0.0
@export var bob_speed: float = 6.0
@export var bob_amount: float = 5.0
@onready var sprite = $Sprite2D if has_node("Sprite2D") else $walk

#For Flameturter:
var is_burning: bool = false
var burn_damage: float = 5.0
var burn_duration: float = 4.0
var burn_timer: float = 0.0
var burn_tick_timer: float = 0.0
var damage_taken_multiplier: float = 1.0

func _ready():
	add_to_group("zombies")
	health = max_health
	var bar = HEALTH_BAR.instantiate()
	add_child(bar)
	bar.position = Vector2(0, -30)  # float it above the sprite
	health_bar = bar
	health_bar.update(health, max_health)
	bob_time = randf() * TAU
	shelling_drop = 2



func _process(delta):
	if starter.playing == true:
		bob_time += delta
		var bob_offset = sin(bob_time * bob_speed) * bob_amount
		sprite.position.y = bob_offset
		health_bar.position.y = -30 + bob_offset
		var follow = get_parent()
		if follow is PathFollow2D:
			follow.progress += speed * delta * speed_modifier
		
			var path_length = follow.get_parent().curve.get_baked_length()
			if follow.progress >= path_length:
				follow.queue_free()
				if wave_manager != null:
					wave_manager.enemy_removed()
				loss_conditions.spend_lives(damage)
			if is_burning:
				burn_timer += delta
				burn_tick_timer += delta
				if burn_tick_timer >= 0.5:
					burn_tick_timer = 0.0
					take_damage(burn_damage)
				if burn_timer >= burn_duration:
					is_burning = false
					burn_timer = 0.0
func take_damage(amount):
	health -= amount * damage_taken_multiplier
	health_bar.update(health, max_health)
	modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	modulate = Color.WHITE
	
	if health <= 0:
		die()

func die():
	# Add loot drop here
	if is_burning:
		_flashpoint_explode()
	currency.add_shellings(shelling_drop)
	if wave_manager != null:
		wave_manager.enemy_removed()
	queue_free()

func _flashpoint_explode():
	var nearby = get_tree().get_nodes_in_group("zombies")
	for zombie in nearby:
		if zombie == self or not is_instance_valid(zombie):
			continue
		if global_position.distance_to(zombie.global_position) <= 60.0:
			if zombie.has_method("take_damage"):
				zombie.take_damage(15.0)
