#extends Area2D
#
#@export var speed: float = 1000
#@export var damage: int = 2
#
#func _ready():
	#body_entered.connect(_on_body_entered)
#
#func _process(delta):
	#position += transform.x * speed * delta
#
#func _on_body_entered(body):
	#if body.is_in_group("zombies"):
		#if body.has_method("take_damage"):
			#body.take_damage(damage)
		#
		#queue_free()
#
#func _on_screen_exited():
	#queue_free()
# bullet.gd
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
	if is_instance_valid(target_node):
		look_at(target_node.global_position)
	position += transform.x * speed * delta
	
func set_hit_target(node):
	target_node = node
	if is_instance_valid(node) and node.has_method("get_parent"):
		var target_vel = Vector2.ZERO
		# PathFollow2D moves the enemy, so we estimate velocity from its speed
		if node.get("speed") != null and node.get("speed_modifier") != null:
			var follow = node.get_parent()
			if follow is PathFollow2D:
				var dir = follow.get_parent().curve.get_point_position(1) - follow.get_parent().curve.get_point_position(0)
				dir = dir.normalized()
				target_vel = dir * node.speed * node.speed_modifier
		
		# Predict how long the bullet takes to reach the target
		var dist = global_position.distance_to(node.global_position)
		var travel_time = dist / speed
		
		# Aim at where they'll be
		var predicted_pos = node.global_position + target_vel * travel_time
		look_at(predicted_pos)

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
