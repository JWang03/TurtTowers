extends CharacterBody2D

@export var speed := 100.0
@export var health: float = 50.0
@export var damage: int = 5         

var path_follow: PathFollow2D
@onready var sprite = $Sprite2D 
@onready var ray_cast = $RayCast2D 
@onready var loss_conditions = get_node_or_null("/root/Game/UI/LossConditions")

var is_eating: bool = false
var last_x_pos: float = 0.0

func _ready():
	add_to_group("zombies")
	last_x_pos = global_position.x
	
	var parent = get_parent()
	if parent is PathFollow2D:
		path_follow = parent
		path_follow.rotates = false
	
	if ray_cast:
		ray_cast.enabled = true

func _physics_process(delta):
	if path_follow and not is_eating:
		path_follow.progress += speed * delta
		update_direction()
		
		var path_parent = path_follow.get_parent()
		if path_parent is Path2D:
			var path_length = path_parent.curve.get_baked_length()
			if path_follow.progress >= path_length:
				reach_end()

	if not is_eating:
		check_for_towers()
		
func update_direction():
	var current_x = global_position.x
	
	if abs(current_x - last_x_pos) > 0.1:
		if current_x < last_x_pos:
			sprite.flip_h = false 
			ray_cast.target_position.x = -abs(ray_cast.target_position.x)
		else:
			sprite.flip_h = true
			ray_cast.target_position.x = abs(ray_cast.target_position.x)
			
	last_x_pos = current_x

func check_for_towers():
	if ray_cast and ray_cast.is_colliding():
		var collider = ray_cast.get_collider()
		if collider and collider.is_in_group("towers"):
			start_eating(collider)

func start_eating(_tower):
	is_eating = true
	print("Zombie on tower")

func take_damage(amount):
	health -= amount
	modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	modulate = Color.WHITE
	
	if health <= 0:
		die()

func reach_end():
	if loss_conditions:
		loss_conditions.spend_lives(damage)
	path_follow.queue_free()

func die():
	path_follow.queue_free()
