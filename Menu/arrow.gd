@tool
extends Control

@export var button_columns: Array[Array] = []

func _ready():
	queue_redraw()

func _draw():
	var arrow_color = Color("#60ffaa")
	var line_width = 2.0

	for column in button_columns:
		for i in range(column.size() - 1):
			var from = get_bottom_center(column[i])
			var to = get_top_center(column[i + 1])
			draw_line(from, to, arrow_color, line_width)
			draw_arrow_head(to, arrow_color)

func get_bottom_center(button: Control) -> Vector2:
	return button.global_position - global_position + Vector2(button.size.x / 2, button.size.y)

func get_top_center(button: Control) -> Vector2:
	return button.global_position - global_position + Vector2(button.size.x / 2, 0)

func draw_arrow_head(tip: Vector2, color: Color):
	var size = 8.0
	var points = PackedVector2Array([
		tip,
		tip + Vector2(-size * 0.5, -size),
		tip + Vector2(size * 0.5, -size)
	])
	draw_colored_polygon(points, color)
