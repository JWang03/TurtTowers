extends CharacterBody2D

@export var speed: float = -30.0 # Negative because we move left
@export var health: int = 10
@export var attack_damage: int = 1

@onready var ray_cast = $RayCast2D # Used to detect plants in front

var is_eating: bool = false

func _ready():
	# Crucial: Add the zombie to the "zombies" group so the bullet/tower can see it
	add_to_group("zombies")
	
	# If using a RayCast, make sure it's enabled and pointing left
	if ray_cast:
		ray_cast.enabled = true
		ray_cast.target_position = Vector2(-20, 0) 

func _physics_process(delta):
	if not is_eating:
		# Simple leftward movement
		velocity.x = speed
		move_and_slide()
		check_for_plants()
	else:
		# Logic for eating plants would go here
		pass

func check_for_plants():
	if ray_cast and ray_cast.is_colliding():
		var collider = ray_cast.get_collider()
		if collider.is_in_group("plants"):
			start_eating(collider)

func start_eating(plant):
	is_eating = true
	print("Eating plant!")
	# You would start an animation/timer here to damage the plant
	# When the plant is dead (queue_free), set is_eating = false

func take_damage(amount: int):
	health -= amount
	# Visual feedback: Flash red briefly
	modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	modulate = Color.WHITE
	
	if health <= 0:
		die()

func die():
	# Add particles or gold drop here
	queue_free()
