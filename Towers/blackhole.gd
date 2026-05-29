extends Area2D

@export var pull_strength: float = 150.0
@export var duration: float = 1.5
@export var friction: float = 0.08
@export var damage_per_second: float = 10.0
var base_scale: float = 1.0
var target_pos: Vector2
var is_active: bool = false

func _process(delta):
	if not is_active:
		global_position = global_position.lerp(target_pos, friction)
		if global_position.distance_to(target_pos) < 3.0:
			activate_black_hole()
	else:
		visual_rotation(delta)
		pull_entities(delta)

func activate_black_hole():
	is_active = true
	var target_scale = Vector2(1.5, 1.5) * base_scale
	var t = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	t.tween_property(self, "scale", target_scale, 0.5)
	await get_tree().create_timer(duration).timeout
	var t2 = create_tween()
	t2.tween_property(self, "scale", Vector2.ZERO, 0.3)
	t2.finished.connect(queue_free)

func pull_entities(delta):
	var bodies = $ExplosionArea.get_overlapping_bodies()
	for body in bodies:
		if not body.is_in_group("zombies"):
			continue
		var follower = get_path_follower(body)
		if follower == null:
			continue

		if body.has_method("take_damage"):
			body.take_damage(damage_per_second * delta)

		if body.get("is_boss") == true:
			continue

		var path = follower.get_parent()
		var path_len = path.curve.get_baked_length()

		var closest_progress = follower.progress
		var closest_dist = global_position.distance_to(body.global_position)
		var search_step = 10.0
		for i in range(1, 30):
			var test_progress = clamp(follower.progress - (search_step * i), 0.0, path_len)
			var test_pos = path.to_global(path.curve.sample_baked(test_progress))
			var test_dist = global_position.distance_to(test_pos)
			if test_dist < closest_dist:
				closest_dist = test_dist
				closest_progress = test_progress

		var pull_step = pull_strength * delta
		if closest_progress < follower.progress:
			follower.progress = max(follower.progress - pull_step, closest_progress)

func get_path_follower(body: Node) -> PathFollow2D:
	var node = body
	while node != null:
		if node is PathFollow2D:
			return node
		node = node.get_parent()
	return null

func visual_rotation(delta):
	rotation += delta * 10.0
