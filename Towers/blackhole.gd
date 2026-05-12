# blackhole.gd
extends Area2D

@export var pull_strength: float = 900.0
@export var duration: float = 1.5
@export var friction: float = 0.08
@export var damage_per_second: float = 10.0
var base_scale: float = 1.0  # set by tower before add_child
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
		var dist = global_position.distance_to(body.global_position)
		var path = follower.get_parent()
		var path_len = path.curve.get_baked_length()

		var proximity_scale = pull_strength / max(dist, 1.0)
		var actual_step = proximity_scale * delta

		var progress_forward  = clamp(follower.progress + actual_step, 0.0, path_len)
		var progress_backward = clamp(follower.progress - actual_step, 0.0, path_len)
		var pos_forward  = path.to_global(path.curve.sample_baked(progress_forward))
		var pos_backward = path.to_global(path.curve.sample_baked(progress_backward))

		if global_position.distance_to(pos_forward) < global_position.distance_to(pos_backward):
			follower.progress += actual_step
		else:
			follower.progress -= actual_step

		if body.has_method("take_damage"):
			body.take_damage(damage_per_second * delta)

func get_path_follower(body: Node) -> PathFollow2D:
	var node = body
	while node != null:
		if node is PathFollow2D:
			return node
		node = node.get_parent()
	return null

func visual_rotation(delta):
	rotation += delta * 10.0
