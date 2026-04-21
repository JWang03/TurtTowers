extends CharacterBody2D

@export var speed: float = 100.0 
@export var attack_damage: int = 1
@export var damage = 5
@export var speed_modifier = 1.0

@onready var starter = get_node("/root/Game/UI/Start_Pause/PlayButton")
@onready var ray_cast = $RayCast2D 
@onready var loss_conditions = get_node("/root/Game/UI/HUD/LossConditions")
@onready var currency = get_node("/root/Game/UI/HUD/CurrencyManager")
@onready var wave_manager = null

@export var max_health: float = 100.0
var health: float = max_health
@onready var health_bar = $HealthBar  # or preload and add manually
const HEALTH_BAR = preload("res://SandyShores/Scenes/HealthBar.tscn")

func _ready():
	add_to_group("zombies")
	health = max_health
	var bar = HEALTH_BAR.instantiate()
	add_child(bar)
	bar.position = Vector2(0, -30)  # float it above the sprite
	health_bar = bar
	health_bar.update(health, max_health)



func _process(delta):
	if starter.playing == true:
		var follow = get_parent()
		if follow is PathFollow2D:
			follow.progress += speed * delta * speed_modifier
		
			var path_length = follow.get_parent().curve.get_baked_length()
			if follow.progress >= path_length:
				follow.queue_free()
				if wave_manager != null:
					wave_manager.enemy_removed()
				loss_conditions.spend_lives(damage)
func take_damage(amount):
	health -= amount
	health_bar.update(health, max_health)
	modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	modulate = Color.WHITE
	
	if health <= 0:
		die()

func die():
	# Add loot drop here
	currency.add_shellings(2)
	if wave_manager != null:
		wave_manager.enemy_removed()
	queue_free()
