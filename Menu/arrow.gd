@tool
extends Control

var arrow_color := Color("#60ffaa")
var line_width := 3.0

func _ready() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	queue_redraw()

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	var left_path := get_node_or_null("../LeftPath") as Control
	var right_path := get_node_or_null("../RightPath") as Control
	if left_path:
		_draw_column(left_path)
	if right_path:
		_draw_column(right_path)

func _draw_column(container: Control) -> void:
	var buttons := container.get_children()
	for i in range(buttons.size() - 1):
		var a := buttons[i] as Control
		var b := buttons[i + 1] as Control
		if a == null or b == null:
			continue
		# Start just below bottom edge of upper button
		var from := _global_to_local(a.global_position + Vector2(a.size.x / 2.0, a.size.y))
		# End just above top edge of lower button
		var to := _global_to_local(b.global_position + Vector2(b.size.x / 2.0, 1))
		# Arrow head size
		var head_size := 10.0
		# Draw line stopping before the arrow head
		draw_line(from, to + Vector2(0, 0.5), arrow_color, line_width)
		# Draw arrow head pointing downward at 'to'
		draw_colored_polygon(PackedVector2Array([
			to,
			to + Vector2(-head_size * 0.6, -head_size),
			to + Vector2( head_size * 0.6, -head_size)
		]), arrow_color)

func _global_to_local(global_pos: Vector2) -> Vector2:
	return global_pos - global_position
