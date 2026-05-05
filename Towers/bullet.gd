extends Area2D

@export var speed: float = 1000.0
@export var damage: int = 5
var target_node = null
func _ready():
	body_entered.connect(_on_body_entered)
	$VisibleOnScreenNotifier2D.screen_exited.connect(_on_screen_exited)

func activate(pos: Vector2, rot: float):
	global_position = pos
	global_rotation = rot
	show()
	process_mode = Node.PROCESS_MODE_INHERIT

func _physics_process(delta):
	position += transform.x * speed * delta
	
func set_hit_target(node):
	target_node = node

func _on_body_entered(body):
	
	if body.is_in_group("zombies"):
		
		var shield_provider = get_shield_provider(body)
		
		if shield_provider != null:
			shield_provider.take_damage(damage)
		else:
			if body.has_method("take_damage"):
				body.take_damage(damage)
		
		queue_free()

func get_shield_provider(zombie):
	var protectors = get_tree().get_nodes_in_group("shield_mobs")
	for p in protectors:
		if is_instance_valid(p) and p.get("is_shield_active"):
			var dist = p.global_position.distance_to(zombie.global_position)
			if dist <= p.shield_radius:
				return p
	return null


func _on_screen_exited():
	queue_free()
