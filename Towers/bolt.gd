extends Line2D

@export var duration: float = 0.2
@export var jiggle_amount: float = 10.0

func create_bolt(start_pos: Vector2, end_pos: Vector2):
	clear_points()

	add_point(to_local(start_pos))

	var segments = 4
	for i in range(1, segments):
		var t = float(i) / segments
		var mid_point = start_pos.lerp(end_pos, t)

		var offset = Vector2(
			randf_range(-jiggle_amount, jiggle_amount),
			randf_range(-jiggle_amount, jiggle_amount)
		)

		add_point(to_local(mid_point + offset))

	add_point(to_local(end_pos))

	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, duration)
	tween.finished.connect(queue_free)
