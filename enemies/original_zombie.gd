extends CharacterBody2D

@export var speed: float = 5.0 
@export var health: float = 70.0
@export var attack_damage: int = 1

@onready var ray_cast = $RayCast2D 

var speed_modifier: float = 1.0

var is_eating: bool = false

func _ready():
	add_to_group("zombies")
	
	if ray_cast:
		ray_cast.enabled = true
		ray_cast.target_position = Vector2(-20, 0) 

func _physics_process(delta):
	if not is_eating:
		velocity.x = speed * speed_modifier
		move_and_slide()
		check_for_towers()
	else:
		# Logic for destroying mother tower would go here if we do that
		pass

func check_for_towers():
	if ray_cast and ray_cast.is_colliding():
		var collider = ray_cast.get_collider()
		if collider.is_in_group("towers"):
			start_eating(collider)

func start_eating(tower):
	is_eating = true
	print("Eating tower!")

func take_damage(amount):
	print("zombie took: ", amount, "from ", get_stack()[1].source)
	health -= amount
	modulate = Color.RED
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.1)
	
	if health <= 0:
		die()

func die():
	# Add loot drop here
	queue_free()
