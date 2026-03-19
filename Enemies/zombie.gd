extends CharacterBody2D

@export var speed: float = 100.0 
@export var health: float = 50.0
@export var attack_damage: int = 1

@onready var starter = get_node("/root/Game/UI/Start_Pause/PlayButton")
@onready var ray_cast = $RayCast2D 
@export var damage = 5
@onready var loss_conditions = get_node("/root/Game/UI/LossConditions")


func _ready():
	add_to_group("zombies")
	
	if ray_cast:
		ray_cast.enabled = true
		ray_cast.target_position = Vector2(-20, 0) 



func _process(delta):
	if starter.playing == true:
		var follow = get_parent()
		if follow is PathFollow2D:
			follow.progress += speed * delta
		
			var path_length = follow.get_parent().curve.get_baked_length()
			if follow.progress >= path_length:
				follow.queue_free()
				loss_conditions.spend_lives(damage)
func take_damage(amount):
	health -= amount
	modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	modulate = Color.WHITE
	
	if health <= 0:
		die()

func die():
	# Add loot drop here
	queue_free()
